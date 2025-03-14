(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

type flow_mode =
  | OptIn
  | OptInStrict
  | OptInStrictLocal
  | OptOut

(*
  * Specifies a function that should be invoked instead of React.createElement
  * when interpreting JSX syntax. Otherwise, the usual rules of JSX are
  * followed: children are varargs after a props argument.
  *)
type jsx_pragma = string * (Loc.t, Loc.t) Flow_ast.Expression.t

type jsx_runtime_pragma =
  | JsxRuntimePragmaClassic
  | JsxRuntimePragmaAutomatic

type t = {
  flow: flow_mode option;
  preventMunge: bool;
  providesModule: string option;
  jsx: jsx_pragma option;
  jsxRuntime: jsx_runtime_pragma option;
  lti: bool;
}

let default_info =
  {
    flow = None;
    preventMunge = false;
    providesModule = None;
    jsx = None;
    jsxRuntime = None;
    lti = false;
  }

(* accessors *)
let flow info = info.flow

let preventMunge info = info.preventMunge

let providesModule info = info.providesModule

let jsx info = info.jsx

let jsx_runtime info = info.jsxRuntime

let lti info = info.lti

let is_strict info =
  match info.flow with
  | Some OptInStrict -> true
  | Some OptIn
  | Some OptInStrictLocal
  | Some OptOut
  | None ->
    false

let is_flow info =
  match info.flow with
  | Some OptIn
  | Some OptInStrict
  | Some OptInStrictLocal ->
    true
  | Some OptOut
  | None ->
    false

(* debugging *)
let json_of_docblock info =
  Hh_json.(
    let flow =
      match flow info with
      | Some OptIn -> JSON_String "OptIn"
      | Some OptInStrict -> JSON_String "OptInStrict"
      | Some OptInStrictLocal -> JSON_String "OptInStrictLocal"
      | Some OptOut -> JSON_String "OptOut"
      | None -> JSON_Null
    in
    let preventsMunge =
      if preventMunge info then
        JSON_Bool true
      else
        JSON_Null
    in
    let providesModule =
      match providesModule info with
      | Some str -> JSON_String str
      | None -> JSON_Null
    in
    JSON_Object
      [("flow", flow); ("preventMunge", preventsMunge); ("providesModule", providesModule)]
  )
