(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

(* This module sets up the definitions for JavaScript globals. Eventually, this
   module should become redundant: we should be able to automatically interpret
   TypeScript type definition files for these and many other primitives. That
   said, in some cases handcoding may turn out to be necessary because the type
   system is not powerful enough to encode the invariants of a library
   function. In any case, this part of the design must be revisited in the
   future. *)

open Utils_js
module Parsing = Parsing_service_js
module Infer = Type_inference_js
module ErrorSet = Flow_error.ErrorSet

let is_ok { Parsing.parsed; _ } = not (FilenameSet.is_empty parsed)

let is_fail { Parsing.failed; _ } = fst failed <> []

type lib_result =
  | Lib_ok of {
      ast: (Loc.t, Loc.t) Flow_ast.Program.t;
      file_sig: File_sig.With_Loc.t;
      tolerable_errors: File_sig.With_Loc.tolerable_error list;
    }
  | Lib_fail of Parsing.parse_failure
  | Lib_skip

let parse_lib_file ~reader options file =
  (* types are always allowed in lib files *)
  let types_mode = Parsing.TypesAllowed in
  (* lib files are always "use strict" *)
  let use_strict = true in
  try%lwt
    let lib_file = File_key.LibFile file in
    let filename_set = FilenameSet.singleton lib_file in
    let next = Parsing.next_of_filename_set (* workers *) None filename_set in
    let%lwt results =
      Parsing.parse_with_defaults ~types_mode ~use_strict ~reader options (* workers *) None next
    in
    Lwt.return
      ( if is_ok results then
        let ast = Parsing_heaps.Mutator_reader.get_ast_unsafe ~reader lib_file in
        let (file_sig, tolerable_errors) =
          Parsing_heaps.Mutator_reader.get_tolerable_file_sig_unsafe ~reader lib_file
        in
        Lib_ok { ast; file_sig; tolerable_errors }
      else if is_fail results then
        let error = List.hd (snd results.Parsing.failed) in
        Lib_fail error
      else
        Lib_skip
      )
  with
  | _ -> failwith (spf "Can't read library definitions file %s, exiting." file)

let infer_lib_file ~ccx ~options ~exclude_syms lib_file ast file_sig =
  let verbose = Options.verbose options in
  let lint_severities = Options.lint_severities options in
  let metadata =
    Context.(
      let metadata = metadata_of_options options in
      { metadata with checked = false }
    )
  in
  (* Lib files use only concrete locations, so this is not used. *)
  let aloc_table = lazy (ALoc.empty_table lib_file) in
  let cx = Context.make ccx metadata lib_file aloc_table Context.InitLib in
  let (syms, _) = Infer.infer_lib_file cx ast ~exclude_syms ~lint_severities ~file_sig in

  if verbose != None then
    prerr_endlinef
      "load_lib %s: added symbols { %s }"
      (File_key.to_string lib_file)
      (String.concat ", " (Base.List.map ~f:Reason.display_string_of_name syms));

  (* symbols loaded from this file are suppressed if found in later ones *)
  (cx, NameUtils.Set.union exclude_syms (NameUtils.Set.of_list syms))

(* process all lib files: parse, infer, and add the symbols they define
   to the builtins object.

   Note: we support overrides of definitions found earlier in the list of
   files by those of the same name found in later ones, so caller must
   preserve lib path declaration order in the (flattened) list of files
   passed.

   returns (success, parse and signature errors, exports)
*)
let load_lib_files ~ccx ~options ~reader files =
  (* iterate in reverse override order *)
  let%lwt (_, leader, ok, errors, ordered_asts) =
    List.rev files
    |> Lwt_list.fold_left_s
         (fun (exclude_syms, leader, ok_acc, errors_acc, asts_acc) file ->
           let lib_file = File_key.LibFile file in
           match%lwt parse_lib_file ~reader options file with
           | Lib_ok { ast; file_sig; tolerable_errors } ->
             let file_sig = File_sig.abstractify_locs file_sig in
             let tolerable_errors = File_sig.abstractify_tolerable_errors tolerable_errors in
             let (cx, exclude_syms) =
               infer_lib_file ~ccx ~options ~exclude_syms lib_file ast file_sig
             in
             let errors =
               tolerable_errors
               |> Inference_utils.set_of_file_sig_tolerable_errors ~source_file:lib_file
             in
             let errors_acc = ErrorSet.union errors errors_acc in
             let asts_acc = ast :: asts_acc in
             Lwt.return (exclude_syms, Some cx, ok_acc, errors_acc, asts_acc)
           | Lib_fail fail ->
             let errors =
               match fail with
               | Parsing.Uncaught_exception exn ->
                 Inference_utils.set_of_parse_exception ~source_file:lib_file exn
               | Parsing.Parse_error error ->
                 Inference_utils.set_of_parse_error ~source_file:lib_file error
               | Parsing.Docblock_errors errs ->
                 Inference_utils.set_of_docblock_errors ~source_file:lib_file errs
             in
             let errors_acc = ErrorSet.union errors errors_acc in
             Lwt.return (exclude_syms, leader, false, errors_acc, asts_acc)
           | Lib_skip -> Lwt.return (exclude_syms, leader, ok_acc, errors_acc, asts_acc))
         (NameUtils.Set.empty, None, true, ErrorSet.empty, [])
  in
  let builtin_exports =
    if ok then
      let sig_opts =
        {
          Type_sig_parse.suppress_types = Options.suppress_types options;
          munge = (* libs shouldn't have private fields *) false;
          ignore_static_propTypes = true;
          facebook_keyMirror = (* irrelevant for libs *) false;
          facebook_fbt = Options.facebook_fbt options;
          max_literal_len = Options.max_literal_length options;
          exact_by_default = Options.exact_by_default options;
          module_ref_prefix = Options.haste_module_ref_prefix options;
          enable_enums = Options.enums options;
          enable_relay_integration = Options.enable_relay_integration options;
          relay_integration_module_prefix = Options.relay_integration_module_prefix options;
        }
      in
      let (_builtin_errors, _builtin_locs, builtins) =
        Type_sig_utils.parse_and_pack_builtins sig_opts ordered_asts
      in
      let builtins =
        (* hide #flow-internal-react-server-module module *)
        let { Packed_type_sig.Builtins.modules; _ } = builtins in
        let modules = SMap.remove Type.react_server_module_ref modules in
        { builtins with Packed_type_sig.Builtins.modules }
      in
      Exports.of_builtins builtins
    else
      Exports.empty
  in
  Lwt.return (ok, leader, errors, builtin_exports)

type init_result = {
  ok: bool;
  errors: ErrorSet.t FilenameMap.t;
  warnings: ErrorSet.t FilenameMap.t;
  suppressions: Error_suppressions.t;
  exports: Exports.t;
}

let error_set_to_filemap err_set =
  ErrorSet.fold
    (fun error map ->
      let file = Flow_error.source_file error in
      FilenameMap.update
        file
        (function
          | None -> Some (ErrorSet.singleton error)
          | Some set -> Some (ErrorSet.add error set))
        map)
    err_set
    FilenameMap.empty

(* initialize builtins:
   parse and do local inference on library files, and set up master context.
   returns list of (lib file, success) pairs.
*)
let init ~options ~reader lib_files =
  let ccx = Context.(make_ccx (empty_master_cx ())) in

  let%lwt (ok, leader, parse_and_sig_errors, exports) =
    load_lib_files ~ccx ~options ~reader lib_files
  in

  let (master_cx, errors, warnings, suppressions) =
    match leader with
    | None -> (Context.empty_master_cx (), ErrorSet.empty, ErrorSet.empty, Error_suppressions.empty)
    | Some cx ->
      Merge_js.optimize_builtins cx;
      let errors = Context.errors cx in
      let suppressions = Context.error_suppressions cx in
      let severity_cover = Context.severity_cover cx in
      let include_suppressions = Context.include_suppressions cx in
      let (errors, warnings, suppressions) =
        Error_suppressions.filter_lints
          ~include_suppressions
          suppressions
          errors
          (Context.aloc_tables cx)
          severity_cover
      in
      let master_cx = Context.{ master_sig_cx = sig_cx cx; builtins = builtins cx } in
      (master_cx, errors, warnings, suppressions)
  in

  (* store master signature context to heap *)
  Context_heaps.Init_master_context_mutator.add_master ~audit:Expensive.ok master_cx;

  let errors = ErrorSet.union parse_and_sig_errors errors in
  let (errors, warnings, suppressions) =
    (error_set_to_filemap errors, error_set_to_filemap warnings, suppressions)
  in

  Lwt.return { ok; errors; warnings; suppressions; exports }
