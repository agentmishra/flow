(*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 *)

open Type
open Reason
open Utils_js

exception EDebugThrow of ALoc.t

exception ECheckTimeout of float * string

type invalid_char_set =
  | DuplicateChar of Char.t
  | InvalidChar of Char.t

module InvalidCharSetSet = Flow_set.Make (struct
  type t = invalid_char_set

  let compare = Stdlib.compare
end)

type t = ALoc.t t'

and 'loc t' =
  | EIncompatible of {
      lower: 'loc virtual_reason * lower_kind option;
      upper: 'loc virtual_reason * 'loc upper_kind;
      use_op: 'loc virtual_use_op option;
      branches: ('loc Reason.virtual_reason * 'loc t') list;
    }
  | EIncompatibleDefs of {
      use_op: 'loc virtual_use_op;
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      branches: ('loc Reason.virtual_reason * 'loc t') list;
    }
  | EIncompatibleProp of {
      prop: name option;
      reason_prop: 'loc virtual_reason;
      reason_obj: 'loc virtual_reason;
      special: lower_kind option;
      use_op: 'loc virtual_use_op option;
    }
  | EDebugPrint of 'loc virtual_reason * string
  | EExportValueAsType of 'loc virtual_reason * name
  | EImportValueAsType of 'loc virtual_reason * string
  | EImportTypeAsTypeof of 'loc virtual_reason * string
  | EImportTypeAsValue of 'loc virtual_reason * string
  | ERefineAsValue of 'loc virtual_reason * name
  | ENoDefaultExport of 'loc virtual_reason * string * string option
  | EOnlyDefaultExport of 'loc virtual_reason * string * string
  | ENoNamedExport of 'loc virtual_reason * string * string * string option
  | EMissingTypeArgs of {
      reason_op: 'loc virtual_reason;
      reason_tapp: 'loc virtual_reason;
      reason_arity: 'loc virtual_reason;
      min_arity: int;
      max_arity: int;
    }
  | EAnyValueUsedAsType of { reason_use: 'loc virtual_reason }
  | EValueUsedAsType of { reason_use: 'loc virtual_reason }
  | EExpectedStringLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExpectedNumberLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExpectedBooleanLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExpectedBigIntLit of {
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EPropNotFound of {
      prop_name: name option;
      reason_prop: 'loc virtual_reason;
      reason_obj: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
      suggestion: string option;
    }
  | EPropNotReadable of {
      reason_prop: 'loc virtual_reason;
      prop_name: name option;
      use_op: 'loc virtual_use_op;
    }
  | EPropNotWritable of {
      reason_prop: 'loc virtual_reason;
      prop_name: name option;
      use_op: 'loc virtual_use_op;
    }
  | EPropPolarityMismatch of
      ('loc virtual_reason * 'loc virtual_reason)
      * name option
      * (Polarity.t * Polarity.t)
      * 'loc virtual_use_op
  | EPolarityMismatch of {
      reason: 'loc virtual_reason;
      name: string;
      expected_polarity: Polarity.t;
      actual_polarity: Polarity.t;
    }
  | EBuiltinLookupFailed of {
      reason: 'loc virtual_reason;
      name: Reason.name option;
      potential_generator: string option;
    }
  | EStrictLookupFailed of {
      reason_prop: 'loc virtual_reason;
      reason_obj: 'loc virtual_reason;
      name: name option;
      suggestion: string option;
      use_op: 'loc virtual_use_op option;
    }
  | EPrivateLookupFailed of ('loc virtual_reason * 'loc virtual_reason) * name * 'loc virtual_use_op
  | EAdditionMixed of 'loc virtual_reason * 'loc virtual_use_op
  | EComparison of ('loc virtual_reason * 'loc virtual_reason)
  | ENonStrictEqualityComparison of ('loc virtual_reason * 'loc virtual_reason)
  | EEscapedGeneric of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      blame_reason: 'loc virtual_reason;
      annot_reason: 'loc virtual_reason option;
      bound_name: string;
      bound_loc: 'loc;
      is_this: bool;
    }
  | ETupleArityMismatch of
      ('loc virtual_reason * 'loc virtual_reason) * int * int * 'loc virtual_use_op
  | ENonLitArrayToTuple of ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | ETupleOutOfBounds of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      length: int;
      index: string;
    }
  | ETupleNonIntegerIndex of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      index: string;
    }
  | ETupleUnsafeWrite of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | ETupleElementNotReadable of {
      reason: 'loc virtual_reason;
      index: int;
      name: string option;
      use_op: 'loc virtual_use_op;
    }
  | ETupleElementNotWritable of {
      reason: 'loc virtual_reason;
      index: int;
      name: string option;
      use_op: 'loc virtual_use_op;
    }
  | ETupleElementPolarityMismatch of {
      index: int;
      reason_lower: 'loc Reason.virtual_reason;
      polarity_lower: Polarity.t;
      reason_upper: 'loc Reason.virtual_reason;
      polarity_upper: Polarity.t;
      use_op: 'loc Type.virtual_use_op;
    }
  | EROArrayWrite of ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | EUnionSpeculationFailed of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      branches: ('loc virtual_reason * 'loc t') list;
    }
  | ESpeculationAmbiguous of {
      reason: 'loc virtual_reason;
      prev_case: int * 'loc virtual_reason;
      case: int * 'loc virtual_reason;
      cases: 'loc virtual_reason list;
    }
  | EIncompatibleWithExact of
      ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op * exactness_error_kind
  | EFunctionIncompatibleWithIndexer of
      ('loc virtual_reason * 'loc virtual_reason) * 'loc virtual_use_op
  | EUnsupportedExact of ('loc virtual_reason * 'loc virtual_reason)
  | EIdxArity of 'loc virtual_reason
  | EIdxUse of 'loc virtual_reason
  | EUnexpectedThisType of 'loc
  | ETypeParamArity of 'loc * int
  | ECallTypeArity of {
      call_loc: 'loc;
      is_new: bool;
      reason_arity: 'loc virtual_reason;
      expected_arity: int;
    }
  | ETypeParamMinArity of 'loc * int
  | ETooManyTypeArgs of 'loc virtual_reason * 'loc virtual_reason * int
  | ETooFewTypeArgs of 'loc virtual_reason * 'loc virtual_reason * int
  | EInvalidTypeArgs of 'loc virtual_reason * 'loc virtual_reason
  | EInvalidExtends of 'loc virtual_reason
  | EPropertyTypeAnnot of 'loc
  | EExportsAnnot of 'loc
  | ECharSetAnnot of 'loc
  | EInvalidCharSet of {
      invalid: 'loc virtual_reason * InvalidCharSetSet.t;
      valid: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidConstructor of 'loc virtual_reason
  | EInvalidConstructorDefinition of {
      loc: 'loc;
      async: bool;
      generator: bool;
      predicate: bool;
    }
  | EUnsupportedKeyInObjectType of 'loc
  | EPredAnnot of 'loc
  | ERefineAnnot of 'loc
  | ETrustedAnnot of 'loc
  | EPrivateAnnot of 'loc
  | EFunPredCustom of ('loc virtual_reason * 'loc virtual_reason) * string
  | EIncompatibleWithShape of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | EInternal of 'loc * internal_error
  | EUnsupportedSyntax of 'loc * 'loc unsupported_syntax
  | EUseArrayLiteral of 'loc
  | EMissingAnnotation of 'loc virtual_reason * 'loc virtual_reason list
  | EMissingLocalAnnotation of {
      reason: 'loc virtual_reason;
      hint_available: bool;
      from_generic_function: bool;
    }
  | EBindingError of binding_error * 'loc * name * ALoc.t
  | ERecursionLimit of ('loc virtual_reason * 'loc virtual_reason)
  | EUninitializedInstanceProperty of 'loc * Lints.property_assignment_kind
  | EEnumsNotEnabled of 'loc
  | EUnsafeGetSet of 'loc
  | EIndeterminateModuleType of 'loc
  | EBadExportPosition of 'loc
  | EBadExportContext of string * 'loc
  | EBadDefaultImportAccess of 'loc * 'loc virtual_reason
  | EBadDefaultImportDestructuring of 'loc
  | EInvalidImportStarUse of 'loc * 'loc virtual_reason
  | ENonConstVarExport of 'loc * 'loc virtual_reason option
  | EThisInExportedFunction of 'loc
  | EMixedImportAndRequire of 'loc * 'loc virtual_reason
  | EToplevelLibraryImport of 'loc
  | EExportRenamedDefault of {
      loc: 'loc;
      name: string option;
      is_reexport: bool;
    }
  | EUnreachable of 'loc
  | EInvalidObjectKit of {
      reason: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidTypeof of 'loc * string
  | EBinaryInLHS of 'loc virtual_reason
  | EBinaryInRHS of 'loc virtual_reason
  | EArithmeticOperand of 'loc virtual_reason
  | EForInRHS of 'loc virtual_reason
  | EInstanceofRHS of 'loc virtual_reason
  | EObjectComputedPropertyAccess of ('loc virtual_reason * 'loc virtual_reason)
  | EObjectComputedPropertyAssign of ('loc virtual_reason * 'loc virtual_reason)
  | EInvalidLHSInAssignment of 'loc
  | EIncompatibleWithUseOp of {
      use_op: 'loc virtual_use_op;
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
    }
  | ETrustIncompatibleWithUseOp of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | EUnsupportedImplements of 'loc virtual_reason
  | ENotAReactComponent of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidReactConfigType of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EInvalidReactPropType of {
      reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
      tool: React.SimplifyPropType.tool;
    }
  | EReactElementFunArity of 'loc virtual_reason * string * int
  | EFunctionCallExtraArg of 'loc virtual_reason * 'loc virtual_reason * int * 'loc virtual_use_op
  | EUnsupportedSetProto of 'loc virtual_reason
  | EDuplicateModuleProvider of {
      module_name: string;
      provider: 'loc;
      conflict: 'loc;
    }
  | EParseError of 'loc * Parse_error.t
  | EDocblockError of 'loc * docblock_error
  | EImplicitInexactObject of 'loc
  | EAmbiguousObjectType of 'loc
  (* The string is either the name of a module or "the module that exports `_`". *)
  | EUntypedTypeImport of 'loc * string
  | EUntypedImport of 'loc * string
  | ENonstrictImport of 'loc
  | EUnclearType of 'loc
  | EDeprecatedBool of 'loc
  | EDeprecatedType of 'loc
  | EUnsafeGettersSetters of 'loc
  | EUnusedSuppression of 'loc
  | ECodelessSuppression of 'loc * string
  | ELintSetting of 'loc * LintSettings.lint_parse_error
  | ESketchyNullLint of {
      kind: Lints.sketchy_null_kind;
      loc: 'loc;
      null_loc: 'loc;
      falsy_loc: 'loc;
    }
  | ESketchyNumberLint of Lints.sketchy_number_kind * 'loc virtual_reason
  | EInvalidPrototype of 'loc * 'loc virtual_reason
  | EUnnecessaryOptionalChain of 'loc * 'loc virtual_reason
  | EUnnecessaryInvariant of 'loc * 'loc virtual_reason
  | EUnexpectedTemporaryBaseType of 'loc
  | ECannotDelete of 'loc * 'loc virtual_reason
  | ESignatureVerification of 'loc Signature_error.t
  | ECannotSpreadInterface of {
      spread_reason: 'loc virtual_reason;
      interface_reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | ECannotSpreadIndexerOnRight of {
      spread_reason: 'loc virtual_reason;
      object_reason: 'loc virtual_reason;
      key_reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EUnableToSpread of {
      spread_reason: 'loc virtual_reason;
      object1_reason: 'loc virtual_reason;
      object2_reason: 'loc virtual_reason;
      propname: name;
      error_kind: exactness_error_kind;
      use_op: 'loc virtual_use_op;
    }
  | EInexactMayOverwriteIndexer of {
      spread_reason: 'loc virtual_reason;
      key_reason: 'loc virtual_reason;
      value_reason: 'loc virtual_reason;
      object2_reason: 'loc virtual_reason;
      use_op: 'loc virtual_use_op;
    }
  | EExponentialSpread of {
      reason: 'loc virtual_reason;
      reasons_for_operand1: 'loc exponential_spread_reason_group;
      reasons_for_operand2: 'loc exponential_spread_reason_group;
    }
  | EComputedPropertyWithMultipleLowerBounds of {
      computed_property_reason: 'loc virtual_reason;
      new_lower_bound_reason: 'loc virtual_reason;
      existing_lower_bound_reason: 'loc virtual_reason;
    }
  | EComputedPropertyWithUnion of {
      computed_property_reason: 'loc virtual_reason;
      union_reason: 'loc virtual_reason;
    }
  (* enums *)
  | EEnumInvalidMemberAccess of {
      member_name: name option;
      suggestion: string option;
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumModification of {
      loc: 'loc;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumMemberDuplicateValue of {
      loc: 'loc;
      prev_use_loc: 'loc;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumInvalidObjectUtil of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumNotIterable of {
      reason: 'loc virtual_reason;
      for_in: bool;
    }
  | EEnumMemberAlreadyChecked of {
      reason: 'loc virtual_reason;
      prev_check_reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
      member_name: string;
    }
  | EEnumAllMembersAlreadyChecked of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumNotAllChecked of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
      left_to_check: string list;
      default_case: 'loc virtual_reason option;
    }
  | EEnumUnknownNotChecked of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumInvalidCheck of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
      example_member: string option;
    }
  | EEnumMemberUsedAsType of {
      reason: 'loc virtual_reason;
      enum_reason: 'loc virtual_reason;
    }
  | EEnumIncompatible of {
      use_op: 'loc virtual_use_op;
      reason_lower: 'loc virtual_reason;
      reason_upper: 'loc virtual_reason;
      representation_type: string option;
    }
  (* end enum error messages *)
  | EAssignConstLikeBinding of {
      loc: 'loc;
      definition: 'loc virtual_reason;
      binding_kind: assigned_const_like_binding_type;
    }
  | ECannotResolveOpenTvar of {
      use_op: 'loc virtual_use_op;
      reason: 'loc virtual_reason;
      blame_reasons: 'loc virtual_reason list;
    }
  | EMalformedCode of 'loc
  | EImplicitInstantiationTemporaryError of 'loc * string
  | EImportInternalReactServerModule of 'loc
  | EImplicitInstantiationUnderconstrainedError of {
      reason_call: 'loc virtual_reason;
      reason_tparam: 'loc virtual_reason;
      bound: string;
      use_op: 'loc virtual_use_op;
    }
  | EImplicitInstantiationWidenedError of {
      reason_call: 'loc virtual_reason;
      bound: string;
    }
  | EClassToObject of 'loc virtual_reason * 'loc virtual_reason * 'loc virtual_use_op
  | EMethodUnbinding of {
      use_op: 'loc virtual_use_op;
      reason_prop: 'loc virtual_reason;
      reason_op: 'loc virtual_reason;
    }
  | EObjectThisReference of 'loc * 'loc virtual_reason
  | EInvalidDeclaration of {
      declaration: 'loc virtual_reason;
      null_write: 'loc null_write option;
    }
  | EInvalidGraphQL of 'loc * Graphql.error
  | EAnnotationInference of 'loc * 'loc virtual_reason * 'loc virtual_reason * string option
  | EAnnotationInferenceRecursive of 'loc * 'loc virtual_reason
  | EDefinitionCycle of ('loc virtual_reason * 'loc list * 'loc Env_api.annot_loc list) Nel.t
  | ERecursiveDefinition of {
      reason: 'loc virtual_reason;
      recursion: 'loc list;
      annot_locs: 'loc Env_api.annot_loc list;
    }
  | EDuplicateClassMember of {
      loc: 'loc;
      name: string;
      static: bool;
    }
  | EEmptyArrayNoProvider of { loc: 'loc }
  | EUnusedPromise of { loc: 'loc }
  | EBigIntRShift3 of 'loc virtual_reason
  | EBigIntNumCoerce of 'loc virtual_reason
  | EInvalidCatchParameterAnnotation of 'loc
  | ETSSyntax of {
      kind: ts_syntax_kind;
      loc: 'loc;
    }
  | EInvalidBinaryArith of {
      reason_out: 'loc virtual_reason;
      reason_l: 'loc virtual_reason;
      reason_r: 'loc virtual_reason;
      kind: ArithKind.t;
    }

and 'loc null_write = {
  null_loc: 'loc;
  initialized: bool;
}

and 'loc exponential_spread_reason_group = {
  first_reason: 'loc virtual_reason;
  second_reason: 'loc virtual_reason option;
}

and exactness_error_kind =
  | Indexer
  | Inexact

and binding_error =
  | ENameAlreadyBound
  | EVarRedeclaration
  | EReferencedBeforeDeclaration
  | ETypeInValuePosition of {
      imported: bool;
      name: string;
    }
  | ETypeAliasInValuePosition
  | EConstReassigned
  | EConstParamReassigned
  | EImportReassigned
  | EEnumReassigned

and assigned_const_like_binding_type =
  | ClassNameBinding
  | FunctionNameBinding
  | DeclaredFunctionNameBinding

and docblock_error =
  | MultipleFlowAttributes
  | InvalidFlowMode of string
  | MultipleProvidesModuleAttributes
  | MultipleJSXAttributes
  | InvalidJSXAttribute of string option
  | MultipleJSXRuntimeAttributes
  | InvalidJSXRuntimeAttribute

and internal_error =
  | AbnormalControlFlow
  | MethodNotAFunction
  | OptionalMethod
  | PredFunWithoutParamNames
  | UnsupportedGuardPredicate of string
  | PropertyDescriptorPropertyCannotBeRead
  | ForInLHS
  | ForOfLHS
  | InstanceLookupComputed
  | PropRefComputedOpen
  | PropRefComputedLiteral
  | RestParameterNotIdentifierPattern
  | InterfaceTypeSpread
  | DebugThrow
  | ParseJobException of Exception.t
  | CheckTimeout of float
  | CheckJobException of Exception.t
  | UnexpectedTypeapp of string
  | UnexpectedAnnotationInference of string
  | MissingEnvRead of ALoc.t
  | MissingEnvWrite of ALoc.t
  | UnconstrainedTvar of int option
  | PlaceholderTypeInChecking
  | ReadOfUnreachedTvar of Env_api.def_loc_type
  | ReadOfUnresolvedTvar of Env_api.def_loc_type
  | EnvInvariant of Env_api.env_invariant_failure
  | ImplicitInstantiationInvariant of string

and 'loc unsupported_syntax =
  | AnnotationInsideDestructuring
  | ComprehensionExpression
  | GeneratorExpression
  | MetaPropertyExpression
  | ObjectPropertyLiteralNonString
  | ObjectPropertyGetSet
  | ObjectPropertyComputedGetSet
  | InvariantSpreadArgument
  | ClassPropertyLiteral
  | ClassPropertyComputed
  | RequireDynamicArgument
  | CatchParameterDeclaration
  | DestructuringObjectPropertyLiteralNonString
  | DestructuringExpressionPattern
  | PredicateDeclarationForImplementation
  | PredicateDeclarationWithoutExpression
  | PredicateDeclarationAnonymousParameters
  | PredicateInvalidBody
  | PredicateInvalidParameter of 'loc virtual_reason
  | PredicateFunctionAbstractReturnType
  | PredicateVoidReturn
  | MultipleIndexers
  | MultipleProtos
  | ExplicitCallAfterProto
  | ExplicitProtoAfterCall
  | SpreadArgument
  | ImportDynamicArgument
  | IllegalName
  | TupleOptionalElement
  | TupleSpreadElement
  | UnsupportedInternalSlot of {
      name: string;
      static: bool;
    }

and lower_kind =
  | Possibly_null
  | Possibly_void
  | Possibly_null_or_void
  | Incompatible_intersection

and 'loc upper_kind =
  | IncompatibleGetPropT of 'loc * name option
  | IncompatibleSetPropT of 'loc * name option
  | IncompatibleMatchPropT of 'loc * name option
  | IncompatibleGetPrivatePropT
  | IncompatibleSetPrivatePropT
  | IncompatibleMethodT of 'loc * name option
  | IncompatibleCallT
  | IncompatibleMixedCallT
  | IncompatibleGetElemT of 'loc
  | IncompatibleSetElemT of 'loc
  | IncompatibleCallElemT of 'loc
  | IncompatibleElemTOfArrT
  | IncompatibleObjAssignFromTSpread
  | IncompatibleObjAssignFromT
  | IncompatibleObjRestT
  | IncompatibleArrRestT
  | IncompatibleSuperT
  | IncompatibleMixinT
  | IncompatibleSpecializeT
  | IncompatibleThisSpecializeT
  | IncompatibleVarianceCheckT
  | IncompatibleGetKeysT
  | IncompatibleHasOwnPropT of 'loc * name option
  | IncompatibleGetValuesT
  | IncompatibleUnaryArithT
  | IncompatibleMapTypeTObject
  | IncompatibleTypeAppVarianceCheckT
  | IncompatibleGetStaticsT
  | IncompatibleBindT
  | IncompatibleUnclassified of string

and ts_syntax_kind =
  | TSUnknown
  | TSNever
  | TSUndefined
  | TSKeyof
  | TSTypeParamExtends
  | TSReadonlyVariance
  | TSInOutVariance of [ `In | `Out | `InOut ]
  | TSTypeCast of [ `AsConst | `As | `Satisfies ]
  | TSReadonlyType of [ `Tuple | `Array ] option

let string_of_assigned_const_like_binding_type = function
  | ClassNameBinding -> "class"
  | FunctionNameBinding -> "function"
  | DeclaredFunctionNameBinding -> "declared function"

let map_loc_of_exponential_spread_reason_group f { first_reason; second_reason } =
  { first_reason = f first_reason; second_reason = Base.Option.map ~f second_reason }

let rec map_loc_of_error_message (f : 'a -> 'b) : 'a t' -> 'b t' =
  let map_use_op = TypeUtil.mod_loc_of_virtual_use_op f in
  let map_reason = Reason.map_reason_locs f in
  let map_branch (r, e) = (map_reason r, map_loc_of_error_message f e) in
  let map_upper_kind = function
    | IncompatibleGetPropT (loc, s) -> IncompatibleGetPropT (f loc, s)
    | IncompatibleSetPropT (loc, s) -> IncompatibleSetPropT (f loc, s)
    | IncompatibleMatchPropT (loc, s) -> IncompatibleMatchPropT (f loc, s)
    | IncompatibleMethodT (loc, s) -> IncompatibleMethodT (f loc, s)
    | IncompatibleHasOwnPropT (loc, s) -> IncompatibleHasOwnPropT (f loc, s)
    | IncompatibleGetElemT loc -> IncompatibleGetElemT (f loc)
    | IncompatibleSetElemT loc -> IncompatibleSetElemT (f loc)
    | IncompatibleCallElemT loc -> IncompatibleCallElemT (f loc)
    | ( IncompatibleGetPrivatePropT | IncompatibleSetPrivatePropT | IncompatibleCallT
      | IncompatibleMixedCallT | IncompatibleElemTOfArrT | IncompatibleObjAssignFromTSpread
      | IncompatibleObjAssignFromT | IncompatibleObjRestT | IncompatibleArrRestT
      | IncompatibleSuperT | IncompatibleMixinT | IncompatibleSpecializeT
      | IncompatibleThisSpecializeT | IncompatibleVarianceCheckT | IncompatibleGetKeysT
      | IncompatibleGetValuesT | IncompatibleUnaryArithT | IncompatibleMapTypeTObject
      | IncompatibleTypeAppVarianceCheckT | IncompatibleGetStaticsT | IncompatibleBindT
      | IncompatibleUnclassified _ ) as u ->
      u
  in
  let map_unsupported_syntax = function
    | PredicateInvalidParameter reason -> PredicateInvalidParameter (map_reason reason)
    | ( ComprehensionExpression | GeneratorExpression | MetaPropertyExpression
      | ObjectPropertyLiteralNonString | ObjectPropertyGetSet | ObjectPropertyComputedGetSet
      | InvariantSpreadArgument | ClassPropertyLiteral | ClassPropertyComputed
      | RequireDynamicArgument | CatchParameterDeclaration
      | DestructuringObjectPropertyLiteralNonString | DestructuringExpressionPattern
      | PredicateDeclarationForImplementation | PredicateDeclarationWithoutExpression
      | PredicateDeclarationAnonymousParameters | PredicateInvalidBody
      | PredicateFunctionAbstractReturnType | PredicateVoidReturn | MultipleIndexers
      | MultipleProtos | ExplicitCallAfterProto | ExplicitProtoAfterCall | SpreadArgument
      | ImportDynamicArgument | IllegalName | TupleOptionalElement | TupleSpreadElement
      | UnsupportedInternalSlot _ | AnnotationInsideDestructuring ) as u ->
      u
  in
  function
  | EIncompatible { use_op; lower = (lreason, lkind); upper = (ureason, ukind); branches } ->
    EIncompatible
      {
        use_op = Base.Option.map ~f:map_use_op use_op;
        lower = (map_reason lreason, lkind);
        upper = (map_reason ureason, map_upper_kind ukind);
        branches = Base.List.map ~f:map_branch branches;
      }
  | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
    EIncompatibleDefs
      {
        use_op = map_use_op use_op;
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        branches = Base.List.map ~f:map_branch branches;
      }
  | EIncompatibleProp { use_op; prop; reason_prop; reason_obj; special } ->
    EIncompatibleProp
      {
        use_op = Base.Option.map ~f:map_use_op use_op;
        prop;
        reason_prop = map_reason reason_prop;
        reason_obj = map_reason reason_obj;
        special;
      }
  | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
    EExpectedStringLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
    EExpectedNumberLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
    EExpectedBooleanLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EExpectedBigIntLit { reason_lower; reason_upper; use_op } ->
    EExpectedBigIntLit
      {
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        use_op = map_use_op use_op;
      }
  | EPropNotFound { prop_name; reason_prop; reason_obj; use_op; suggestion } ->
    EPropNotFound
      {
        prop_name;
        reason_prop = map_reason reason_prop;
        reason_obj = map_reason reason_obj;
        use_op = map_use_op use_op;
        suggestion;
      }
  | EPropNotReadable { reason_prop; prop_name; use_op } ->
    EPropNotReadable { reason_prop = map_reason reason_prop; prop_name; use_op = map_use_op use_op }
  | EPropNotWritable { reason_prop; prop_name; use_op } ->
    EPropNotWritable { reason_prop = map_reason reason_prop; prop_name; use_op = map_use_op use_op }
  | EPropPolarityMismatch ((r1, r2), p, ps, op) ->
    EPropPolarityMismatch ((map_reason r1, map_reason r2), p, ps, map_use_op op)
  | EBuiltinLookupFailed { reason; name; potential_generator } ->
    EBuiltinLookupFailed { reason = map_reason reason; name; potential_generator }
  | EStrictLookupFailed { reason_prop; reason_obj; name; suggestion; use_op } ->
    EStrictLookupFailed
      {
        reason_prop = map_reason reason_prop;
        reason_obj = map_reason reason_obj;
        name;
        suggestion;
        use_op = Base.Option.map ~f:map_use_op use_op;
      }
  | EPrivateLookupFailed ((r1, r2), x, op) ->
    EPrivateLookupFailed ((map_reason r1, map_reason r2), x, map_use_op op)
  | EAdditionMixed (r, op) -> EAdditionMixed (map_reason r, map_use_op op)
  | ETupleArityMismatch ((r1, r2), l, i, op) ->
    ETupleArityMismatch ((map_reason r1, map_reason r2), l, i, map_use_op op)
  | ENonLitArrayToTuple ((r1, r2), op) ->
    ENonLitArrayToTuple ((map_reason r1, map_reason r2), map_use_op op)
  | ETupleOutOfBounds { use_op; reason; reason_op; length; index } ->
    ETupleOutOfBounds
      {
        use_op = map_use_op use_op;
        reason = map_reason reason;
        reason_op = map_reason reason_op;
        length;
        index;
      }
  | ETupleNonIntegerIndex { use_op; reason; index } ->
    ETupleNonIntegerIndex { use_op = map_use_op use_op; reason = map_reason reason; index }
  | ETupleUnsafeWrite { reason; use_op } ->
    ETupleUnsafeWrite { reason = map_reason reason; use_op = map_use_op use_op }
  | ETupleElementNotReadable { reason; index; name; use_op } ->
    ETupleElementNotReadable { reason = map_reason reason; index; name; use_op = map_use_op use_op }
  | ETupleElementNotWritable { reason; index; name; use_op } ->
    ETupleElementNotWritable { reason = map_reason reason; index; name; use_op = map_use_op use_op }
  | ETupleElementPolarityMismatch
      { index; reason_lower; polarity_lower; reason_upper; polarity_upper; use_op } ->
    ETupleElementPolarityMismatch
      {
        index;
        reason_lower = map_reason reason_lower;
        polarity_lower;
        reason_upper = map_reason reason_upper;
        polarity_upper;
        use_op = map_use_op use_op;
      }
  | EROArrayWrite ((r1, r2), op) -> EROArrayWrite ((map_reason r1, map_reason r2), map_use_op op)
  | EUnionSpeculationFailed { use_op; reason; reason_op; branches } ->
    EUnionSpeculationFailed
      {
        use_op = map_use_op use_op;
        reason = map_reason reason;
        reason_op = map_reason reason_op;
        branches = Base.List.map ~f:map_branch branches;
      }
  | EIncompatibleWithExact ((r1, r2), op, kind) ->
    EIncompatibleWithExact ((map_reason r1, map_reason r2), map_use_op op, kind)
  | EFunctionIncompatibleWithIndexer ((r1, r2), op) ->
    EFunctionIncompatibleWithIndexer ((map_reason r1, map_reason r2), map_use_op op)
  | EInvalidCharSet { invalid = (ir, set); valid; use_op } ->
    EInvalidCharSet
      { invalid = (map_reason ir, set); valid = map_reason valid; use_op = map_use_op use_op }
  | EInvalidConstructor r -> EInvalidConstructor (map_reason r)
  | EInvalidConstructorDefinition ({ loc; _ } as stuff) ->
    EInvalidConstructorDefinition { stuff with loc = f loc }
  | EIncompatibleWithShape (l, u, use_op) ->
    EIncompatibleWithShape (map_reason l, map_reason u, map_use_op use_op)
  | EInvalidObjectKit { reason; reason_op; use_op } ->
    EInvalidObjectKit
      { reason = map_reason reason; reason_op = map_reason reason_op; use_op = map_use_op use_op }
  | EIncompatibleWithUseOp { use_op; reason_lower; reason_upper } ->
    EIncompatibleWithUseOp
      {
        use_op = map_use_op use_op;
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
      }
  | ETrustIncompatibleWithUseOp (rl, ru, op) ->
    ETrustIncompatibleWithUseOp (map_reason rl, map_reason ru, map_use_op op)
  | ENotAReactComponent { reason; use_op } ->
    ENotAReactComponent { reason = map_reason reason; use_op = map_use_op use_op }
  | EInvalidReactConfigType { reason; use_op } ->
    EInvalidReactConfigType { reason = map_reason reason; use_op = map_use_op use_op }
  | EInvalidReactPropType { reason; use_op; tool } ->
    EInvalidReactPropType { reason = map_reason reason; use_op = map_use_op use_op; tool }
  | EFunctionCallExtraArg (rl, ru, n, op) ->
    EFunctionCallExtraArg (map_reason rl, map_reason ru, n, map_use_op op)
  | EDebugPrint (r, s) -> EDebugPrint (map_reason r, s)
  | EExportValueAsType (r, s) -> EExportValueAsType (map_reason r, s)
  | EImportValueAsType (r, s) -> EImportValueAsType (map_reason r, s)
  | EImportTypeAsTypeof (r, s) -> EImportTypeAsTypeof (map_reason r, s)
  | EImportTypeAsValue (r, s) -> EImportTypeAsValue (map_reason r, s)
  | ERefineAsValue (r, s) -> ERefineAsValue (map_reason r, s)
  | ENoDefaultExport (r, s1, s2) -> ENoDefaultExport (map_reason r, s1, s2)
  | EOnlyDefaultExport (r, s1, s2) -> EOnlyDefaultExport (map_reason r, s1, s2)
  | ENoNamedExport (r, s1, s2, s3) -> ENoNamedExport (map_reason r, s1, s2, s3)
  | EMissingTypeArgs { reason_op; reason_tapp; reason_arity; min_arity; max_arity } ->
    EMissingTypeArgs
      {
        reason_op = map_reason reason_op;
        reason_tapp = map_reason reason_tapp;
        reason_arity = map_reason reason_arity;
        min_arity;
        max_arity;
      }
  | EAnyValueUsedAsType { reason_use } -> EAnyValueUsedAsType { reason_use = map_reason reason_use }
  | EValueUsedAsType { reason_use } -> EValueUsedAsType { reason_use = map_reason reason_use }
  | EPolarityMismatch { reason; name; expected_polarity; actual_polarity } ->
    EPolarityMismatch { reason = map_reason reason; name; expected_polarity; actual_polarity }
  | EComparison (r1, r2) -> EComparison (map_reason r1, map_reason r2)
  | ENonStrictEqualityComparison (r1, r2) ->
    ENonStrictEqualityComparison (map_reason r1, map_reason r2)
  | EEscapedGeneric { reason; blame_reason; annot_reason; use_op; bound_name; bound_loc; is_this }
    ->
    EEscapedGeneric
      {
        reason = map_reason reason;
        blame_reason = map_reason blame_reason;
        annot_reason = Base.Option.map ~f:map_reason annot_reason;
        use_op = map_use_op use_op;
        bound_loc = f bound_loc;
        bound_name;
        is_this;
      }
  | ESpeculationAmbiguous
      { reason; prev_case = (prev_i, prev_case_reason); case = (i, case_reason); cases } ->
    ESpeculationAmbiguous
      {
        reason = map_reason reason;
        prev_case = (prev_i, map_reason prev_case_reason);
        case = (i, map_reason case_reason);
        cases = Base.List.map ~f:map_reason cases;
      }
  | EUnsupportedExact (r1, r2) -> EUnsupportedExact (map_reason r1, map_reason r2)
  | EIdxArity r -> EIdxArity (map_reason r)
  | EIdxUse r -> EIdxUse (map_reason r)
  | EUnexpectedThisType loc -> EUnexpectedThisType (f loc)
  | ETypeParamArity (loc, i) -> ETypeParamArity (f loc, i)
  | ECallTypeArity { call_loc; is_new; reason_arity; expected_arity } ->
    ECallTypeArity
      { call_loc = f call_loc; is_new; expected_arity; reason_arity = map_reason reason_arity }
  | ETypeParamMinArity (loc, i) -> ETypeParamMinArity (f loc, i)
  | ETooManyTypeArgs (r1, r2, i) -> ETooManyTypeArgs (map_reason r1, map_reason r2, i)
  | ETooFewTypeArgs (r1, r2, i) -> ETooFewTypeArgs (map_reason r1, map_reason r2, i)
  | EInvalidTypeArgs (r1, r2) -> EInvalidTypeArgs (map_reason r1, map_reason r2)
  | EInvalidExtends r -> EInvalidExtends (map_reason r)
  | EPropertyTypeAnnot loc -> EPropertyTypeAnnot (f loc)
  | EExportsAnnot loc -> EExportsAnnot (f loc)
  | ECharSetAnnot loc -> ECharSetAnnot (f loc)
  | EUnsupportedKeyInObjectType loc -> EUnsupportedKeyInObjectType (f loc)
  | EPredAnnot loc -> EPredAnnot (f loc)
  | ERefineAnnot loc -> ERefineAnnot (f loc)
  | ETrustedAnnot loc -> ETrustedAnnot (f loc)
  | EPrivateAnnot loc -> EPrivateAnnot (f loc)
  | EFunPredCustom ((r1, r2), s) -> EFunPredCustom ((map_reason r1, map_reason r2), s)
  | EInternal (loc, i) -> EInternal (f loc, i)
  | EUnsupportedSyntax (loc, u) -> EUnsupportedSyntax (f loc, map_unsupported_syntax u)
  | EUseArrayLiteral loc -> EUseArrayLiteral (f loc)
  | EMissingAnnotation (r, rs) -> EMissingAnnotation (map_reason r, Base.List.map ~f:map_reason rs)
  | EMissingLocalAnnotation { reason; hint_available; from_generic_function } ->
    EMissingLocalAnnotation { reason = map_reason reason; hint_available; from_generic_function }
  | EBindingError (b, loc, s, scope) -> EBindingError (b, f loc, s, scope)
  | ERecursionLimit (r1, r2) -> ERecursionLimit (map_reason r1, map_reason r2)
  | EUnsafeGetSet loc -> EUnsafeGetSet (f loc)
  | EUninitializedInstanceProperty (loc, e) -> EUninitializedInstanceProperty (f loc, e)
  | EEnumsNotEnabled loc -> EEnumsNotEnabled (f loc)
  | EIndeterminateModuleType loc -> EIndeterminateModuleType (f loc)
  | EBadExportPosition loc -> EBadExportPosition (f loc)
  | EBadExportContext (s, loc) -> EBadExportContext (s, f loc)
  | EBadDefaultImportAccess (loc, r) -> EBadDefaultImportAccess (f loc, map_reason r)
  | EBadDefaultImportDestructuring loc -> EBadDefaultImportDestructuring (f loc)
  | EInvalidImportStarUse (loc, r) -> EInvalidImportStarUse (f loc, map_reason r)
  | ENonConstVarExport (loc, r) -> ENonConstVarExport (f loc, Base.Option.map ~f:map_reason r)
  | EThisInExportedFunction loc -> EThisInExportedFunction (f loc)
  | EMixedImportAndRequire (loc, r) -> EMixedImportAndRequire (f loc, map_reason r)
  | EToplevelLibraryImport loc -> EToplevelLibraryImport (f loc)
  | EExportRenamedDefault { loc; name; is_reexport } ->
    EExportRenamedDefault { loc = f loc; name; is_reexport }
  | EUnreachable loc -> EUnreachable (f loc)
  | EInvalidTypeof (loc, s) -> EInvalidTypeof (f loc, s)
  | EBinaryInLHS r -> EBinaryInLHS (map_reason r)
  | EBinaryInRHS r -> EBinaryInRHS (map_reason r)
  | EArithmeticOperand r -> EArithmeticOperand (map_reason r)
  | EForInRHS r -> EForInRHS (map_reason r)
  | EInstanceofRHS r -> EInstanceofRHS (map_reason r)
  | EObjectComputedPropertyAccess (r1, r2) ->
    EObjectComputedPropertyAccess (map_reason r1, map_reason r2)
  | EObjectComputedPropertyAssign (r1, r2) ->
    EObjectComputedPropertyAssign (map_reason r1, map_reason r2)
  | EInvalidLHSInAssignment l -> EInvalidLHSInAssignment (f l)
  | EUnsupportedImplements r -> EUnsupportedImplements (map_reason r)
  | EReactElementFunArity (r, s, i) -> EReactElementFunArity (map_reason r, s, i)
  | EUnsupportedSetProto r -> EUnsupportedSetProto (map_reason r)
  | EDuplicateModuleProvider { module_name; provider; conflict } ->
    EDuplicateModuleProvider { module_name; provider = f provider; conflict = f conflict }
  | EParseError (loc, p) -> EParseError (f loc, p)
  | EDocblockError (loc, e) -> EDocblockError (f loc, e)
  | EImplicitInexactObject loc -> EImplicitInexactObject (f loc)
  | EAmbiguousObjectType loc -> EAmbiguousObjectType (f loc)
  | EUntypedTypeImport (loc, s) -> EUntypedTypeImport (f loc, s)
  | EUntypedImport (loc, s) -> EUntypedImport (f loc, s)
  | ENonstrictImport loc -> ENonstrictImport (f loc)
  | EUnclearType loc -> EUnclearType (f loc)
  | EDeprecatedBool loc -> EDeprecatedBool (f loc)
  | EDeprecatedType loc -> EDeprecatedType (f loc)
  | EUnsafeGettersSetters loc -> EUnsafeGettersSetters (f loc)
  | EUnusedSuppression loc -> EUnusedSuppression (f loc)
  | ECodelessSuppression (loc, c) -> ECodelessSuppression (f loc, c)
  | ELintSetting (loc, err) -> ELintSetting (f loc, err)
  | ESketchyNullLint { kind; loc; null_loc; falsy_loc } ->
    ESketchyNullLint { kind; loc = f loc; null_loc = f null_loc; falsy_loc = f falsy_loc }
  | ESketchyNumberLint (kind, r) -> ESketchyNumberLint (kind, map_reason r)
  | EInvalidPrototype (loc, r) -> EInvalidPrototype (f loc, map_reason r)
  | EUnnecessaryOptionalChain (loc, r) -> EUnnecessaryOptionalChain (f loc, map_reason r)
  | EUnnecessaryInvariant (loc, r) -> EUnnecessaryInvariant (f loc, map_reason r)
  | EUnexpectedTemporaryBaseType loc -> EUnexpectedTemporaryBaseType (f loc)
  | ECannotDelete (l1, r1) -> ECannotDelete (f l1, map_reason r1)
  | ESignatureVerification sve -> ESignatureVerification (Signature_error.map f sve)
  | ECannotSpreadInterface { spread_reason; interface_reason; use_op } ->
    ECannotSpreadInterface
      {
        spread_reason = map_reason spread_reason;
        interface_reason = map_reason interface_reason;
        use_op = map_use_op use_op;
      }
  | ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason; use_op } ->
    ECannotSpreadIndexerOnRight
      {
        spread_reason = map_reason spread_reason;
        object_reason = map_reason object_reason;
        key_reason = map_reason key_reason;
        use_op = map_use_op use_op;
      }
  | EUnableToSpread { spread_reason; object1_reason; object2_reason; propname; error_kind; use_op }
    ->
    EUnableToSpread
      {
        spread_reason = map_reason spread_reason;
        object1_reason = map_reason object1_reason;
        object2_reason = map_reason object2_reason;
        propname;
        error_kind;
        use_op = map_use_op use_op;
      }
  | EInexactMayOverwriteIndexer { spread_reason; key_reason; value_reason; object2_reason; use_op }
    ->
    EInexactMayOverwriteIndexer
      {
        spread_reason = map_reason spread_reason;
        key_reason = map_reason key_reason;
        value_reason = map_reason value_reason;
        object2_reason = map_reason object2_reason;
        use_op = map_use_op use_op;
      }
  | EExponentialSpread { reason; reasons_for_operand1; reasons_for_operand2 } ->
    EExponentialSpread
      {
        reason = map_reason reason;
        reasons_for_operand1 =
          map_loc_of_exponential_spread_reason_group map_reason reasons_for_operand1;
        reasons_for_operand2 =
          map_loc_of_exponential_spread_reason_group map_reason reasons_for_operand2;
      }
  | EComputedPropertyWithMultipleLowerBounds
      { computed_property_reason; new_lower_bound_reason; existing_lower_bound_reason } ->
    EComputedPropertyWithMultipleLowerBounds
      {
        computed_property_reason = map_reason computed_property_reason;
        new_lower_bound_reason = map_reason new_lower_bound_reason;
        existing_lower_bound_reason = map_reason existing_lower_bound_reason;
      }
  | EComputedPropertyWithUnion { computed_property_reason; union_reason } ->
    EComputedPropertyWithUnion
      {
        computed_property_reason = map_reason computed_property_reason;
        union_reason = map_reason union_reason;
      }
  | EEnumInvalidMemberAccess { member_name; suggestion; reason; enum_reason } ->
    EEnumInvalidMemberAccess
      { member_name; suggestion; reason = map_reason reason; enum_reason = map_reason enum_reason }
  | EEnumModification { loc; enum_reason } ->
    EEnumModification { loc = f loc; enum_reason = map_reason enum_reason }
  | EEnumMemberDuplicateValue { loc; prev_use_loc; enum_reason } ->
    EEnumMemberDuplicateValue
      { loc = f loc; prev_use_loc = f prev_use_loc; enum_reason = map_reason enum_reason }
  | EEnumInvalidObjectUtil { reason; enum_reason } ->
    EEnumInvalidObjectUtil { reason = map_reason reason; enum_reason = map_reason enum_reason }
  | EEnumNotIterable { reason; for_in } -> EEnumNotIterable { reason = map_reason reason; for_in }
  | EEnumMemberAlreadyChecked { reason; prev_check_reason; enum_reason; member_name } ->
    EEnumMemberAlreadyChecked
      {
        reason = map_reason reason;
        prev_check_reason = map_reason prev_check_reason;
        enum_reason = map_reason enum_reason;
        member_name;
      }
  | EEnumAllMembersAlreadyChecked { reason; enum_reason } ->
    EEnumAllMembersAlreadyChecked
      { reason = map_reason reason; enum_reason = map_reason enum_reason }
  | EEnumNotAllChecked { reason; enum_reason; left_to_check; default_case } ->
    EEnumNotAllChecked
      {
        reason = map_reason reason;
        enum_reason = map_reason enum_reason;
        left_to_check;
        default_case = Option.map map_reason default_case;
      }
  | EEnumUnknownNotChecked { reason; enum_reason } ->
    EEnumUnknownNotChecked { reason = map_reason reason; enum_reason = map_reason enum_reason }
  | EEnumInvalidCheck { reason; enum_reason; example_member } ->
    EEnumInvalidCheck
      { reason = map_reason reason; enum_reason = map_reason enum_reason; example_member }
  | EEnumMemberUsedAsType { reason; enum_reason } ->
    EEnumMemberUsedAsType { reason = map_reason reason; enum_reason = map_reason enum_reason }
  | EEnumIncompatible { use_op; reason_lower; reason_upper; representation_type } ->
    EEnumIncompatible
      {
        use_op = map_use_op use_op;
        reason_lower = map_reason reason_lower;
        reason_upper = map_reason reason_upper;
        representation_type;
      }
  | EAssignConstLikeBinding { loc; definition; binding_kind } ->
    EAssignConstLikeBinding { loc = f loc; definition = map_reason definition; binding_kind }
  | ECannotResolveOpenTvar { use_op; reason; blame_reasons } ->
    ECannotResolveOpenTvar
      {
        use_op = map_use_op use_op;
        reason = map_reason reason;
        blame_reasons = Base.List.map ~f:map_reason blame_reasons;
      }
  | EMalformedCode loc -> EMalformedCode (f loc)
  | EImplicitInstantiationTemporaryError (loc, msg) ->
    EImplicitInstantiationTemporaryError (f loc, msg)
  | EImportInternalReactServerModule loc -> EImportInternalReactServerModule (f loc)
  | EImplicitInstantiationUnderconstrainedError { reason_call; reason_tparam; bound; use_op } ->
    EImplicitInstantiationUnderconstrainedError
      {
        reason_call = map_reason reason_call;
        reason_tparam = map_reason reason_tparam;
        bound;
        use_op = map_use_op use_op;
      }
  | EImplicitInstantiationWidenedError { reason_call; bound } ->
    EImplicitInstantiationWidenedError { reason_call = map_reason reason_call; bound }
  | EClassToObject (r1, r2, op) -> EClassToObject (map_reason r1, map_reason r2, map_use_op op)
  | EMethodUnbinding { use_op; reason_op; reason_prop } ->
    EMethodUnbinding
      {
        use_op = map_use_op use_op;
        reason_op = map_reason reason_op;
        reason_prop = map_reason reason_prop;
      }
  | EObjectThisReference (loc, r) -> EObjectThisReference (f loc, map_reason r)
  | EInvalidDeclaration { declaration; null_write } ->
    EInvalidDeclaration
      {
        declaration = map_reason declaration;
        null_write =
          Base.Option.map
            ~f:(fun ({ null_loc; _ } as nw) -> { nw with null_loc = f null_loc })
            null_write;
      }
  | EInvalidGraphQL (loc, err) -> EInvalidGraphQL (f loc, err)
  | EAnnotationInference (loc, r1, r2, suggestion) ->
    EAnnotationInference (f loc, map_reason r1, map_reason r2, suggestion)
  | EAnnotationInferenceRecursive (loc, r) -> EAnnotationInferenceRecursive (f loc, map_reason r)
  | EDefinitionCycle elts ->
    let open Env_api in
    EDefinitionCycle
      (Nel.map
         (fun (reason, recur, annot) ->
           ( map_reason reason,
             Base.List.map ~f recur,
             Base.List.map
               ~f:(function
                 | Loc l -> Loc (f l)
                 | Object { loc; props } -> Object { loc = f loc; props = Base.List.map ~f props })
               annot
           ))
         elts
      )
  | ERecursiveDefinition { reason; recursion; annot_locs } ->
    let open Env_api in
    ERecursiveDefinition
      {
        reason = map_reason reason;
        annot_locs =
          Base.List.map
            ~f:(function
              | Loc l -> Loc (f l)
              | Object { loc; props } -> Object { loc = f loc; props = Base.List.map ~f props })
            annot_locs;
        recursion = Base.List.map ~f recursion;
      }
  | EDuplicateClassMember { loc; name; static } ->
    EDuplicateClassMember { loc = f loc; name; static }
  | EEmptyArrayNoProvider { loc } -> EEmptyArrayNoProvider { loc = f loc }
  | EUnusedPromise { loc } -> EUnusedPromise { loc = f loc }
  | EBigIntRShift3 r -> EBigIntRShift3 (map_reason r)
  | EBigIntNumCoerce r -> EBigIntNumCoerce (map_reason r)
  | EInvalidCatchParameterAnnotation loc -> EInvalidCatchParameterAnnotation (f loc)
  | ETSSyntax { kind; loc } -> ETSSyntax { kind; loc = f loc }
  | EInvalidBinaryArith { reason_out; reason_l; reason_r; kind } ->
    EInvalidBinaryArith
      {
        reason_out = map_reason reason_out;
        reason_l = map_reason reason_l;
        reason_r = map_reason reason_r;
        kind;
      }

let desc_of_reason r = Reason.desc_of_reason ~unwrap:(is_scalar_reason r) r

(* A utility function for getting and updating the use_op in error messages. *)
let util_use_op_of_msg nope util = function
  | EIncompatible { use_op; lower; upper; branches } ->
    Base.Option.value_map use_op ~default:nope ~f:(fun use_op ->
        util use_op (fun use_op -> EIncompatible { use_op = Some use_op; lower; upper; branches })
    )
  | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
    util use_op (fun use_op -> EIncompatibleDefs { use_op; reason_lower; reason_upper; branches })
  | EIncompatibleProp { use_op; prop; reason_prop; reason_obj; special } ->
    Base.Option.value_map use_op ~default:nope ~f:(fun use_op ->
        util use_op (fun use_op ->
            EIncompatibleProp { use_op = Some use_op; prop; reason_prop; reason_obj; special }
        )
    )
  | ETrustIncompatibleWithUseOp (rl, ru, op) ->
    util op (fun op -> ETrustIncompatibleWithUseOp (rl, ru, op))
  | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedStringLit { reason_lower; reason_upper; use_op })
  | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedNumberLit { reason_lower; reason_upper; use_op })
  | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedBooleanLit { reason_lower; reason_upper; use_op })
  | EExpectedBigIntLit { reason_lower; reason_upper; use_op } ->
    util use_op (fun use_op -> EExpectedBigIntLit { reason_lower; reason_upper; use_op })
  | EPropNotFound { prop_name = prop; reason_prop; reason_obj; use_op; suggestion } ->
    util use_op (fun use_op ->
        EPropNotFound { prop_name = prop; reason_prop; reason_obj; use_op; suggestion }
    )
  | EPropNotReadable { reason_prop; prop_name; use_op } ->
    util use_op (fun use_op -> EPropNotReadable { reason_prop; prop_name; use_op })
  | EPropNotWritable { reason_prop; prop_name; use_op } ->
    util use_op (fun use_op -> EPropNotWritable { reason_prop; prop_name; use_op })
  | EPropPolarityMismatch (rs, p, ps, op) ->
    util op (fun op -> EPropPolarityMismatch (rs, p, ps, op))
  | EStrictLookupFailed { reason_prop; reason_obj; name; suggestion; use_op = Some op } ->
    util op (fun op ->
        EStrictLookupFailed { reason_prop; reason_obj; name; suggestion; use_op = Some op }
    )
  | EPrivateLookupFailed (rs, x, op) -> util op (fun op -> EPrivateLookupFailed (rs, x, op))
  | EAdditionMixed (r, op) -> util op (fun op -> EAdditionMixed (r, op))
  | ETupleArityMismatch (rs, x, y, op) -> util op (fun op -> ETupleArityMismatch (rs, x, y, op))
  | ENonLitArrayToTuple (rs, op) -> util op (fun op -> ENonLitArrayToTuple (rs, op))
  | ETupleOutOfBounds { use_op; reason; reason_op; length; index } ->
    util use_op (fun use_op -> ETupleOutOfBounds { use_op; reason; reason_op; length; index })
  | ETupleNonIntegerIndex { use_op; reason; index } ->
    util use_op (fun use_op -> ETupleNonIntegerIndex { use_op; reason; index })
  | ETupleUnsafeWrite { reason; use_op } ->
    util use_op (fun use_op -> ETupleUnsafeWrite { reason; use_op })
  | ETupleElementNotReadable { reason; index; name; use_op } ->
    util use_op (fun use_op -> ETupleElementNotReadable { reason; index; name; use_op })
  | ETupleElementNotWritable { reason; index; name; use_op } ->
    util use_op (fun use_op -> ETupleElementNotWritable { reason; index; name; use_op })
  | ETupleElementPolarityMismatch
      { index; reason_lower; polarity_lower; reason_upper; polarity_upper; use_op } ->
    util use_op (fun use_op ->
        ETupleElementPolarityMismatch
          { index; reason_lower; polarity_lower; reason_upper; polarity_upper; use_op }
    )
  | EROArrayWrite (rs, op) -> util op (fun op -> EROArrayWrite (rs, op))
  | EUnionSpeculationFailed { use_op; reason; reason_op; branches } ->
    util use_op (fun use_op -> EUnionSpeculationFailed { use_op; reason; reason_op; branches })
  | EIncompatibleWithExact (rs, op, kind) ->
    util op (fun op -> EIncompatibleWithExact (rs, op, kind))
  | EFunctionIncompatibleWithIndexer (rs, op) ->
    util op (fun op -> EFunctionIncompatibleWithIndexer (rs, op))
  | EInvalidCharSet { invalid; valid; use_op } ->
    util use_op (fun use_op -> EInvalidCharSet { invalid; valid; use_op })
  | EIncompatibleWithShape (l, u, use_op) ->
    util use_op (fun use_op -> EIncompatibleWithShape (l, u, use_op))
  | EInvalidObjectKit { reason; reason_op; use_op } ->
    util use_op (fun use_op -> EInvalidObjectKit { reason; reason_op; use_op })
  | EIncompatibleWithUseOp ({ use_op; _ } as contents) ->
    util use_op (fun use_op -> EIncompatibleWithUseOp { contents with use_op })
  | EEnumIncompatible ({ use_op; _ } as contents) ->
    util use_op (fun use_op -> EEnumIncompatible { contents with use_op })
  | ENotAReactComponent { reason; use_op } ->
    util use_op (fun use_op -> ENotAReactComponent { reason; use_op })
  | EInvalidReactConfigType { reason; use_op } ->
    util use_op (fun use_op -> EInvalidReactConfigType { reason; use_op })
  | EInvalidReactPropType { reason; use_op; tool } ->
    util use_op (fun use_op -> EInvalidReactPropType { reason; use_op; tool })
  | EFunctionCallExtraArg (rl, ru, n, op) ->
    util op (fun op -> EFunctionCallExtraArg (rl, ru, n, op))
  | ECannotSpreadInterface { spread_reason; interface_reason; use_op } ->
    util use_op (fun use_op -> ECannotSpreadInterface { spread_reason; interface_reason; use_op })
  | ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason; use_op } ->
    util use_op (fun use_op ->
        ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason; use_op }
    )
  | EUnableToSpread { spread_reason; object1_reason; object2_reason; propname; error_kind; use_op }
    ->
    util use_op (fun use_op ->
        EUnableToSpread
          { spread_reason; object1_reason; object2_reason; propname; error_kind; use_op }
    )
  | EInexactMayOverwriteIndexer { spread_reason; key_reason; value_reason; object2_reason; use_op }
    ->
    util use_op (fun use_op ->
        EInexactMayOverwriteIndexer
          { spread_reason; key_reason; value_reason; object2_reason; use_op }
    )
  | ECannotResolveOpenTvar { use_op; reason; blame_reasons } ->
    util use_op (fun use_op -> ECannotResolveOpenTvar { use_op; reason; blame_reasons })
  | EEscapedGeneric { reason; blame_reason; annot_reason; use_op; bound_name; bound_loc; is_this }
    ->
    util use_op (fun use_op ->
        EEscapedGeneric
          { reason; blame_reason; annot_reason; use_op; bound_loc; bound_name; is_this }
    )
  | EImplicitInstantiationUnderconstrainedError { reason_call; reason_tparam; bound; use_op } ->
    util use_op (fun use_op ->
        EImplicitInstantiationUnderconstrainedError { reason_call; reason_tparam; bound; use_op }
    )
  | EDebugPrint (_, _)
  | EExportValueAsType (_, _)
  | EImportValueAsType (_, _)
  | EImportTypeAsTypeof (_, _)
  | EImportTypeAsValue (_, _)
  | ERefineAsValue (_, _)
  | ENoDefaultExport (_, _, _)
  | EOnlyDefaultExport (_, _, _)
  | ENoNamedExport (_, _, _, _)
  | EMissingTypeArgs
      { reason_op = _; reason_tapp = _; reason_arity = _; min_arity = _; max_arity = _ }
  | EAnyValueUsedAsType _
  | EValueUsedAsType _
  | EPolarityMismatch { reason = _; name = _; expected_polarity = _; actual_polarity = _ }
  | EBuiltinLookupFailed _
  | EStrictLookupFailed { use_op = None; _ }
  | EComparison (_, _)
  | ENonStrictEqualityComparison _
  | ESpeculationAmbiguous _
  | EUnsupportedExact (_, _)
  | EIdxArity _
  | EIdxUse _
  | EUnexpectedThisType _
  | ETypeParamArity (_, _)
  | ECallTypeArity _
  | ETypeParamMinArity (_, _)
  | ETooManyTypeArgs (_, _, _)
  | ETooFewTypeArgs (_, _, _)
  | EInvalidTypeArgs (_, _)
  | EInvalidExtends _
  | EPropertyTypeAnnot _
  | EExportsAnnot _
  | ECharSetAnnot _
  | EUnsupportedKeyInObjectType _
  | EPredAnnot _
  | ERefineAnnot _
  | ETrustedAnnot _
  | EPrivateAnnot _
  | EFunPredCustom (_, _)
  | EInternal (_, _)
  | EUnsupportedSyntax (_, _)
  | EUseArrayLiteral _
  | EMissingAnnotation _
  | EMissingLocalAnnotation _
  | EBindingError (_, _, _, _)
  | ERecursionLimit (_, _)
  | EUnsafeGetSet _
  | EUninitializedInstanceProperty _
  | EEnumsNotEnabled _
  | EIndeterminateModuleType _
  | EBadExportPosition _
  | EBadExportContext _
  | EBadDefaultImportAccess _
  | EBadDefaultImportDestructuring _
  | EInvalidImportStarUse _
  | ENonConstVarExport _
  | EThisInExportedFunction _
  | EMixedImportAndRequire _
  | EToplevelLibraryImport _
  | EExportRenamedDefault _
  | EUnreachable _
  | EInvalidTypeof (_, _)
  | EBinaryInLHS _
  | EBinaryInRHS _
  | EArithmeticOperand _
  | EForInRHS _
  | EInstanceofRHS _
  | EObjectComputedPropertyAccess (_, _)
  | EObjectComputedPropertyAssign (_, _)
  | EInvalidConstructor _
  | EInvalidConstructorDefinition _
  | EInvalidLHSInAssignment _
  | EUnsupportedImplements _
  | EReactElementFunArity (_, _, _)
  | EUnsupportedSetProto _
  | EDuplicateModuleProvider { module_name = _; provider = _; conflict = _ }
  | EParseError (_, _)
  | EDocblockError (_, _)
  | EImplicitInexactObject _
  | EAmbiguousObjectType _
  | EUntypedTypeImport (_, _)
  | EUntypedImport (_, _)
  | ENonstrictImport _
  | EUnclearType _
  | EDeprecatedBool _
  | EDeprecatedType _
  | EUnsafeGettersSetters _
  | EUnusedSuppression _
  | ECodelessSuppression _
  | ELintSetting _
  | ESketchyNullLint { kind = _; loc = _; null_loc = _; falsy_loc = _ }
  | ESketchyNumberLint _
  | EInvalidPrototype _
  | EUnnecessaryOptionalChain _
  | EUnnecessaryInvariant _
  | EUnexpectedTemporaryBaseType _
  | ECannotDelete _
  | ESignatureVerification _
  | EExponentialSpread _
  | EComputedPropertyWithMultipleLowerBounds _
  | EComputedPropertyWithUnion _
  | EEnumInvalidMemberAccess _
  | EEnumModification _
  | EEnumMemberDuplicateValue _
  | EEnumInvalidObjectUtil _
  | EEnumNotIterable _
  | EEnumMemberAlreadyChecked _
  | EEnumAllMembersAlreadyChecked _
  | EEnumNotAllChecked _
  | EEnumUnknownNotChecked _
  | EEnumInvalidCheck _
  | EEnumMemberUsedAsType _
  | EAssignConstLikeBinding _
  | EMalformedCode _
  | EImplicitInstantiationTemporaryError _
  | EImportInternalReactServerModule _
  | EImplicitInstantiationWidenedError _
  | EClassToObject _
  | EMethodUnbinding _
  | EObjectThisReference _
  | EInvalidDeclaration _
  | EInvalidGraphQL _
  | EDefinitionCycle _
  | ERecursiveDefinition _
  | EAnnotationInference _
  | EAnnotationInferenceRecursive _
  | EDuplicateClassMember _
  | EEmptyArrayNoProvider _
  | EUnusedPromise _
  | EBigIntRShift3 _
  | EBigIntNumCoerce _
  | EInvalidCatchParameterAnnotation _
  | ETSSyntax _
  | EInvalidBinaryArith _ ->
    nope

(* Not all messages (i.e. those whose locations are based on use_ops) have locations that can be
   determined while locations are abstract. We just return None in this case. *)
let loc_of_msg : 'loc t' -> 'loc option = function
  | EAnyValueUsedAsType { reason_use = primary }
  | EValueUsedAsType { reason_use = primary }
  | EComparison (primary, _)
  | ENonStrictEqualityComparison (primary, _)
  | EFunPredCustom ((primary, _), _)
  | EInvalidTypeArgs (_, primary)
  | ETooFewTypeArgs (primary, _, _)
  | ETooManyTypeArgs (primary, _, _) ->
    Some (poly_loc_of_reason primary)
  | ESketchyNumberLint (_, reason)
  | EInvalidExtends reason
  | EUnsupportedSetProto reason
  | EReactElementFunArity (reason, _, _)
  | EUnsupportedImplements reason
  | EObjectComputedPropertyAssign (_, reason)
  | EObjectComputedPropertyAccess (_, reason)
  | EForInRHS reason
  | EBinaryInRHS reason
  | EBinaryInLHS reason
  | EInstanceofRHS reason
  | EArithmeticOperand reason
  | ERecursionLimit (reason, _)
  | EMissingAnnotation (reason, _)
  | EMissingLocalAnnotation { reason; _ }
  | EIdxArity reason
  | EIdxUse reason
  | EUnsupportedExact (_, reason)
  | EPolarityMismatch { reason; _ }
  | ENoNamedExport (reason, _, _, _)
  | EOnlyDefaultExport (reason, _, _)
  | ENoDefaultExport (reason, _, _)
  | ERefineAsValue (reason, _)
  | EImportTypeAsValue (reason, _)
  | EImportTypeAsTypeof (reason, _)
  | EExportValueAsType (reason, _)
  | EImportValueAsType (reason, _)
  | EDebugPrint (reason, _)
  | EComputedPropertyWithMultipleLowerBounds
      {
        computed_property_reason = reason;
        new_lower_bound_reason = _;
        existing_lower_bound_reason = _;
      }
  | EComputedPropertyWithUnion { computed_property_reason = reason; union_reason = _ } ->
    Some (poly_loc_of_reason reason)
  | EEnumMemberAlreadyChecked { reason; _ }
  | EEnumAllMembersAlreadyChecked { reason; _ }
  | EEnumNotAllChecked { reason; _ }
  | EEnumUnknownNotChecked { reason; _ }
  | EEnumInvalidCheck { reason; _ }
  | EEnumMemberUsedAsType { reason; _ }
  | EEnumInvalidMemberAccess { reason; _ }
  | EEnumInvalidObjectUtil { reason; _ }
  | EEnumNotIterable { reason; _ }
  | ERecursiveDefinition { reason; _ }
  | EDefinitionCycle ((reason, _, _), _)
  | EInvalidConstructor reason
  | EInvalidDeclaration { declaration = reason; _ }
  | EBigIntRShift3 reason
  | EBigIntNumCoerce reason
  | EInvalidBinaryArith { reason_out = reason; _ } ->
    Some (poly_loc_of_reason reason)
  | EExponentialSpread
      {
        reason = _;
        reasons_for_operand1 =
          { first_reason = first_reason_group1; second_reason = second_reason_group1 };
        reasons_for_operand2 =
          { first_reason = first_reason_group2; second_reason = second_reason_group2 };
      } ->
    (* Ideally, we have an actual annotated union in here somewhere. This function tries to find
     * it, otherwise our primary location will be around the first reason in the list of reasons
     * for the first spread operand.
     *
     * It's important that we don't position around the location of the spread because that
     * may be a polymorphic type variable.
     *
     * TODO (jmbrown): Maybe we should have two separate errors here-- one for type spread and
     * one for value spread. It's always safe to position the error around the value spread.
     * The same is true for all of the other spread errors.
     *)
    let union_reason =
      match (second_reason_group1, second_reason_group2) with
      | (None, _) -> first_reason_group1
      | (_, None) -> first_reason_group2
      | (Some r, _) -> r
    in
    Some (poly_loc_of_reason union_reason)
  | EInvalidPrototype (loc, _)
  | EUntypedTypeImport (loc, _)
  | EUntypedImport (loc, _)
  | ENonstrictImport loc
  | EUnclearType loc
  | EDeprecatedBool loc
  | EDeprecatedType loc
  | EUnsafeGettersSetters loc
  | EUnnecessaryOptionalChain (loc, _)
  | EUnnecessaryInvariant (loc, _)
  | EUnusedSuppression loc
  | ECodelessSuppression (loc, _)
  | EDocblockError (loc, _)
  | EImplicitInexactObject loc
  | EAmbiguousObjectType loc
  | EParseError (loc, _)
  | EInvalidLHSInAssignment loc
  | EInvalidTypeof (loc, _)
  | EUnreachable loc
  | EUnexpectedTemporaryBaseType loc
  | ECannotDelete (loc, _)
  | EBadExportContext (_, loc)
  | EBadExportPosition loc
  | EBadDefaultImportAccess (loc, _)
  | EBadDefaultImportDestructuring loc
  | EInvalidImportStarUse (loc, _)
  | ENonConstVarExport (loc, _)
  | EThisInExportedFunction loc
  | EMixedImportAndRequire (loc, _)
  | EToplevelLibraryImport loc
  | EExportRenamedDefault { loc; _ }
  | EIndeterminateModuleType loc
  | EEnumsNotEnabled loc
  | EUnsafeGetSet loc
  | EUninitializedInstanceProperty (loc, _)
  | EUseArrayLiteral loc
  | EInvalidConstructorDefinition { loc; _ }
  | EUnsupportedSyntax (loc, _)
  | EInternal (loc, _)
  | EPrivateAnnot loc
  | ETrustedAnnot loc
  | ERefineAnnot loc
  | EPredAnnot loc
  | EUnsupportedKeyInObjectType loc
  | ECharSetAnnot loc
  | EExportsAnnot loc
  | EPropertyTypeAnnot loc
  | EUnexpectedThisType loc
  | ETypeParamMinArity (loc, _)
  | EAssignConstLikeBinding { loc; _ }
  | EMalformedCode loc
  | EImplicitInstantiationTemporaryError (loc, _)
  | EObjectThisReference (loc, _)
  | EImportInternalReactServerModule loc
  | EInvalidGraphQL (loc, _)
  | EAnnotationInference (loc, _, _, _)
  | EAnnotationInferenceRecursive (loc, _)
  | EInvalidCatchParameterAnnotation loc
  | ETSSyntax { loc; _ } ->
    Some loc
  | EImplicitInstantiationWidenedError { reason_call; _ } -> Some (poly_loc_of_reason reason_call)
  | ELintSetting (loc, _) -> Some loc
  | ETypeParamArity (loc, _) -> Some loc
  | ESketchyNullLint { loc; _ } -> Some loc
  | ECallTypeArity { call_loc; _ } -> Some call_loc
  | EMissingTypeArgs { reason_op; _ } -> Some (poly_loc_of_reason reason_op)
  | ESignatureVerification sve ->
    Signature_error.(
      (match sve with
      | ExpectedAnnotation (loc, _)
      | UnexpectedObjectKey (loc, _)
      | UnexpectedArraySpread (loc, _)
      | UnexpectedArrayHole loc
      | EmptyArray loc
      | EmptyObject loc
      | UnexpectedExpression (loc, _) ->
        Some loc)
    )
  | EDuplicateModuleProvider { conflict; _ } -> Some conflict
  | EBindingError (_, loc, _, _) -> Some loc
  | EEnumModification { loc; _ } -> Some loc
  | EEnumMemberDuplicateValue { loc; _ } -> Some loc
  | ESpeculationAmbiguous { reason; _ } -> Some (poly_loc_of_reason reason)
  | EBuiltinLookupFailed { reason; _ } -> Some (poly_loc_of_reason reason)
  | EDuplicateClassMember { loc; _ } -> Some loc
  | EEmptyArrayNoProvider { loc } -> Some loc
  | EUnusedPromise { loc } -> Some loc
  | EUnableToSpread _
  | ECannotSpreadInterface _
  | ECannotSpreadIndexerOnRight _
  | EInexactMayOverwriteIndexer _
  | EFunctionCallExtraArg _
  | ENotAReactComponent _
  | EInvalidReactConfigType _
  | EInvalidReactPropType _
  | EIncompatibleWithUseOp _
  | ETrustIncompatibleWithUseOp _
  | EEnumIncompatible _
  | EIncompatibleDefs _
  | EInvalidObjectKit _
  | EIncompatibleWithShape _
  | EInvalidCharSet _
  | EIncompatibleWithExact _
  | EFunctionIncompatibleWithIndexer _
  | EUnionSpeculationFailed _
  | ETupleUnsafeWrite _
  | EROArrayWrite _
  | ETupleElementNotReadable _
  | ETupleElementNotWritable _
  | ETupleElementPolarityMismatch _
  | ETupleOutOfBounds _
  | ETupleNonIntegerIndex _
  | ENonLitArrayToTuple _
  | ETupleArityMismatch _
  | EAdditionMixed _
  | EPrivateLookupFailed _
  | EStrictLookupFailed _
  | EPropPolarityMismatch _
  | EPropNotReadable _
  | EPropNotWritable _
  | EPropNotFound _
  | EExpectedBooleanLit _
  | EExpectedNumberLit _
  | EExpectedStringLit _
  | EExpectedBigIntLit _
  | EEscapedGeneric _
  | EIncompatibleProp _
  | EIncompatible _
  | ECannotResolveOpenTvar _
  | EMethodUnbinding _
  | EImplicitInstantiationUnderconstrainedError _
  | EClassToObject _ ->
    None

let kind_of_msg =
  Errors.(
    function
    | EUntypedTypeImport _ -> LintError Lints.UntypedTypeImport
    | EUntypedImport _ -> LintError Lints.UntypedImport
    | ENonstrictImport _ -> LintError Lints.NonstrictImport
    | EUnclearType _ -> LintError Lints.UnclearType
    | EDeprecatedBool _ -> LintError Lints.(DeprecatedType DeprecatedBool)
    | EDeprecatedType _ -> LintError Lints.(DeprecatedType DeprecatedStar)
    | EUnsafeGettersSetters _ -> LintError Lints.UnsafeGettersSetters
    | ESketchyNullLint { kind; _ } -> LintError (Lints.SketchyNull kind)
    | ESketchyNumberLint (kind, _) -> LintError (Lints.SketchyNumber kind)
    | EUnnecessaryOptionalChain _ -> LintError Lints.UnnecessaryOptionalChain
    | EUnnecessaryInvariant _ -> LintError Lints.UnnecessaryInvariant
    | EImplicitInexactObject _ -> LintError Lints.ImplicitInexactObject
    | EAmbiguousObjectType _ -> LintError Lints.AmbiguousObjectType
    | EEnumNotAllChecked { default_case = Some _; _ } ->
      LintError Lints.RequireExplicitEnumSwitchCases
    | EUninitializedInstanceProperty _ -> LintError Lints.UninitializedInstanceProperty
    | EBadDefaultImportAccess _ -> LintError Lints.DefaultImportAccess
    | EBadDefaultImportDestructuring _ -> LintError Lints.DefaultImportAccess
    | EInvalidImportStarUse _ -> LintError Lints.InvalidImportStarUse
    | ENonConstVarExport _ -> LintError Lints.NonConstVarExport
    | EThisInExportedFunction _ -> LintError Lints.ThisInExportedFunction
    | EMixedImportAndRequire _ -> LintError Lints.MixedImportAndRequire
    | EExportRenamedDefault _ -> LintError Lints.ExportRenamedDefault
    | EUnusedPromise _ -> LintError Lints.UnusedPromiseInAsyncScope
    | EBadExportPosition _
    | EBadExportContext _ ->
      InferWarning ExportKind
    | EUnsafeGetSet _
    | EEnumsNotEnabled _
    | EIndeterminateModuleType _
    | EUnreachable _
    | EInvalidTypeof _ ->
      InferWarning OtherKind
    | EInternal _ -> InternalError
    | ERecursionLimit _ -> RecursionLimitError
    | EDuplicateModuleProvider _ -> DuplicateProviderError
    | EParseError _ -> ParseError
    | EDocblockError _
    | ELintSetting _ ->
      PseudoParseError
    | _ -> InferError
  )

let polarity_explanation = function
  | (Polarity.Positive, _) -> "read-only"
  | (Polarity.Negative, _) -> "write-only"
  | (Polarity.Neutral, Polarity.Negative) -> "readable"
  | (Polarity.Neutral, Polarity.Positive) -> "writable"
  | (Polarity.Neutral, Polarity.Neutral) -> failwith "unreachable"

let mk_prop_message =
  Errors.Friendly.(
    function
    | None
    (* TODO the $-prefixed names should be internal *)
    | Some ("$key" | "$value") ->
      [text "an index signature declaring the expected key / value type"]
    | Some "$call" -> [text "a call signature declaring the expected parameter / return type"]
    | Some prop -> [text "property "; code prop]
  )

let mk_tuple_element_error_message ~reason ~index ~name kind =
  let open Errors.Friendly in
  let index_ref = Reference ([Code (string_of_int index)], def_loc_of_reason reason) in
  let label =
    Base.Option.value_map name ~default:[] ~f:(fun name -> [text " labeled "; code name])
  in
  [text "tuple element at index "; index_ref] @ label @ [text " is not "; text kind]

let enum_name_of_reason reason =
  match desc_of_reason reason with
  | REnum name
  | RType (OrdinaryName name) ->
    Some name
  | _ -> None

let string_of_internal_error = function
  | AbnormalControlFlow -> "abnormal control flow"
  | UnconstrainedTvar None -> "unconstrained tvar during tvar resolution"
  | UnconstrainedTvar (Some i) -> spf "unconstrained tvar (%d) during tvar resolution" i
  | PlaceholderTypeInChecking -> "placeholder type in checking mode"
  | ReadOfUnreachedTvar k ->
    spf "read of %s entry which has not been prepared for typechecking" (Env_api.show_def_loc_type k)
  | ReadOfUnresolvedTvar k ->
    spf "read of %s entry from previous component is not FullyResolved" (Env_api.show_def_loc_type k)
  | MethodNotAFunction -> "expected function type"
  | OptionalMethod -> "optional methods are not supported"
  | PredFunWithoutParamNames -> "FunT -> FunT no params"
  | UnsupportedGuardPredicate pred -> spf "unsupported guard predicate (%s)" pred
  | PropertyDescriptorPropertyCannotBeRead -> "unexpected property in properties object"
  | ForInLHS -> "unexpected LHS in for...in"
  | ForOfLHS -> "unexpected LHS in for...of"
  | InstanceLookupComputed -> "unexpected computed property lookup on InstanceT"
  | PropRefComputedOpen -> "unexpected open computed property element type"
  | PropRefComputedLiteral -> "unexpected literal computed property element type"
  | RestParameterNotIdentifierPattern -> "unexpected rest parameter, expected an identifier pattern"
  | InterfaceTypeSpread -> "unexpected spread property in interface"
  | DebugThrow -> "debug throw"
  | ParseJobException exc -> "uncaught exception: " ^ Exception.to_string exc
  | CheckTimeout s -> spf "check job timed out after %0.2f seconds" s
  | CheckJobException exc -> "uncaught exception: " ^ Exception.to_string exc
  | UnexpectedTypeapp s -> "unexpected typeapp: " ^ s
  | UnexpectedAnnotationInference s -> "unexpected " ^ s ^ " in annotation inference"
  | MissingEnvRead l -> "missing env entry for read at " ^ ALoc.debug_to_string l
  | MissingEnvWrite loc -> "expected env entry for write location" ^ ALoc.debug_to_string loc
  | EnvInvariant (Env_api.NameDefOrderingFailure { all; roots; missing_roots }) ->
    let all = Base.List.map ~f:ALoc.debug_to_string all |> String.concat "," in
    let roots = Base.List.map ~f:ALoc.debug_to_string roots |> String.concat "," in
    let missing_roots = Base.List.map ~f:ALoc.debug_to_string missing_roots |> String.concat "," in
    spf
      "Please report this error to the Flow team: Env_api tarjan failure, all: { %s } roots: { %s } missing_roots: { %s }"
      all
      roots
      missing_roots
  | EnvInvariant (Env_api.Impossible str) ->
    "Internal state should be impossible, please report this to the Flow team: " ^ str
  | EnvInvariant (Env_api.ASTStructureOverride str) ->
    "AST visitor issue, please report this to the Flow team: " ^ str
  | EnvInvariant Env_api.NameDefGraphMismatch ->
    "EnvMap.find missed, please report this to the Flow team"
  | EnvInvariant Env_api.(MissingEnvEntry x) ->
    spf "Did not find %s in name_resolver environment, please report this to the Flow team" x
  | ImplicitInstantiationInvariant str ->
    "Implicit instantiation issue, please report this to the Flow team: " ^ str

(* Friendly messages are created differently based on the specific error they come from, so
   we collect the ingredients here and pass them to make_error_printable *)
type 'loc friendly_message_recipe =
  | IncompatibleUse of {
      loc: 'loc;
      upper_kind: 'loc upper_kind;
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | Speculation of {
      loc: 'loc;
      use_op: 'loc Type.virtual_use_op;
      branches: ('loc Reason.virtual_reason * 'loc t') list;
    }
  | Incompatible of {
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | IncompatibleTrust of {
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | IncompatibleEnum of {
      reason_lower: 'loc Reason.virtual_reason;
      reason_upper: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
      suggestion: 'loc Errors.Friendly.message_feature list;
    }
  | PropMissing of {
      loc: 'loc;
      prop: string option;
      suggestion: string option;
      reason_obj: 'loc Reason.virtual_reason;
      use_op: 'loc Type.virtual_use_op;
    }
  | Normal of { features: 'loc Errors.Friendly.message_feature list }
  | UseOp of {
      loc: 'loc;
      features: 'loc Errors.Friendly.message_feature list;
      use_op: 'loc Type.virtual_use_op;
    }
  | PropPolarityMismatch of {
      prop: string option;
      reason_lower: 'loc Reason.virtual_reason;
      polarity_lower: Polarity.t;
      reason_upper: 'loc Reason.virtual_reason;
      polarity_upper: Polarity.t;
      use_op: 'loc Type.virtual_use_op;
    }

let friendly_message_of_msg : Loc.t t' -> Loc.t friendly_message_recipe =
  let text = Errors.Friendly.text in
  let code = Errors.Friendly.code in
  let ref = Errors.Friendly.ref in
  let desc = Errors.Friendly.ref ~loc:false in
  let msg_export prefix export_name =
    if export_name = "default" then
      (text "", text "the default export")
    else
      (text prefix, code export_name)
  in
  let open Errors in
  function
  | EIncompatible
      { lower = (reason_lower, _); upper = (reason_upper, upper_kind); use_op; branches } ->
    if branches = [] then
      IncompatibleUse
        {
          loc = loc_of_reason reason_upper;
          upper_kind;
          reason_lower;
          reason_upper;
          use_op = Base.Option.value ~default:unknown_use use_op;
        }
    else
      Speculation
        {
          loc = loc_of_reason reason_upper;
          use_op = Base.Option.value ~default:unknown_use use_op;
          branches;
        }
  | EIncompatibleDefs { use_op; reason_lower; reason_upper; branches } ->
    if branches = [] then
      Incompatible { reason_lower; reason_upper; use_op }
    else
      Speculation { loc = loc_of_reason reason_upper; use_op; branches }
  | EIncompatibleProp { prop; reason_prop; reason_obj; special = _; use_op } ->
    PropMissing
      {
        loc = loc_of_reason reason_prop;
        prop = Base.Option.map ~f:display_string_of_name prop;
        reason_obj;
        suggestion = None;
        use_op = Base.Option.value ~default:unknown_use use_op;
      }
  | EDebugPrint (_, str) -> Normal { features = [text str] }
  | EExportValueAsType (_, export_name) ->
    Normal
      {
        features =
          [
            text "Cannot export the value ";
            code (display_string_of_name export_name);
            text " as a type.";
          ];
      }
  | EImportValueAsType (_, export_name) ->
    let (prefix, export) = msg_export "the value " export_name in
    let features =
      [
        text "Cannot import ";
        prefix;
        export;
        text " as a type. ";
        code "import type";
        text " only works on type exports like type aliases, ";
        text "interfaces, and classes. If you intended to import the type of a ";
        text "value use ";
        code "import typeof";
        text " instead.";
      ]
    in
    Normal { features }
  | EImportTypeAsTypeof (_, export_name) ->
    let (prefix, export) = msg_export "the type " export_name in
    let features =
      [
        text "Cannot import ";
        prefix;
        export;
        text " as a type. ";
        code "import typeof";
        text " only works on value exports like variables, ";
        text "functions, and classes. If you intended to import a type use ";
        code "import type";
        text " instead.";
      ]
    in
    Normal { features }
  | EImportTypeAsValue (_, export_name) ->
    let (prefix, export) = msg_export "the type " export_name in
    let features =
      [
        text "Cannot import ";
        prefix;
        export;
        text " as a value. ";
        text "Use ";
        code "import type";
        text " instead.";
      ]
    in
    Normal { features }
  | ERefineAsValue (_, name) ->
    let (_, export) = msg_export "" (display_string_of_name name) in
    let features = [text "Cannot refine "; export; text " as a value. "] in
    Normal { features }
  | ENoDefaultExport (_, module_name, suggestion) ->
    let features =
      [
        text "Cannot import a default export because there is no default export ";
        text "in ";
        code module_name;
        text ".";
      ]
      @
      match suggestion with
      | None -> []
      | Some suggestion ->
        [
          text " ";
          text "Did you mean ";
          code (spf "import {%s} from \"%s\"" suggestion module_name);
          text "?";
        ]
    in
    Normal { features }
  | EOnlyDefaultExport (_, module_name, export_name) ->
    let features =
      [
        text "Cannot import ";
        code export_name;
        text " because ";
        text "there is no ";
        code export_name;
        text " export in ";
        code module_name;
        text ". Did you mean ";
        code (spf "import %s from \"...\"" export_name);
        text "?";
      ]
    in
    Normal { features }
  | ENoNamedExport (_, module_name, export_name, suggestion) ->
    let features =
      [
        text "Cannot import ";
        code export_name;
        text " because ";
        text "there is no ";
        code export_name;
        text " export in ";
        code module_name;
        text ".";
      ]
      @
      match suggestion with
      | None -> []
      | Some suggestion -> [text " Did you mean "; code suggestion; text "?"]
    in
    Normal { features }
  | EMissingTypeArgs { reason_op = _; reason_tapp; reason_arity; min_arity; max_arity } ->
    let (arity, args) =
      if min_arity = max_arity then
        ( spf "%d" max_arity,
          if max_arity = 1 then
            "argument"
          else
            "arguments"
        )
      else
        (spf "%d-%d" min_arity max_arity, "arguments")
    in
    let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
    let features =
      [text "Cannot use "; ref reason_arity; text (spf " without %s type %s." arity args)]
    in
    Normal { features }
  | ETooManyTypeArgs (reason_tapp, reason_arity, n) ->
    let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
    let features =
      [
        text "Cannot use ";
        ref reason_arity;
        text " with more than ";
        text
          (spf
             "%n type %s."
             n
             ( if n == 1 then
               "argument"
             else
               "arguments"
             )
          );
      ]
    in
    Normal { features }
  | ETooFewTypeArgs (reason_tapp, reason_arity, n) ->
    let reason_arity = replace_desc_reason (desc_of_reason reason_tapp) reason_arity in
    let features =
      [
        text "Cannot use ";
        ref reason_arity;
        text " with fewer than ";
        text
          (spf
             "%n type %s."
             n
             ( if n == 1 then
               "argument"
             else
               "arguments"
             )
          );
      ]
    in
    Normal { features }
  | EInvalidTypeArgs (reason_main, reason_tapp) ->
    let features =
      [text "Cannot use "; ref reason_main; text " with "; ref reason_tapp; text " argument"]
    in
    Normal { features }
  | EInvalidExtends reason ->
    let features =
      [
        text "Cannot use ";
        ref reason;
        text " as a superclass. Only variables and member expressions may be extended";
      ]
    in
    Normal { features }
  | ETypeParamArity (_, n) ->
    if n = 0 then
      Normal { features = [text "Cannot apply type because it is not a polymorphic type."] }
    else
      let features =
        [
          text "Cannot use type without exactly ";
          text
            (spf
               "%n type %s."
               n
               ( if n == 1 then
                 "argument"
               else
                 "arguments"
               )
            );
        ]
      in
      Normal { features }
  | ETypeParamMinArity (_, n) ->
    let features =
      [
        text "Cannot use type without at least ";
        text
          (spf
             "%n type %s."
             n
             ( if n == 1 then
               "argument"
             else
               "arguments"
             )
          );
      ]
    in
    Normal { features }
  | ECallTypeArity { call_loc = _; is_new; reason_arity; expected_arity = n } ->
    let use =
      if is_new then
        "construct "
      else
        "call "
    in
    if n = 0 then
      let features =
        [
          text "Cannot ";
          text use;
          text "non-polymorphic ";
          ref reason_arity;
          text " with type arguments.";
        ]
      in
      Normal { features }
    else
      let features =
        [
          text "Cannot ";
          text use;
          ref reason_arity;
          text " without exactly ";
          text
            (spf
               "%n type argument%s."
               n
               ( if n == 1 then
                 ""
               else
                 "s"
               )
            );
        ]
      in
      Normal { features }
  | EAnyValueUsedAsType { reason_use } ->
    let features =
      [
        text "Cannot use ";
        desc reason_use;
        text " as a type because it is an ";
        code "any";
        text "-typed value. ";
        text "Type ";
        desc reason_use;
        text " properly, so it is no longer ";
        code "any";
        text "-typed, to use it as an annotation.";
      ]
    in
    Normal { features }
  | EValueUsedAsType { reason_use } ->
    let features =
      [
        text "Cannot use ";
        desc reason_use;
        text " as a type. ";
        text "A name can be used as a type only if it refers to ";
        text "a type, interface, class, or enum definition. ";
        text "To get the type of a non-class value, use ";
        code "typeof";
        text ".";
      ]
    in
    Normal { features }
  | EExpectedStringLit { reason_lower; reason_upper; use_op } ->
    Incompatible { reason_lower; reason_upper; use_op }
  | EExpectedNumberLit { reason_lower; reason_upper; use_op } ->
    Incompatible { reason_lower; reason_upper; use_op }
  | EExpectedBooleanLit { reason_lower; reason_upper; use_op } ->
    Incompatible { reason_lower; reason_upper; use_op }
  | EExpectedBigIntLit { reason_lower; reason_upper; use_op } ->
    Incompatible { reason_lower; reason_upper; use_op }
  | EPropNotFound { prop_name; reason_obj; reason_prop; use_op; suggestion } ->
    PropMissing
      {
        loc = loc_of_reason reason_prop;
        prop = Base.Option.map ~f:display_string_of_name prop_name;
        reason_obj;
        use_op;
        suggestion;
      }
  | EPropNotReadable { reason_prop; prop_name = x; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason_prop;
        features =
          mk_prop_message (Base.Option.map ~f:display_string_of_name x) @ [text " is not readable"];
        use_op;
      }
  | EPropNotWritable { reason_prop; prop_name = x; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason_prop;
        features =
          mk_prop_message (Base.Option.map ~f:display_string_of_name x) @ [text " is not writable"];
        use_op;
      }
  | EPropPolarityMismatch
      ((reason_lower, reason_upper), prop, (polarity_lower, polarity_upper), use_op) ->
    PropPolarityMismatch
      {
        prop = Base.Option.map ~f:display_string_of_name prop;
        reason_lower;
        polarity_lower;
        reason_upper;
        polarity_upper;
        use_op;
      }
  | EPolarityMismatch { reason; name; expected_polarity; actual_polarity } ->
    let polarity_string = function
      | Polarity.Positive -> "output"
      | Polarity.Negative -> "input"
      | Polarity.Neutral -> "input/output"
    in
    let expected_polarity = polarity_string expected_polarity in
    let actual_polarity = polarity_string actual_polarity in
    let reason_targ = mk_reason (RIdentifier (OrdinaryName name)) (def_loc_of_reason reason) in
    let features =
      [
        text "Cannot use ";
        ref reason_targ;
        text (" in an " ^ actual_polarity ^ " ");
        text "position because ";
        ref reason_targ;
        text " is expected to occur only in ";
        text (expected_polarity ^ " positions.");
      ]
    in
    Normal { features }
  | EBuiltinLookupFailed { reason; name; potential_generator } ->
    let features =
      match name with
      | Some x when is_internal_module_name x ->
        let potential_generator_features =
          match potential_generator with
          | Some generator ->
            [
              text " Try running the command ";
              code generator;
              text " to generate the missing module.";
            ]
          | None -> []
        in
        [text "Cannot resolve module "; code (uninternal_name x); text "."]
        @ potential_generator_features
      | None -> [text "Cannot resolve name "; desc reason; text "."]
      | Some x when is_internal_name x -> [text "Cannot resolve name "; desc reason; text "."]
      | Some x -> [text "Cannot resolve name "; code (display_string_of_name x); text "."]
    in
    Normal { features }
  | EStrictLookupFailed { reason_prop; reason_obj; name; suggestion; use_op } ->
    PropMissing
      {
        loc = loc_of_reason reason_prop;
        prop = Base.Option.map ~f:display_string_of_name name;
        suggestion;
        reason_obj;
        use_op = Base.Option.value ~default:unknown_use use_op;
      }
  | EPrivateLookupFailed (reasons, x, use_op) ->
    PropMissing
      {
        loc = loc_of_reason (fst reasons);
        prop = Some ("#" ^ display_string_of_name x);
        reason_obj = snd reasons;
        use_op;
        suggestion = None;
      }
  | EAdditionMixed (reason, use_op) ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = [ref reason; text " could either behave like a string or like a number"];
        use_op;
      }
  | EComparison (lower, upper) ->
    Normal { features = [text "Cannot compare "; ref lower; text " to "; ref upper; text "."] }
  | ENonStrictEqualityComparison (lower, upper) ->
    Normal
      {
        features =
          [
            text "Cannot compare ";
            ref lower;
            text " to ";
            ref upper;
            text " with a non-strict equality check. ";
            text "Make sure the arguments are valid, ";
            text "or try using strict equality (";
            code "===";
            text " or ";
            code "!==";
            text ") instead.";
          ];
      }
  | ETupleArityMismatch (reasons, l1, l2, use_op) ->
    let (lower, upper) = reasons in
    UseOp
      {
        loc = loc_of_reason lower;
        features =
          [
            ref lower;
            text (spf " has an arity of %d but " l1);
            ref upper;
            text (spf " has an arity of %d" l2);
          ];
        use_op;
      }
  | ENonLitArrayToTuple (reasons, use_op) ->
    let (lower, upper) = reasons in
    UseOp
      {
        loc = loc_of_reason lower;
        features =
          [
            ref lower;
            text " has an unknown number of elements, so is ";
            text "incompatible with ";
            ref upper;
          ];
        use_op;
      }
  | ETupleOutOfBounds { reason; reason_op; length; index; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features =
          [
            ref reason_op;
            text
              (spf
                 " only has %d element%s, so index %s is out of bounds"
                 length
                 ( if length == 1 then
                   ""
                 else
                   "s"
                 )
                 index
              );
          ];
        use_op;
      }
  | ETupleNonIntegerIndex { reason; index; use_op } ->
    let index_ref = Errors.Friendly.(Reference ([Code index], def_loc_of_reason reason)) in
    UseOp
      {
        loc = loc_of_reason reason;
        features =
          [
            text "the index into a tuple must be an integer, but ";
            index_ref;
            text " is not an integer";
          ];
        use_op;
      }
  | ETupleUnsafeWrite { reason; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = [text "the index must be statically known to write a tuple element"];
        use_op;
      }
  | ETupleElementNotReadable { reason; index; name; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = mk_tuple_element_error_message ~reason ~index ~name "readable";
        use_op;
      }
  | ETupleElementNotWritable { reason; index; name; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = mk_tuple_element_error_message ~reason ~index ~name "writable";
        use_op;
      }
  | ETupleElementPolarityMismatch
      { index; reason_lower; polarity_lower; reason_upper; polarity_upper; use_op } ->
    let expected = polarity_explanation (polarity_lower, polarity_upper) in
    let actual = polarity_explanation (polarity_upper, polarity_lower) in
    UseOp
      {
        loc = loc_of_reason reason_lower;
        features =
          [
            text "tuple element at index ";
            code (string_of_int index);
            text " is ";
            text expected;
            text " in ";
            ref reason_lower;
            text " but ";
            text actual;
            text " in ";
            ref reason_upper;
          ];
        use_op;
      }
  | EROArrayWrite (reasons, use_op) ->
    let (lower, _) = reasons in
    UseOp
      {
        loc = loc_of_reason lower;
        features = [text "read-only arrays cannot be written to"];
        use_op;
      }
  | EUnionSpeculationFailed { use_op; reason; reason_op = _; branches } ->
    Speculation { loc = loc_of_reason reason; use_op; branches }
  | ESpeculationAmbiguous
      { reason = _; prev_case = (prev_i, prev_case); case = (i, case); cases = case_rs } ->
    Friendly.(
      let prev_case_r =
        mk_reason (RCustom ("case " ^ string_of_int (prev_i + 1))) (loc_of_reason prev_case)
      in
      let case_r = mk_reason (RCustom ("case " ^ string_of_int (i + 1))) (loc_of_reason case) in
      let features =
        [
          text "Could not decide which case to select, since ";
          ref prev_case_r;
          text " ";
          text "may work but if it doesn't ";
          ref case_r;
          text " looks promising ";
          text "too. To fix add a type annotation ";
        ]
        @ conjunction_concat
            ~conjunction:"or"
            (Base.List.map
               ~f:(fun case_r ->
                 let text = "to " ^ string_of_desc (desc_of_reason case_r) in
                 [ref (mk_reason (RCustom text) (loc_of_reason case_r))])
               case_rs
            )
        @ [text "."]
      in
      Normal { features }
    )
  | EIncompatibleWithExact (reasons, use_op, kind) ->
    let (lower, upper) = reasons in
    let object_kind =
      match kind with
      | Indexer -> "indexed "
      | Inexact -> "inexact "
    in
    UseOp
      {
        loc = loc_of_reason lower;
        features = [text object_kind; ref lower; text " is incompatible with exact "; ref upper];
        use_op;
      }
  | EFunctionIncompatibleWithIndexer ((lower, upper), use_op) ->
    UseOp
      {
        loc = loc_of_reason lower;
        features = [ref lower; text " is incompatible with indexed "; ref upper];
        use_op;
      }
  | EUnsupportedExact (_, lower) ->
    Normal { features = [text "Cannot create exact type from "; ref lower; text "."] }
  | EIdxArity _ ->
    let features =
      [
        text "Cannot call ";
        code "idx(...)";
        text " because only exactly two ";
        text "arguments are allowed.";
      ]
    in
    Normal { features }
  | EIdxUse _ ->
    let features =
      [
        text "Illegal ";
        code "idx";
        text " operation: the callback can only access properties on the callback parameter.";
      ]
    in
    Normal { features }
  | EUnexpectedThisType _ ->
    Normal { features = [text "Unexpected use of "; code "this"; text " type."] }
  | EPropertyTypeAnnot _ ->
    let features =
      [
        text "Cannot use ";
        code "$PropertyType";
        text " because the second ";
        text "type argument must be a string literal.";
      ]
    in
    Normal { features }
  | EExportsAnnot _ ->
    let features =
      [
        text "Cannot use ";
        code "$Exports";
        text " because the first type ";
        text "argument must be a string literal.";
      ]
    in
    Normal { features }
  | ECharSetAnnot _ ->
    let features =
      [
        text "Cannot use ";
        code "$CharSet";
        text " because the first type ";
        text "argument must be a string literal.";
      ]
    in
    Normal { features }
  | EInvalidCharSet { invalid = (invalid_reason, invalid_chars); valid = valid_reason; use_op } ->
    let valid_reason = mk_reason (desc_of_reason valid_reason) (def_loc_of_reason valid_reason) in
    let invalids =
      InvalidCharSetSet.fold
        (fun c acc ->
          match c with
          | InvalidChar c ->
            [code (Base.String.of_char c); text " is not a member of the set"] :: acc
          | DuplicateChar c -> [code (Base.String.of_char c); text " is duplicated"] :: acc)
        invalid_chars
        []
      |> List.rev
    in
    UseOp
      {
        loc = loc_of_reason invalid_reason;
        features =
          [ref invalid_reason; text " is incompatible with "; ref valid_reason; text " since "]
          @ Friendly.conjunction_concat ~conjunction:"and" invalids;
        use_op;
      }
  | EUnsupportedKeyInObjectType _ -> Normal { features = [text "Unsupported key in object type."] }
  | EPredAnnot _ ->
    let features =
      [
        text "Cannot use ";
        code "$Pred";
        text " because the first ";
        text "type argument must be a number literal.";
      ]
    in
    Normal { features }
  | ERefineAnnot _ ->
    let features =
      [
        text "Cannot use ";
        code "$Refine";
        text " because the third ";
        text "type argument must be a number literal.";
      ]
    in
    Normal { features }
  | ETrustedAnnot _ ->
    Normal { features = [text "Not a valid type to mark as "; code "$Trusted"; text "."] }
  | EPrivateAnnot _ ->
    Normal { features = [text "Not a valid type to mark as "; code "$Private"; text "."] }
  | EFunPredCustom ((a, b), msg) ->
    Normal { features = [ref a; text ". "; text msg; text " "; ref b; text "."] }
  | EIncompatibleWithShape (lower, upper, use_op) ->
    UseOp
      {
        loc = loc_of_reason lower;
        features = [ref lower; text " is incompatible with "; code "$Shape"; text " of "; ref upper];
        use_op;
      }
  | EInternal (_, internal_error) ->
    let msg = string_of_internal_error internal_error in
    Normal { features = [text (spf "Internal error: %s" msg)] }
  | EUnsupportedSyntax (_, unsupported_syntax) ->
    let features =
      match unsupported_syntax with
      | ComprehensionExpression
      | GeneratorExpression
      | MetaPropertyExpression ->
        [text "Not supported."]
      | AnnotationInsideDestructuring ->
        [
          text "Annotations inside of destructuring are not supported. ";
          text "Annotate the top-level pattern instead. ";
          text "For example, instead of the invalid ";
          code "const [a: number, b: string] = ...";
          text " do ";
          code "const [a, b]: [number, string] = ...";
          text ".";
        ]
      | ObjectPropertyLiteralNonString -> [text "Non-string literal property keys not supported."]
      | ObjectPropertyGetSet -> [text "Get/set properties not yet supported."]
      | ObjectPropertyComputedGetSet -> [text "Computed getters and setters are not yet supported."]
      | InvariantSpreadArgument ->
        [text "Unsupported arguments in call to "; code "invariant"; text "."]
      | ClassPropertyLiteral -> [text "Literal properties not yet supported."]
      | ClassPropertyComputed -> [text "Computed property keys not supported."]
      | RequireDynamicArgument ->
        [text "The parameter passed to "; code "require"; text " must be a string literal."]
      | ImportDynamicArgument ->
        [text "The parameter passed to "; code "import"; text " must be a string literal."]
      | CatchParameterDeclaration -> [text "Unsupported catch parameter declaration."]
      | DestructuringObjectPropertyLiteralNonString ->
        [text "Unsupported non-string literal object property in destructuring."]
      | DestructuringExpressionPattern -> [text "Unsupported expression pattern in destructuring."]
      | PredicateDeclarationForImplementation ->
        [text "Cannot declare predicate when a function body is present."]
      | PredicateDeclarationWithoutExpression ->
        [text "Predicate function declarations need to declare a "; text "predicate expression."]
      | PredicateDeclarationAnonymousParameters ->
        [text "Predicate function declarations cannot use anonymous "; text "function parameters."]
      | PredicateInvalidBody ->
        [
          text "Invalid body for predicate function. Expected a simple return ";
          text "statement as body.";
        ]
      | PredicateInvalidParameter r ->
        [
          text "Invalid ";
          ref r;
          text " in predicate function. Predicate functions cannot ";
          text "have destructured or spread parameters. This predicate annotation will ";
          text "be ignored.";
        ]
      | PredicateFunctionAbstractReturnType ->
        [
          text "The return type of a predicate function cannot contain a generic type. ";
          text "The function predicate will be ignored here.";
        ]
      | PredicateVoidReturn -> [text "Predicate functions need to return non-void."]
      | MultipleIndexers -> [text "Multiple indexers are not supported."]
      | MultipleProtos -> [text "Multiple prototypes specified."]
      | ExplicitCallAfterProto -> [text "Unexpected call property after explicit prototype."]
      | ExplicitProtoAfterCall -> [text "Unexpected prototype after call property."]
      | SpreadArgument -> [text "A spread argument is unsupported here."]
      | IllegalName -> [text "Illegal name."]
      | TupleOptionalElement -> [text "Optional tuple elements are not supported."]
      | TupleSpreadElement -> [text "Tuple spread is not supported."]
      | UnsupportedInternalSlot { name; static = false } ->
        [text "Unsupported internal slot "; code name; text "."]
      | UnsupportedInternalSlot { name; static = true } ->
        [text "Unsupported static internal slot "; code name; text "."]
    in
    Normal { features }
  | EUseArrayLiteral _ ->
    Normal { features = [text "Use an array literal instead of "; code "new Array(...)"; text "."] }
  | EMissingAnnotation (reason, _) ->
    let default = [text "Missing type annotation for "; desc reason; text "."] in
    let features =
      match desc_of_reason reason with
      | RTypeParam (_, (reason_op_desc, reason_op_loc), (reason_tapp_desc, reason_tapp_loc)) ->
        let reason_op = mk_reason reason_op_desc reason_op_loc in
        let reason_tapp = mk_reason reason_tapp_desc reason_tapp_loc in
        default
        @ [
            text " ";
            desc reason;
            text " is a type parameter declared in ";
            ref reason_tapp;
            text " and was implicitly instantiated at ";
            ref reason_op;
            text ".";
          ]
      | _ -> default
    in
    (* We don't collect trace info in the assert_ground_visitor because traces
     * represent tests of lower bounds to upper bounds, and the assert_ground
     * visitor is just visiting types. Instead, we collect a list of types we
     * visited to get to the missing annotation error and report that as the
     * trace *)
    Normal { features }
  | EMissingLocalAnnotation { reason; hint_available; from_generic_function } ->
    if hint_available then
      Normal
        {
          features =
            [
              text "An annotation on ";
              desc reason;
              text " is required because Flow cannot infer its type from local context.";
            ];
        }
    else if from_generic_function then
      Normal
        {
          features =
            [
              text "Missing an annotation on ";
              desc reason;
              text " because generic functions must be fully annotated.";
            ];
        }
    else
      Normal { features = [text "Missing an annotation on "; desc reason; text "."] }
  | EBindingError (binding_error, _, x, entry_loc) ->
    let desc =
      match x with
      | InternalName "this" -> RThis
      | InternalName "super" -> RSuper
      | _ -> RIdentifier x
    in
    (* We can call to_loc here because reaching this point requires that everything else
       in the error message is concretized already; making Scopes polymorphic is not a good idea *)
    let x = mk_reason desc (entry_loc |> ALoc.to_loc_exn) in
    let type_as_value_msg x =
      [
        text "Cannot use type ";
        ref x;
        text " as a value. ";
        text "Types are erased and don't exist at runtime.";
      ]
    in
    let features =
      match binding_error with
      | ENameAlreadyBound ->
        [text "Cannot declare "; ref x; text " because the name is already bound."]
      | EVarRedeclaration ->
        [text "Cannot declare "; ref x; text " because var redeclaration is not supported."]
      | EReferencedBeforeDeclaration ->
        if desc = RThis || desc = RSuper then
          [
            text "Must call ";
            code "super";
            text " before accessing ";
            ref x;
            text " in a derived constructor.";
          ]
        else
          [
            text "Cannot use variable ";
            ref x;
            text " because the declaration ";
            text "either comes later or was skipped.";
          ]
      | ETypeInValuePosition { imported = true; name } ->
        type_as_value_msg x
        @ [
            text " If the exported binding can also be used as a value, try importing it using ";
            code (spf "import %s" name);
            text " instead of ";
            code (spf "import type %s" name);
            text " and ";
            code (spf "import {%s}" name);
            text " instead of ";
            code (spf "import type {%s}" name);
            text ".";
          ]
      | ETypeInValuePosition { imported = false; name = _ }
      | ETypeAliasInValuePosition ->
        type_as_value_msg x
      | EConstReassigned
      | EConstParamReassigned ->
        [text "Cannot reassign constant "; ref x; text "."]
      | EImportReassigned -> [text "Cannot reassign import "; ref x; text "."]
      | EEnumReassigned -> [text "Cannot reassign enum "; ref x; text "."]
    in
    Normal { features }
  | ERecursionLimit _ -> Normal { features = [text "*** Recursion limit exceeded ***"] }
  | EUnsafeGetSet _ ->
    let features =
      [
        text "Potentially unsafe get/set usage. Getters and setters with side ";
        text "effects are potentially unsafe and so disabled by default. You may ";
        text "opt-in to using them anyway by putting ";
        code "unsafe.enable_getters_and_setters";
        text " into the ";
        code "[options]";
        text " section of your ";
        code ".flowconfig";
        text ".";
      ]
    in
    Normal { features }
  | EUninitializedInstanceProperty (_loc, err) ->
    let open Lints in
    let features =
      match err with
      | PropertyNotDefinitelyInitialized ->
        [
          text "Class property not definitely initialized in the constructor. ";
          text "Can you add an assignment to the property declaration?";
        ]
      | ReadFromUninitializedProperty ->
        [
          text "It is unsafe to read from a class property before it is ";
          text "definitely initialized.";
        ]
      | MethodCallBeforeEverythingInitialized ->
        [
          text "It is unsafe to call a method in the constructor before all ";
          text "class properties are definitely initialized.";
        ]
      | PropertyFunctionCallBeforeEverythingInitialized ->
        [
          text "It is unsafe to call a property function in the constructor ";
          text "before all class properties are definitely initialized.";
        ]
      | ThisBeforeEverythingInitialized ->
        [
          text "It is unsafe to use ";
          code "this";
          text " in the constructor ";
          text "before all class properties are definitely initialized.";
        ]
    in
    Normal { features }
  | EEnumsNotEnabled _ ->
    let features =
      [
        text "Flow Enums are not enabled. ";
        text "You may opt-in to using enums by putting ";
        code "enums=true";
        text " into the ";
        code "[options]";
        text " section of your ";
        code ".flowconfig";
        text ".";
      ]
    in
    Normal { features }
  | EIndeterminateModuleType _ ->
    let features =
      [
        text "Unable to determine module type (CommonJS vs ES) if both an export ";
        text "statement and ";
        code "module.exports";
        text " are used in the ";
        text "same module!";
      ]
    in
    Normal { features }
  | EBadExportPosition _ -> Normal { features = [text "Exports can only appear at the top level"] }
  | EBadExportContext (name, _) ->
    Normal
      {
        features =
          [code name; text " may only be used as part of a legal top level export statement"];
      }
  | EBadDefaultImportAccess (_, import_star_reason) ->
    Normal
      {
        features =
          [
            text "The default export of a module cannot be accessed from an ";
            ref import_star_reason;
            text " object. To use the default export you must import it directly.";
          ];
      }
  | EBadDefaultImportDestructuring _ ->
    Normal
      {
        features =
          [
            text "The default export of a module cannot be accessed from import destructuring. ";
            text "To use the default export you must import it directly.";
          ];
      }
  | EInvalidImportStarUse (_, import_star_reason) ->
    Normal
      {
        features =
          [
            ref import_star_reason;
            text " object can only be used by accessing one of its named exports";
            text " with a member access or destructuring.";
          ];
      }
  | ENonConstVarExport (_, decl_reason) ->
    let reason_opt =
      match decl_reason with
      | Some reason -> [text "variable "; ref reason]
      | None -> [text "variable"]
    in
    Normal
      {
        features =
          List.concat
            [
              [text "Cannot export "];
              reason_opt;
              [
                text " declared using ";
                code "var";
                text " or ";
                code "let";
                text ". All exported variables must be ";
                code "const";
                text ".";
              ];
            ];
      }
  | EThisInExportedFunction _ ->
    Normal { features = [text "Cannot use "; code "this"; text " in an exported function."] }
  | EMixedImportAndRequire (_, import_reason) ->
    Normal
      {
        features =
          [
            text "Cannot use a mix of non-type toplevel ";
            ref import_reason;
            text " and ";
            code "require";
            text " statements in the same file.";
          ];
      }
  | EToplevelLibraryImport _ ->
    Normal
      {
        features =
          [
            text "Cannot use an import statement at the toplevel of a library file. ";
            text "Import statements may only appear inside a ";
            code "declare module";
            text ".";
          ];
      }
  | EExportRenamedDefault { loc = _; name; is_reexport } ->
    let reexport_message () =
      [
        text "If you intended to set the default export please ";
        code "import";
        text " and then ";
        code "export default";
        text " instead.";
      ]
    in
    let features =
      match (name, is_reexport) with
      | (None, _) ->
        [
          text "Cannot set the default export of a module by re-exporting the ";
          code "default";
          text " property. ";
        ]
        @ reexport_message ()
      | (Some name, true) ->
        [
          text "Cannot set the default export of a module by re-exporting ";
          code name;
          text " as ";
          code "default";
          text ". ";
        ]
        @ reexport_message ()
      | (Some name, false) ->
        [
          text "Cannot set the default export of a module by renaming ";
          code name;
          text " to ";
          code "default";
          text ". If you intended to set the default export use ";
          code (spf "export default %s" name);
          text " instead.";
        ]
    in
    Normal { features }
  | EUnexpectedTemporaryBaseType _ ->
    Normal
      {
        features =
          [text "The type argument of a temporary base type must be a compatible literal type"];
      }
  | ECannotDelete (_, expr) ->
    let features =
      [
        text "Cannot delete ";
        ref expr;
        text " because only member expressions and variables can be deleted.";
      ]
    in
    Normal { features }
  | ESignatureVerification sve ->
    Signature_error.(
      let features =
        match sve with
        | ExpectedAnnotation (_, sort) ->
          [text (spf "Missing type annotation at %s:" (Expected_annotation_sort.to_string sort))]
        | UnexpectedObjectKey _ -> [text "Expected simple key in object:"]
        | UnexpectedArraySpread _ -> [text "Unexpected spread in array:"]
        | UnexpectedArrayHole _ -> [text "Unexpected array hole:"]
        | EmptyArray _ ->
          [
            text "Cannot determine the element type of an empty array. ";
            text "Please provide an annotation, e.g., by adding a type cast around this expression.";
          ]
        | EmptyObject _ ->
          [
            text "Cannot determine types of initialized properties of an empty object. ";
            text "Please provide an annotation, e.g., by adding a type cast around this expression.";
          ]
        | UnexpectedExpression (_, esort) ->
          [
            text
              (spf
                 "Cannot determine the type of this %s. "
                 (Flow_ast_utils.ExpressionSort.to_string esort)
              );
            text "Please provide an annotation, e.g., by adding a type cast around this expression.";
          ]
      in
      let features =
        text "Cannot build a typed interface for this module. "
        :: text "You should annotate the exports of this module with types. "
        :: features
      in
      Normal { features }
    )
  | EUnreachable _ -> Normal { features = [text "Unreachable code."] }
  | EInvalidObjectKit { reason; reason_op = _; use_op } ->
    UseOp { loc = loc_of_reason reason; features = [ref reason; text " is not an object"]; use_op }
  | EInvalidTypeof (_, typename) ->
    let features =
      [
        text "Cannot compare the result of ";
        code "typeof";
        text " to string ";
        text "literal ";
        code typename;
        text " because it is not a valid ";
        code "typeof";
        text " return value.";
      ]
    in
    Normal { features }
  | EArithmeticOperand reason ->
    let features =
      [
        text "Cannot perform arithmetic operation because ";
        ref reason;
        text " ";
        text "is not a number or bigint.";
      ]
    in
    Normal { features }
  | EBinaryInLHS reason ->
    (* TODO: or symbol *)
    let features =
      [
        text "Cannot use ";
        code "in";
        text " because on the left-hand side, ";
        ref reason;
        text " must be a string or number.";
      ]
    in
    Normal { features }
  | EBinaryInRHS reason ->
    let features =
      [
        text "Cannot use ";
        code "in";
        text " because on the right-hand side, ";
        ref reason;
        text " must be an object or array.";
      ]
    in
    Normal { features }
  | EForInRHS reason ->
    let features =
      [
        text "Cannot iterate using a ";
        code "for...in";
        text " statement ";
        text "because ";
        ref reason;
        text " is not an object, null, or undefined.";
      ]
    in
    Normal { features }
  | EInstanceofRHS reason ->
    let features =
      [
        text "The right-hand side of an ";
        code "instanceof";
        text " expression must be an object, but got ";
        ref reason;
        text ".";
      ]
    in
    Normal { features }
  | EObjectComputedPropertyAccess (_, reason_prop) ->
    Normal { features = [text "Cannot access computed property using "; ref reason_prop; text "."] }
  | EObjectComputedPropertyAssign (_, reason_prop) ->
    Normal { features = [text "Cannot assign computed property using "; ref reason_prop; text "."] }
  | EInvalidLHSInAssignment _ ->
    Normal { features = [text "Invalid left-hand side in assignment expression."] }
  | EIncompatibleWithUseOp { reason_lower; reason_upper; use_op } ->
    Incompatible { reason_lower; reason_upper; use_op }
  | ETrustIncompatibleWithUseOp (reason_lower, reason_upper, use_op) ->
    IncompatibleTrust { reason_lower; reason_upper; use_op }
  | EUnsupportedImplements reason ->
    Normal
      {
        features = [text "Cannot implement "; desc reason; text " because it is not an interface."];
      }
  | ENotAReactComponent { reason; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = [ref reason; text " is not a React component"];
        use_op;
      }
  | EInvalidReactConfigType { reason; use_op } ->
    UseOp
      {
        loc = loc_of_reason reason;
        features = [ref reason; text " cannot calculate config"];
        use_op;
      }
  | ECannotResolveOpenTvar { use_op; reason; blame_reasons } ->
    let rec refs = function
      | [] -> failwith "cannot have empty reason list"
      | [r] -> [ref r]
      | [r1; r2] -> [ref r1; text " and "; ref r2]
      | r1 :: rs -> [ref r1; text ", "] @ refs rs
    in
    UseOp
      {
        loc = loc_of_reason reason;
        features =
          [
            text "Flow cannot infer the type of ";
            ref reason;
            text ". Please provide an annotation for ";
          ]
          @ refs blame_reasons;
        use_op;
      }
  | EInvalidReactPropType { reason; use_op; tool } ->
    React.(
      React.SimplifyPropType.(
        let is_not_prop_type = "is not a React propType" in
        let msg =
          match tool with
          | ArrayOf -> is_not_prop_type
          | InstanceOf -> "is not a class"
          | ObjectOf -> is_not_prop_type
          | OneOf ResolveArray -> "is not an array"
          | OneOf (ResolveElem _) -> "is not a literal"
          | OneOfType ResolveArray -> "is not an array"
          | OneOfType (ResolveElem _) -> is_not_prop_type
          | Shape ResolveObject -> "is not an object"
          | Shape (ResolveDict _) -> is_not_prop_type
          | Shape (ResolveProp _) -> is_not_prop_type
        in
        UseOp { loc = loc_of_reason reason; features = [ref reason; text (" " ^ msg)]; use_op }
      )
    )
  | EReactElementFunArity (_, fn, n) ->
    let features =
      [
        text "Cannot call ";
        code ("React." ^ fn);
        text " ";
        text
          (spf
             "without at least %d argument%s."
             n
             ( if n == 1 then
               ""
             else
               "s"
             )
          );
      ]
    in
    Normal { features }
  | EFunctionCallExtraArg (unused_reason, def_reason, param_count, use_op) ->
    let msg =
      match param_count with
      | 0 -> "no arguments are expected by"
      | 1 -> "no more than 1 argument is expected by"
      | n -> spf "no more than %d arguments are expected by" n
    in
    UseOp
      { loc = loc_of_reason unused_reason; features = [text msg; text " "; ref def_reason]; use_op }
  | EEscapedGeneric
      { is_this = false; reason; blame_reason; annot_reason; use_op; bound_loc; bound_name }
    when blame_reason = reason ->
    let features =
      [
        text "type variable ";
        ref (replace_desc_reason (RCustom (spf "`%s`" bound_name)) blame_reason);
        text " cannot escape from the scope in which it was ";
        ref (mk_reason (RCustom "defined") bound_loc);
      ]
    in
    let annot_features =
      Base.Option.value_map annot_reason ~default:[] ~f:(fun annot_reason ->
          [text " (try adding a type annotation to "; ref annot_reason; text ")"]
      )
    in
    UseOp { loc = loc_of_reason reason; features = features @ annot_features; use_op }
  | EEscapedGeneric
      { is_this = false; reason; blame_reason; annot_reason; use_op; bound_loc; bound_name } ->
    let features =
      [
        ref reason;
        text " contains type variable ";
        ref (replace_desc_reason (RCustom (spf "`%s`" bound_name)) blame_reason);
        text " which cannot escape from the scope in which it was ";
        ref (mk_reason (RCustom "defined") bound_loc);
      ]
    in
    let annot_features =
      Base.Option.value_map annot_reason ~default:[] ~f:(fun annot_reason ->
          [text " (try adding a type annotation to "; ref annot_reason; text ")"]
      )
    in
    UseOp { loc = loc_of_reason reason; features = features @ annot_features; use_op }
  | EEscapedGeneric
      { is_this = true; reason; blame_reason; annot_reason; use_op; bound_loc; bound_name }
    when match desc_of_reason reason with
         | RThis
         | RThisType ->
           true
         | _ -> reason = blame_reason ->
    let features =
      [
        ref (replace_desc_reason (RCustom (spf "`%s`" bound_name)) blame_reason);
        text " cannot escape from its ";
        ref (mk_reason (RCustom "class") bound_loc);
      ]
    in
    let annot_features =
      Base.Option.value_map annot_reason ~default:[] ~f:(fun annot_reason ->
          [text " (try adding a type annotation to "; ref annot_reason; text ")"]
      )
    in
    UseOp { loc = loc_of_reason reason; features = features @ annot_features; use_op }
  | EEscapedGeneric
      { is_this = true; reason; blame_reason; annot_reason; use_op; bound_loc; bound_name } ->
    let features =
      [
        ref reason;
        text " contains ";
        ref (replace_desc_reason (RCustom (spf "`%s`" bound_name)) blame_reason);
        text " which cannot escape from its ";
        ref (mk_reason (RCustom "class") bound_loc);
      ]
    in
    let annot_features =
      Base.Option.value_map annot_reason ~default:[] ~f:(fun annot_reason ->
          [text " (try adding a type annotation to "; ref annot_reason; text ")"]
      )
    in
    UseOp { loc = loc_of_reason reason; features = features @ annot_features; use_op }
  | EUnsupportedSetProto _ -> Normal { features = [text "Mutating this prototype is unsupported."] }
  | EDuplicateModuleProvider { module_name; provider; _ } ->
    let features =
      [
        text "Duplicate module provider for ";
        code module_name;
        text ". Change ";
        text "either this module provider or the ";
        ref (mk_reason (RCustom "current module provider") provider);
        text ".";
      ]
    in
    Normal { features }
  | EParseError (_, parse_error) ->
    Normal { features = Friendly.message_of_string (Parse_error.PP.error parse_error) }
  | EDocblockError (_, err) ->
    let features =
      match err with
      | MultipleFlowAttributes ->
        [
          text "Unexpected ";
          code "@flow";
          text " declaration. Only one per ";
          text "file is allowed.";
        ]
      | InvalidFlowMode s ->
        [
          code (spf "@flow %s" s);
          text " is not a valid ";
          code "@flow";
          text " mode. Valid ones are: ";
          code "@flow";
          text ", ";
          code "@flow strict";
          text ", and ";
          code "@flow strict-local";
          text ".";
        ]
      | MultipleProvidesModuleAttributes ->
        [
          text "Unexpected ";
          code "@providesModule";
          text " declaration. ";
          text "Only one per file is allowed.";
        ]
      | MultipleJSXAttributes ->
        [
          text "Unexpected ";
          code "@jsx";
          text " declaration. Only one per ";
          text "file is allowed.";
        ]
      | InvalidJSXAttribute first_error ->
        [
          text "Invalid ";
          code "@jsx";
          text " declaration. Should have the form ";
          code "@jsx LeftHandSideExpression";
          text " with no spaces.";
        ]
        @
        (match first_error with
        | None -> []
        | Some first_error -> [text (spf " Parse error: %s." first_error)])
      | MultipleJSXRuntimeAttributes ->
        [
          text "Unexpected ";
          code "@jsxRuntime";
          text " declaration. Only one per ";
          text "file is allowed.";
        ]
      | InvalidJSXRuntimeAttribute ->
        [
          text "Invalid ";
          code "@jsxRuntime";
          text " declaration. The only supported values are ";
          code "classic";
          text " and ";
          code "automatic";
          text ".";
        ]
    in
    Normal { features }
  | EImplicitInexactObject _ ->
    let features =
      [
        text "Please add ";
        code "...";
        text " to the end of the list of ";
        text "properties to express an inexact object type.";
      ]
    in
    Normal { features }
  | EAmbiguousObjectType _ ->
    let features =
      [
        text "Please write this object type as explicitly exact (use ";
        code "{|";
        text " and ";
        code "|}";
        text " instead of ";
        code "{";
        text " and ";
        code "}";
        text ") or as explicitly inexact (add ";
        code "...";
        text " to the end of the list of properties).";
      ]
    in
    Normal { features }
  | EUntypedTypeImport (_, module_name) ->
    let features =
      [
        text "Importing a type from an untyped module makes it ";
        code "any";
        text " ";
        text "and is not safe! Did you mean to add ";
        code "// @flow";
        text " to ";
        text "the top of ";
        code module_name;
        text "?";
      ]
    in
    Normal { features }
  | EUntypedImport (_, module_name) ->
    let features =
      [
        text "Importing from an untyped module makes it ";
        code "any";
        text " ";
        text "and is not safe! Did you mean to add ";
        code "// @flow";
        text " ";
        text "to the top of ";
        code module_name;
        text "?";
      ]
    in
    Normal { features }
  | ENonstrictImport _ ->
    let features =
      [
        text "Dependencies of a ";
        code "@flow strict";
        text " module must ";
        text "also be ";
        code "@flow strict";
        text "!";
      ]
    in
    Normal { features }
  | EUnclearType _ ->
    let features =
      [
        text "Unclear type. Using ";
        code "any";
        text ", ";
        code "Object";
        text ", ";
        code "Function";
        text ", or ";
        code "*";
        text " types is not safe!";
      ]
    in
    Normal { features }
  | EDeprecatedBool _ ->
    Normal { features = [text "Deprecated type. Use "; code "boolean"; text " instead."] }
  | EDeprecatedType _ ->
    Normal
      { features = [text "Deprecated type. Using "; code "*"; text " types is not recommended!"] }
  | EUnsafeGettersSetters _ ->
    Normal { features = [text "Getters and setters can have side effects and are unsafe."] }
  | EUnusedSuppression _ -> Normal { features = [text "Unused suppression comment."] }
  | ECodelessSuppression (_, c) ->
    Normal
      {
        features =
          [
            text
              "Suppression is missing a code. Please update this suppression to use an error code: ";
            code ("$FlowFixMe[" ^ c ^ "]");
          ];
      }
  | ELintSetting (_, kind) ->
    let features =
      match kind with
      | LintSettings.Redundant_argument ->
        [text "Redundant argument. This argument doesn't change any lint settings."]
      | LintSettings.Overwritten_argument ->
        [
          text "Redundant argument. The values set by this argument are ";
          text "overwritten later in this comment.";
        ]
      | LintSettings.Naked_comment ->
        [text "Malformed lint rule. At least one argument is required."]
      | LintSettings.Nonexistent_rule ->
        [
          text "Nonexistent/misspelled lint rule. Perhaps you have a ";
          text "missing/extra ";
          code ",";
          text "?";
        ]
      | LintSettings.Invalid_setting ->
        [text "Invalid setting. Valid settings are error, warn, and off."]
      | LintSettings.Malformed_argument ->
        [
          text "Malformed lint rule. Properly formed rules contain a single ";
          code ":";
          text " character. Perhaps you have a missing/extra ";
          code ",";
          text "?";
        ]
    in
    Normal { features }
  | ESketchyNullLint { kind = sketchy_kind; loc = _; falsy_loc; null_loc } ->
    let (type_str, value_str) =
      match sketchy_kind with
      | Lints.SketchyNullBool -> ("boolean", "false")
      | Lints.SketchyNullNumber -> ("number", "0")
      | Lints.SketchyNullBigInt -> ("bigint", "0n")
      | Lints.SketchyNullString -> ("string", "an empty string")
      | Lints.SketchyNullMixed -> ("mixed", "false")
      | Lints.SketchyNullEnumBool -> ("boolean enum", "false at runtime")
      | Lints.SketchyNullEnumNumber -> ("number enum", "0 at runtime")
      | Lints.SketchyNullEnumBigInt -> ("bigint enum", "0n at runtime")
      | Lints.SketchyNullEnumString -> ("string enum", "an empty string at runtime")
    in
    let features =
      [
        text "Sketchy null check on ";
        ref (mk_reason (RCustom type_str) falsy_loc);
        text " ";
        text "which is potentially ";
        text value_str;
        text ". Perhaps you meant to ";
        text "check for ";
        ref (mk_reason RNullOrVoid null_loc);
        text "?";
      ]
    in
    Normal { features }
  | ESketchyNumberLint (_, reason) ->
    let features =
      [
        text "Avoid using ";
        code "&&";
        text " to check the value of ";
        ref reason;
        text ". ";
        text "Consider handling falsy values (0 and NaN) by using a conditional to choose an ";
        text "explicit default instead.";
      ]
    in
    Normal { features }
  | EInvalidConstructor reason ->
    Normal
      {
        features =
          [
            text "Cannot use ";
            code "new";
            text " on ";
            ref reason;
            text ". Only classes can be constructed.";
          ];
      }
  | EInvalidConstructorDefinition { loc = _; async; generator; predicate } ->
    let kind =
      if predicate then
        "a predicate"
      else if generator then
        "a generator"
      else if async then
        "async"
      else
        failwith "Missing reason for invalid constructor"
    in
    Normal { features = [text "Class constructor may not be "; text kind; text "."] }
  | EInvalidPrototype (_, reason) ->
    Normal
      {
        features =
          [text "Cannot use "; ref reason; text " as a prototype. Expected an object or null."];
      }
  | EUnnecessaryOptionalChain (_, lhs_reason) ->
    let features =
      [
        text "This use of optional chaining (";
        code "?.";
        text ") is unnecessary because ";
        ref lhs_reason;
        text " cannot be nullish or because an earlier ";
        code "?.";
        text " will short-circuit the nullish case.";
      ]
    in
    Normal { features }
  | EUnnecessaryInvariant (_, reason) ->
    let features =
      [
        text "This use of `invariant` is unnecessary because "; ref reason; text " is always truthy.";
      ]
    in
    Normal { features }
  | ECannotSpreadInterface { spread_reason; interface_reason; use_op } ->
    let features =
      [
        text "Flow cannot determine a type for ";
        ref spread_reason;
        text ". ";
        ref interface_reason;
        text " cannot be spread because interfaces do not ";
        text "track the own-ness of their properties. Try using an object type instead";
      ]
    in
    UseOp { loc = loc_of_reason spread_reason; features; use_op }
  | ECannotSpreadIndexerOnRight { spread_reason; object_reason; key_reason; use_op } ->
    let features =
      [
        text "Flow cannot determine a type for ";
        ref spread_reason;
        text ". ";
        ref object_reason;
        text " cannot be spread because the indexer ";
        ref key_reason;
        text " may overwrite properties with explicit keys in a way that Flow cannot track. ";
        text "Try spreading ";
        ref object_reason;
        text " first or remove the indexer";
      ]
    in
    UseOp { loc = loc_of_reason spread_reason; features; use_op }
  | EUnableToSpread { spread_reason; object1_reason; object2_reason; propname; error_kind; use_op }
    ->
    let (error_reason, fix_suggestion) =
      match error_kind with
      | Inexact -> ("is inexact", [text " Try making "; ref object2_reason; text " exact"])
      | Indexer ->
        ( "has an indexer",
          [
            text " Try removing the indexer in ";
            ref object2_reason;
            text " or make ";
            code (display_string_of_name propname);
            text " a required property";
          ]
        )
    in
    let features =
      [
        text "Flow cannot determine a type for ";
        ref spread_reason;
        text ". ";
        ref object2_reason;
        text " ";
        text error_reason;
        text ", so it may contain ";
        code (display_string_of_name propname);
        text " with a type that conflicts with ";
        code (display_string_of_name propname);
        text "'s definition in ";
        ref object1_reason;
        text ".";
      ]
      @ fix_suggestion
    in
    UseOp { loc = loc_of_reason spread_reason; features; use_op }
  | EInexactMayOverwriteIndexer { spread_reason; key_reason; value_reason; object2_reason; use_op }
    ->
    let features =
      [
        text "Flow cannot determine a type for ";
        ref spread_reason;
        text ". ";
        ref object2_reason;
        text " is inexact and may ";
        text "have a property key that conflicts with ";
        ref key_reason;
        text " or a property value that conflicts with ";
        ref value_reason;
        text ". Try making ";
        ref object2_reason;
        text " exact";
      ]
    in
    UseOp { loc = loc_of_reason spread_reason; features; use_op }
  | EExponentialSpread { reason; reasons_for_operand1; reasons_for_operand2 } ->
    let format_reason_group { first_reason; second_reason } =
      match second_reason with
      | None -> [ref first_reason]
      | Some second_reason ->
        [text "inferred union from "; ref first_reason; text " | "; ref second_reason]
    in
    let union_refs =
      let reasons_for_operand1 = format_reason_group reasons_for_operand1 in
      let reasons_for_operand2 = format_reason_group reasons_for_operand2 in
      reasons_for_operand1 @ [text " and "] @ reasons_for_operand2
    in
    let features =
      [
        text "Computing ";
        ref reason;
        text " may lead to an exponentially large number of cases to reason about because ";
      ]
      @ union_refs
      @ [
          text
            " are both unions. Please use at most one union type per spread to simplify reasoning about the spread result.";
          text
            " You may be able to get rid of a union by specifying a more general type that captures all of the branches of the union.";
        ]
    in
    Normal { features }
  | EComputedPropertyWithMultipleLowerBounds
      { computed_property_reason; new_lower_bound_reason; existing_lower_bound_reason } ->
    let features =
      [
        text "Cannot use ";
        ref computed_property_reason;
        text " as a computed property.";
        text
          " Computed properties may only be primitive literal values, but this one may be either ";
        ref existing_lower_bound_reason;
        text " or ";
        ref new_lower_bound_reason;
        text ". Can you add a literal type annotation to ";
        ref computed_property_reason;
        text "?";
        text " See https://flow.org/en/docs/types/literals/ for more information on literal types.";
      ]
    in
    Normal { features }
  | EComputedPropertyWithUnion { computed_property_reason; union_reason } ->
    let features =
      [
        text "Cannot use ";
        ref computed_property_reason;
        text " as a computed property.";
        text " Computed properties may only be primitive literal values, but ";
        ref union_reason;
        text " is a union. Can you add a literal type annotation to ";
        ref computed_property_reason;
        text "?";
        text " See https://flow.org/en/docs/types/literals/ for more information on literal types.";
      ]
    in
    Normal { features }
  | EEnumInvalidMemberAccess { member_name; suggestion; reason; enum_reason } ->
    let features =
      [text "Cannot access "; desc reason]
      @
      match member_name with
      | Some name ->
        let name = display_string_of_name name in
        [text " because "; code name; text " is not a member of "; ref enum_reason; text "."]
        @ Base.Option.value_map suggestion ~default:[] ~f:(fun suggestion ->
              [text " Did you mean the member "; code suggestion; text "?"]
          )
      | None ->
        [text " on "; ref enum_reason; text " because computed access is not allowed on enums."]
    in
    Normal { features }
  | EEnumModification { enum_reason; _ } ->
    let features =
      [text "Cannot change member of "; ref enum_reason; text " because enums are frozen."]
    in
    Normal { features }
  | EEnumMemberDuplicateValue { prev_use_loc; enum_reason; _ } ->
    let features =
      [
        text "Invalid enum member initializer. Initializers need to be unique, but this one ";
        text "has already been used for a ";
        ref (mk_reason (RCustom "previous member") prev_use_loc);
        text " of ";
        ref enum_reason;
        text ".";
      ]
    in
    Normal { features }
  | EEnumInvalidObjectUtil { reason; enum_reason } ->
    let suggestion =
      match enum_name_of_reason enum_reason with
      | Some enum_name ->
        [
          text " ";
          text "You can use the enum's name ";
          code enum_name;
          text " as the type of its members.";
        ]
      | None -> []
    in
    let features =
      [
        text "Cannot instantiate ";
        desc reason;
        text " because ";
        ref enum_reason;
        text " is not an object.";
      ]
      @ suggestion
    in
    Normal { features }
  | EEnumNotIterable { reason; for_in } ->
    let features =
      if for_in then
        let suggestion =
          match enum_name_of_reason reason with
          | Some enum_name ->
            [
              text " ";
              text "You can use ";
              code (spf "for (... of %s.members()) { ... }" enum_name);
              text " to iterate over the enum's members.";
            ]
          | None -> []
        in
        [
          text "Cannot iterate using a ";
          code "for...in";
          text " loop because ";
          ref reason;
          text " is not an object, null, or undefined.";
        ]
        @ suggestion
      else
        let suggestion =
          match enum_name_of_reason reason with
          | Some enum_name ->
            [
              text " ";
              text "You can use ";
              code (spf "%s.members()" enum_name);
              text " to get an iterator for the enum's members.";
            ]
          | None -> []
        in
        [desc reason; text " is not an iterable."] @ suggestion
    in
    Normal { features }
  | EEnumMemberAlreadyChecked { reason; prev_check_reason; enum_reason; member_name } ->
    let features =
      [
        text "Invalid exhaustive check: ";
        desc reason;
        text " checks for enum member ";
        code member_name;
        text " of ";
        ref enum_reason;
        text ", but member ";
        code member_name;
        text " was already checked at ";
        ref prev_check_reason;
        text ".";
      ]
    in
    Normal { features }
  | EEnumAllMembersAlreadyChecked { reason; enum_reason } ->
    let features =
      [
        text "Invalid exhaustive check: ";
        desc reason;
        text " checks for additional enum members of ";
        ref enum_reason;
        text ", but all of its members have already been checked.";
      ]
    in
    Normal { features }
  | EEnumNotAllChecked { reason; enum_reason; left_to_check; default_case } ->
    let left_to_check_features =
      match left_to_check with
      | [member_to_check] ->
        [text "the member "; code member_to_check; text " of enum "; ref enum_reason; text " has"]
      | _ ->
        let number_to_check = List.length left_to_check in
        let members_features =
          if number_to_check > 5 then
            let max_display_amount = 4 in
            (Base.List.take left_to_check max_display_amount
            |> Base.List.bind ~f:(fun member -> [code member; text ", "])
            )
            @ [text (spf "and %d others" (number_to_check - max_display_amount))]
          else
            Friendly.conjunction_concat
              (Base.List.map ~f:(fun member -> [code member]) left_to_check)
        in
        (text "the members " :: members_features)
        @ [text " of enum "; ref enum_reason; text " have"]
    in
    let default_features =
      match default_case with
      | Some default_reason ->
        [
          text " The ";
          ref default_reason;
          text " does not check for the missing members as the ";
          code (Lints.string_of_kind Lints.RequireExplicitEnumSwitchCases);
          text " lint has been enabled.";
        ]
      | None -> []
    in
    let features =
      (text "Incomplete exhaustive check: " :: left_to_check_features)
      @ [text " not been considered in check of "; desc reason; text "."]
      @ default_features
    in
    Normal { features }
  | EEnumUnknownNotChecked { reason; enum_reason } ->
    let features =
      [
        text "Missing ";
        code "default";
        text " case in the check of ";
        desc reason;
        text ". ";
        ref enum_reason;
        text " has unknown members (specified using ";
        code "...";
        text ") so checking it requires the use of a ";
        code "default";
        text " case to cover those members.";
      ]
    in
    Normal { features }
  | EEnumInvalidCheck { reason; enum_reason; example_member } ->
    let suggestion =
      match enum_name_of_reason enum_reason with
      | Some enum_name ->
        let example_member = Base.Option.value ~default:"A" example_member in
        [text " "; text "For example "; code (spf "case %s.%s:" enum_name example_member); text "."]
      | None -> []
    in
    let features =
      [
        text "Invalid enum member check at ";
        desc reason;
        text ". Check must be dot-access of a member of ";
        ref enum_reason;
        text ".";
      ]
      @ suggestion
    in
    Normal { features }
  | EEnumMemberUsedAsType { reason; enum_reason } ->
    let features =
      [
        text "Cannot use ";
        desc reason;
        text " as a type. ";
        text "Enum members are not separate types. ";
        text "Only the enum itself, ";
        ref enum_reason;
        text ", is a type.";
      ]
    in
    Normal { features }
  | EEnumIncompatible { reason_lower; reason_upper; use_op; representation_type } ->
    let suggestion =
      match representation_type with
      | Some representation_type ->
        [
          text "You can explicitly cast your enum value to a ";
          text representation_type;
          text " using ";
          code (spf "(<expression>: %s)" representation_type);
        ]
      | None -> []
    in
    IncompatibleEnum { reason_lower; reason_upper; use_op; suggestion }
  | EAssignConstLikeBinding { definition; binding_kind; _ } ->
    let features =
      [
        text "Cannot reassign ";
        text (string_of_assigned_const_like_binding_type binding_kind);
        text " binding ";
        ref definition;
        text ".";
      ]
    in
    Normal { features }
  | EMalformedCode _ ->
    Normal
      {
        features =
          [
            text "Suppression contains a malformed error code. Suppressions with error codes ";
            text "should be formatted as ";
            code "$FlowFixMe[<CODE>]";
            text ".";
          ];
      }
  | EObjectThisReference (_, reason) ->
    Normal
      {
        features =
          [
            text "Cannot reference ";
            code "this";
            text " from within ";
            ref reason;
            text ". For safety, Flow restricts access to ";
            code "this";
            text " inside object methods since these methods may be unbound and rebound.";
            text " Consider replacing the reference to ";
            code "this";
            text " with the name of the object, or rewriting the object as a class.";
          ];
      }
  | EDuplicateClassMember { name; static; _ } ->
    let member_type =
      if static then
        "Static class"
      else
        "Class"
    in
    Normal
      {
        features =
          [
            code name;
            text " has already been declared in this class. ";
            text member_type;
            text " member names must be unique.";
          ];
      }
  | EEmptyArrayNoProvider { loc = _ } ->
    Normal
      {
        features =
          [text "Cannot determine type of empty array literal. Please provide an annotation."];
      }
  | EInvalidDeclaration { declaration = reason; null_write = None } ->
    Normal
      {
        features =
          [text "Variable "; ref reason; text " is never initialized, annotated, or assigned to."];
      }
  | EInvalidDeclaration { declaration = reason; null_write = Some { null_loc; initialized } } ->
    let null_ref =
      if initialized then
        code "null"
      else
        ref (mk_reason (RCode "null") null_loc)
    in
    Normal
      {
        features =
          [
            text "Variable ";
            ref reason;
            text " is only ever assigned to by ";
            null_ref;
            text ". This is likely unintended; if it is intended, annotate ";
            desc reason;
            text " with ";
            code ": null";
            text " to disambiguate.";
          ];
      }
  | EImplicitInstantiationTemporaryError (_, msg) -> Normal { features = [text msg] }
  | EImportInternalReactServerModule _ ->
    Normal
      {
        features =
          [
            text "Do not import ";
            code Type.react_server_module_ref;
            text " directly. Instead, ensure you are in a React Server file and import ";
            code "react";
            text " normally.";
          ];
      }
  | EImplicitInstantiationUnderconstrainedError { reason_call; reason_tparam; use_op; bound = _ } ->
    UseOp
      {
        use_op;
        features =
          [
            ref reason_tparam;
            text " is underconstrained by ";
            ref reason_call;
            text ". Either add explicit type arguments or cast the expression to your expected type";
          ];
        loc = loc_of_reason reason_call;
      }
  | EImplicitInstantiationWidenedError { reason_call; bound } ->
    Normal
      {
        features =
          [
            code bound;
            text " is possibly constrained by ";
            ref reason_call;
            text " and widened later.";
          ];
      }
  | EClassToObject (reason_class, reason_obj, use_op) ->
    let features =
      [
        ref reason_class;
        text " is not a subtype of ";
        ref reason_obj;
        text ". Class instances are not subtypes of object types; consider rewriting ";
        ref reason_obj;
        text " as an interface";
      ]
    in
    UseOp { loc = loc_of_reason reason_class; features; use_op }
  | EMethodUnbinding { use_op; reason_op; reason_prop } ->
    let context = Errors.Friendly.(Reference ([Text "context"], def_loc_of_reason reason_prop)) in
    UseOp
      {
        loc = loc_of_reason reason_op;
        features =
          [
            ref reason_op; text " cannot be unbound from the "; context; text " where it was defined";
          ];
        use_op;
      }
  | EInvalidGraphQL (_, err) ->
    let features =
      match err with
      | Graphql.InvalidTaggedTemplate ->
        [text "Template literal substitutions are not allowed in GraphQL literals."]
      | Graphql.InvalidGraphQL ->
        [text "Expected a GraphQL fragment, query, mutation, or subscription."]
    in
    Normal { features }
  | EAnnotationInference (_, reason_op, reason, suggestion) ->
    let suggestion =
      match suggestion with
      | Some util -> [text " (Try using the "; code util; text " utility type instead.)"]
      | None -> []
    in
    let features =
      [
        text "Cannot use ";
        desc (replace_desc_reason (desc_of_reason reason_op) reason_op);
        text " on ";
        ref (replace_desc_reason (Reason.desc_of_reason reason) reason);
        text " in an export position. ";
        text "Please provide an (alternative) annotation for ";
        ref reason_op;
        text ".";
      ]
      @ suggestion
    in
    Normal { features }
  | EAnnotationInferenceRecursive (_, reason) ->
    let features =
      [
        text "Invalid trivially recursive definition of ";
        desc reason;
        text " in an export position. ";
      ]
    in
    Normal { features }
  | ERecursiveDefinition { reason; recursion; annot_locs } ->
    let (itself, tl_recur) =
      match recursion with
      | hd :: tl ->
        let (suffix, tl) =
          if List.length tl > 4 then
            ([text ", [...]"], Base.List.take tl 4)
          else
            ([], tl)
        in
        ( ref (mk_reason (RCustom "itself") hd),
          (Base.List.map ~f:(fun loc -> [text ", "; ref (mk_reason (RCustom "") loc)]) tl
          |> List.flatten
          )
          @ suffix
        )
      | [] -> (text "itself", [])
    in
    let annot_message =
      match annot_locs with
      | [] -> [text "this definition"]
      | [Env_api.Loc loc]
      | [Env_api.Object { loc; props = [] }] ->
        [ref (mk_reason (RCustom "this definition") loc)]
      | [Env_api.Object { loc; props }] when List.length props > 5 ->
        [ref (mk_reason (RCustom "this definition") loc)]
      | [Env_api.Object { loc; props = [prop] }] ->
        [
          ref (mk_reason (RCustom "this definition") loc);
          text "or to";
          ref (mk_reason (RCustom "its property") prop);
        ]
      | [Env_api.Object { loc; props }] ->
        [ref (mk_reason (RCustom "this definition") loc); text " or to its properties"]
        @ Base.List.map ~f:(fun l -> ref (mk_reason (RCustom "") l)) props
      | ls ->
        let (locs, properties) =
          Base.List.fold
            ~init:([], [])
            ~f:(fun (locs, properties) annot_locs ->
              match annot_locs with
              | Env_api.Loc l -> (l :: locs, properties)
              | Env_api.Object { loc; props } -> (loc :: locs, props @ properties))
            ls
        in
        let (locs, properties) =
          ( Base.List.take (Base.List.dedup_and_sort ~compare:Loc.compare locs) 10,
            Base.List.dedup_and_sort ~compare:Loc.compare properties
          )
        in
        let props =
          if List.length properties <= 5 && List.length properties > 0 then
            let these =
              if List.length properties > 1 then
                text "these object properties"
              else
                text "this object property"
            in
            text " or to "
            :: these
            :: Base.List.map ~f:(fun l -> ref (mk_reason (RCustom "") l)) properties
          else
            []
        in
        (text "these definitions" :: Base.List.map ~f:(fun l -> ref (mk_reason (RCustom "") l)) locs)
        @ props
    in
    let features =
      [
        text "Cannot compute a type for ";
        desc reason;
        text " because its definition includes references to ";
        itself;
      ]
      @ tl_recur
      @ (text ". Please add an annotation to " :: annot_message)
    in
    Normal { features }
  | EDefinitionCycle dependencies ->
    let deps =
      Base.List.filter_mapi
        ~f:
          (fun i -> function
            | (_, [], _) -> None
            | _ when i = 10 -> Some [text " - ...\n"]
            | _ when i > 10 -> None
            | (reason, (_ :: _ as dep), _) ->
              let (hd, tl) = Base.List.dedup_and_sort ~compare:Loc.compare dep |> Nel.of_list_exn in
              let (suffix, tl) =
                if List.length tl > 4 then
                  ([text ", [...]"], Base.List.take tl 4)
                else
                  ([], tl)
              in
              let tl_dep =
                Base.List.map ~f:(fun loc -> [text ","; ref (mk_reason (RCustom "") loc)]) tl
                |> List.flatten
              in
              Some
                ([
                   text " - ";
                   ref reason;
                   text " depends on ";
                   ref (mk_reason (RCustom "other definition") hd);
                 ]
                @ tl_dep
                @ suffix
                @ [text "\n"]
                ))
        (Nel.to_list dependencies)
      |> List.flatten
    in
    let (locs, properties) =
      Base.List.fold
        ~init:([], [])
        ~f:(fun (locs, properties) (_, _, annot_locs) ->
          Base.List.fold annot_locs ~init:(locs, properties) ~f:(fun (locs, properties) annot_loc ->
              match annot_loc with
              | Env_api.Loc l -> (l :: locs, properties)
              | Env_api.Object { loc; props } -> (loc :: locs, props @ properties)
          ))
        (Nel.to_list dependencies)
    in
    let (locs, properties) =
      ( Base.List.take (Base.List.dedup_and_sort ~compare:Loc.compare locs) 10,
        Base.List.dedup_and_sort ~compare:Loc.compare properties
      )
    in
    let annot_message ls =
      Base.List.map ~f:(fun annot_loc -> ref (mk_reason (RCustom "") annot_loc)) ls
    in
    let features =
      text
        "The following definitions recursively depend on each other, and Flow cannot compute their types:\n"
      :: deps
      @ (text "Please add type annotations to these definitions" :: annot_message locs)
    in
    let features =
      if List.length properties <= 5 && List.length properties > 0 then
        features @ (text " or to these object properties" :: annot_message properties)
      else
        features
    in
    Normal { features }
  | EUnusedPromise { loc = _ } ->
    Normal
      {
        features =
          [
            code "Promise";
            text " in async scope is unused. Did you mean to ";
            code "await";
            text " it?";
          ];
      }
  | EBigIntRShift3 reason ->
    Normal
      {
        features =
          [
            text "Cannot perform unsigned right shift because ";
            ref reason;
            text " ";
            text "is a bigint, and all bigints are signed.";
          ];
      }
  | EBigIntNumCoerce reason ->
    Normal
      {
        features =
          [
            text "Cannot perform unary plus because a ";
            ref reason;
            text " ";
            text "cannot be coerced to number.";
          ];
      }
  | EInvalidCatchParameterAnnotation _ ->
    Normal
      {
        features =
          [
            text "Invalid catch parameter type annotation. ";
            text "Annotation must be ";
            code "any";
            text " or ";
            code "mixed";
            text " if specified.";
          ];
      }
  | ETSSyntax { kind; _ } -> begin
    match kind with
    | TSUnknown ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "unknown";
              text " type in Flow is ";
              code "mixed";
              text ".";
            ];
        }
    | TSNever ->
      Normal
        {
          features =
            [
              text "The closest equivalent of TypeScript's ";
              code "never";
              text " type in Flow is ";
              code "empty";
              text ".";
            ];
        }
    | TSUndefined ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "undefined";
              text " type in Flow is ";
              code "void";
              text ". ";
              text "Flow does not have separate ";
              code "void";
              text " and ";
              code "undefined";
              text " types.";
            ];
        }
    | TSKeyof ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "keyof";
              text " type operator in Flow is the ";
              code "$Keys";
              text " utility type, used in the form ";
              code "$Keys<T>";
              text ".";
            ];
        }
    | TSTypeParamExtends ->
      Normal
        {
          features =
            [
              text "While TypeScript uses ";
              code "extends";
              text " to specify type parameter bounds, Flow uses ";
              code ":";
              text " in the form ";
              code "type T<A: B> = ...";
              text ".";
            ];
        }
    | TSReadonlyVariance ->
      Normal
        {
          features =
            [
              text "While TypeScript uses ";
              code "readonly";
              text " to specify read only properties, Flow uses ";
              code "+";
              text " in the form ";
              code "+foo: T";
              text " for class and object type properties, and ";
              code "+[string]: T";
              text " for dictionaries.";
            ];
        }
    | TSInOutVariance `In ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "in";
              text " variance annotation is ";
              code "-";
              text " in Flow.";
            ];
        }
    | TSInOutVariance `Out ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "out";
              text " variance annotation is ";
              code "+";
              text " in Flow.";
            ];
        }
    | TSInOutVariance `InOut ->
      Normal
        {
          features =
            [
              text "The equivalent of TypeScript's ";
              code "in out";
              text " variance annotation in Flow is to simply leave it out - ";
              text "it's the default if you don't have a variance annotation.";
            ];
        }
    | TSTypeCast kind ->
      let keyword =
        match kind with
        | `AsConst
        | `As ->
          "as"
        | `Satisfies -> "satisfies"
      in
      let features =
        [
          text "The closest equivalent of TypeScript's ";
          code keyword;
          text " cast in Flow has the form ";
          code "(<expr>: <type>)";
          text " - using a colon and wrapped in parentheses.";
        ]
      in
      let features =
        if kind = `AsConst then
          features
          @ [
              text " ";
              text "Flow does not have an equivalent of ";
              code "as const";
              text ". ";
              text "Try adding an annotation instead.";
            ]
        else
          features
      in
      Normal { features }
    | TSReadonlyType (Some arg_kind) ->
      let (arg_type, example) =
        match arg_kind with
        | `Tuple -> ("a tuple", "$ReadOnly<[T, S]>")
        | `Array -> ("an array", "$ReadOnlyArray<T>")
      in
      let features =
        [
          text "The equivalent of TypeScript's ";
          code "readonly";
          text " type operator applied to ";
          text arg_type;
          text " type is ";
          code example;
          text ".";
        ]
      in
      Normal { features }
    | TSReadonlyType None ->
      let features =
        [
          text "TypeScript's ";
          code "readonly";
          text " type operator is not valid in Flow. ";
          text "For array types, you can use ";
          code "$ReadOnlyArray<T>";
          text ". For object and tuple types you can use ";
          code "$ReadOnly<T>";
          text ".";
        ]
      in
      Normal { features }
  end
  | EInvalidBinaryArith { reason_out = _; reason_l; reason_r; kind } ->
    Normal
      {
        features =
          [
            text "Cannot use operator `";
            text (Type.ArithKind.string_of_arith_kind kind);
            text "` with operands ";
            ref reason_l;
            text " and ";
            ref reason_r;
          ];
      }

let is_lint_error = function
  | EUntypedTypeImport _
  | EUntypedImport _
  | ENonstrictImport _
  | EUnclearType _
  | EDeprecatedBool _
  | EDeprecatedType _
  | EUnsafeGettersSetters _
  | ESketchyNullLint _
  | ESketchyNumberLint _
  | EUnnecessaryOptionalChain _
  | EUnnecessaryInvariant _
  | EImplicitInexactObject _
  | EAmbiguousObjectType _
  | EEnumNotAllChecked { default_case = Some _; _ }
  | EUninitializedInstanceProperty _
  | EUnusedPromise _ ->
    true
  | _ -> false

open Error_codes

let error_code_of_use_op use_op ~default =
  let code_of_root = function
    | Cast _ -> Some IncompatibleCast
    | ClassExtendsCheck _ -> Some IncompatibleExtend
    | FunCall _
    | FunCallMethod _ ->
      Some IncompatibleCall
    | FunReturnStatement _
    | FunImplicitReturn _ ->
      Some IncompatibleReturn
    | _ -> None
  in
  let code_of_frame acc frame =
    match (acc, frame) with
    | (Some _, _) -> acc
    | (_, TypeArgCompatibility _)
    | (_, TypeParamBound _) ->
      Some IncompatibleTypeArg
    | (_, CallFunCompatibility _) -> Some InvalidCallUtil
    | (_, TupleMapFunCompatibility _) -> Some InvalidTupleMap
    | (_, ObjMapFunCompatibility _) -> Some InvalidObjMap
    | (_, ObjMapiFunCompatibility _) -> Some InvalidObjMapi
    | (None, _) -> None
  in
  Base.Option.first_some (fold_use_op code_of_root code_of_frame use_op) (Some default)

let error_code_of_upper_kind = function
  | IncompatibleCallT -> Some NotAFunction
  | IncompatibleObjAssignFromTSpread
  | IncompatibleArrRestT ->
    Some NotAnArray
  | IncompatibleObjAssignFromT
  | IncompatibleObjRestT
  | IncompatibleGetKeysT
  | IncompatibleGetValuesT ->
    Some NotAnObject
  | IncompatibleMixinT
  | IncompatibleThisSpecializeT ->
    Some NotAClass
  | _ -> Some Error_codes.IncompatibleUse

let error_code_of_message err : error_code option =
  match err with
  | EAdditionMixed _ -> Some UnclearAddition
  | EArithmeticOperand _ -> Some UnsafeArith
  | EInvalidBinaryArith { kind = (_, op); _ } -> begin
    match op with
    | Type.ArithKind.Plus -> Some UnsafeAddition
    | _ -> Some UnsafeArith
  end
  | EAssignConstLikeBinding _ -> Some CannotReassignConstLike
  | EBadExportContext _ -> Some InvalidExport
  | EBadExportPosition _ -> Some InvalidExport
  | EBadDefaultImportAccess _ -> Some DefaultImportAccess
  | EBadDefaultImportDestructuring _ -> Some DefaultImportAccess
  | EInvalidImportStarUse _ -> Some InvalidImportStarUse
  | EBinaryInLHS _ -> Some InvalidInLhs
  | EBinaryInRHS _ -> Some InvalidInRhs
  | EBindingError (binding_error, _, _, _) -> begin
    match binding_error with
    | ENameAlreadyBound -> Some NameAlreadyBound
    | EVarRedeclaration -> Some NameAlreadyBound
    | EReferencedBeforeDeclaration -> Some ReferenceBeforeDeclaration
    | ETypeInValuePosition _
    | ETypeAliasInValuePosition ->
      Some TypeAsValue
    | EConstReassigned
    | EConstParamReassigned ->
      Some ReassignConst
    | EImportReassigned -> Some ReassignImport
    | EEnumReassigned -> Some ReassignEnum
  end
  | EBuiltinLookupFailed { name; _ } -> begin
    match name with
    | Some x when is_internal_module_name x -> Some CannotResolveModule
    | _ -> Some CannotResolveName
  end
  | ECallTypeArity _ -> Some NonpolymorphicTypeArg
  | ECannotDelete _ -> Some CannotDelete
  | ECannotResolveOpenTvar _ -> Some CannotInferType
  | ECannotSpreadIndexerOnRight _ -> Some CannotSpreadIndexer
  | ECannotSpreadInterface _ -> Some CannotSpreadInterface
  | ECharSetAnnot _ -> Some InvalidCharsetTypeArg
  | ECodelessSuppression _ -> None
  | ENonStrictEqualityComparison _
  | EComparison _ ->
    Some InvalidCompare
  | EComputedPropertyWithMultipleLowerBounds _ -> Some InvalidComputedProp
  | EComputedPropertyWithUnion _ -> Some InvalidComputedProp
  | EDebugPrint (_, _) -> None
  | EDocblockError (_, err) -> begin
    match err with
    | MultipleFlowAttributes -> Some DuplicateFlowDecl
    | InvalidFlowMode _ -> Some InvalidFlowModeDecl
    | MultipleProvidesModuleAttributes -> Some DuplicateProvideModuleDecl
    | MultipleJSXAttributes -> Some DuplicateJsxDecl
    | InvalidJSXAttribute _ -> Some InvalidJsxDecl
    | MultipleJSXRuntimeAttributes -> Some DuplicateJsxRuntimeDecl
    | InvalidJSXRuntimeAttribute -> Some InvalidJsxRuntimeDecl
  end
  | EDuplicateModuleProvider _ -> Some DuplicateModule
  | EEnumAllMembersAlreadyChecked _ -> Some InvalidExhaustiveCheck
  | EEnumInvalidCheck _ -> Some InvalidExhaustiveCheck
  | EEnumInvalidMemberAccess _ -> Some InvalidEnumAccess
  | EEnumInvalidObjectUtil _ -> Some NotAnObject
  | EEnumNotIterable _ -> Some NotIterable
  | EEnumMemberAlreadyChecked _ -> Some InvalidExhaustiveCheck
  | EEnumMemberDuplicateValue _ -> Some DuplicateEnumInit
  | EEnumMemberUsedAsType _ -> Some EnumValueAsType
  | EEnumModification _ -> Some CannotWriteEnum
  | EEnumNotAllChecked { default_case = None; _ } -> Some InvalidExhaustiveCheck
  | EEnumNotAllChecked { default_case = Some _; _ } -> Some RequireExplicitEnumSwitchCases
  | EEnumUnknownNotChecked _ -> Some InvalidExhaustiveCheck
  | EEscapedGeneric _ -> Some EscapedGeneric
  | EExpectedBooleanLit { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EExpectedNumberLit { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EExpectedStringLit { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EExpectedBigIntLit { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EEnumsNotEnabled _ -> Some IllegalEnum
  | EExponentialSpread _ -> Some ExponentialSpread
  | EExportsAnnot _ -> Some InvalidExportsTypeArg
  | EExportValueAsType (_, _) -> Some ExportValueAsType
  | EForInRHS _ -> Some InvalidInRhs
  | EInstanceofRHS _ -> Some InvalidInRhs
  | EFunctionCallExtraArg _ -> Some ExtraArg
  | EFunPredCustom (_, _) -> Some FunctionPredicate
  | EIdxArity _ -> Some InvalidIdx
  | EIdxUse _ -> Some InvalidIdx
  | EImportTypeAsTypeof (_, _) -> Some InvalidImportType
  | EImportTypeAsValue (_, _) -> Some ImportTypeAsValue
  | EImportValueAsType (_, _) -> Some ImportValueAsType
  | EIncompatible { upper = (_, upper_kind); branches = []; _ } ->
    error_code_of_upper_kind upper_kind
  | EIncompatible { use_op = Some use_op; _ } ->
    error_code_of_use_op use_op ~default:Error_codes.IncompatibleUse
  | EIncompatible _ -> Some Error_codes.IncompatibleUse
  | EIncompatibleDefs { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EIncompatibleProp { use_op = Some use_op; _ } ->
    error_code_of_use_op use_op ~default:IncompatibleType
  | EIncompatibleProp { use_op = None; _ } -> Some IncompatibleType
  | EIncompatibleWithExact (_, _, Inexact) -> Some IncompatibleExact
  | EIncompatibleWithExact (_, _, Indexer) -> Some IncompatibleIndexer
  | EFunctionIncompatibleWithIndexer _ -> Some IncompatibleFunctionIndexer
  | EIncompatibleWithShape _ -> Some IncompatibleShape
  | EEnumIncompatible { use_op; _ }
  | EIncompatibleWithUseOp { use_op; _ } ->
    error_code_of_use_op use_op ~default:IncompatibleType
  | EIndeterminateModuleType _ -> Some ModuleTypeConflict
  | EInexactMayOverwriteIndexer _ -> Some CannotSpreadInexact
  (* We don't want these to be suppressible *)
  | EInternal (_, _) -> None
  | EInvalidCharSet _ -> Some InvalidCharsetTypeArg
  | EInvalidConstructor _ -> Some InvalidConstructor
  | EInvalidConstructorDefinition _ -> Some InvalidConstructorDefinition
  | EInvalidLHSInAssignment _ -> Some InvalidLhs
  | EInvalidObjectKit _ -> Some NotAnObject
  | EInvalidPrototype _ -> Some NotAnObject
  | EInvalidReactConfigType _ -> Some InvalidReactConfig
  | EInvalidReactPropType _ -> Some InvalidPropType
  | EInvalidTypeArgs (_, _) -> Some InvalidTypeArg
  | EInvalidTypeof _ -> Some IllegalTypeof
  | EInvalidExtends _ -> Some InvalidExtends
  | ELintSetting _ -> Some LintSetting
  | EMissingAnnotation _ -> Some MissingAnnot
  | EMissingLocalAnnotation { reason; hint_available = _; from_generic_function = _ } -> begin
    match desc_of_reason reason with
    | RImplicitThis _ -> Some MissingThisAnnot
    | _ -> Some MissingLocalAnnot
  end
  | EMissingTypeArgs _ -> Some MissingTypeArg
  | EMixedImportAndRequire _ -> Some MixedImportAndRequire
  | EToplevelLibraryImport _ -> Some ToplevelLibraryImport
  | ENoDefaultExport (_, _, _) -> Some MissingExport
  | ENoNamedExport (_, _, _, _) -> Some MissingExport
  | ENonConstVarExport _ -> Some NonConstVarExport
  | ENonLitArrayToTuple _ -> Some InvalidTupleArity
  | ENotAReactComponent _ -> Some NotAComponent
  | EObjectComputedPropertyAccess (_, _) -> Some InvalidComputedProp
  | EObjectComputedPropertyAssign (_, _) -> Some InvalidComputedProp
  | EOnlyDefaultExport (_, _, _) -> Some MissingExport
  (* We don't want these to be suppressible *)
  | EParseError (_, _) -> None
  | EPolarityMismatch _ -> Some IncompatibleVariance
  | EPredAnnot _ -> Some InvalidPredTypeArg
  | EPrivateAnnot _ -> Some InvalidPrivateTypeArg
  | EPrivateLookupFailed _ -> Some Error_codes.PropMissing
  | EPropertyTypeAnnot _ -> Some InvalidPropertyTypeArg
  | EPropNotFound _ -> Some Error_codes.PropMissing
  | EPropNotReadable _ -> Some CannotRead
  | EPropNotWritable _ -> Some CannotWrite
  | EPropPolarityMismatch _ -> Some IncompatibleVariance
  | EReactElementFunArity (_, _, _) -> Some MissingArg
  (* We don't want these to be suppressible *)
  | ERecursionLimit (_, _) -> None
  | ERefineAnnot _ -> Some InvalidRefineTypeArg
  | ERefineAsValue (_, _) -> Some RefineAsValue
  | EROArrayWrite _ -> Some CannotWrite
  | ESignatureVerification _ -> Some SignatureVerificationFailure
  | ESpeculationAmbiguous _ -> Some SpeculationAmbiguous
  | EStrictLookupFailed _ -> Some Error_codes.PropMissing
  | EThisInExportedFunction _ -> Some ThisInExportedFunction
  | EExportRenamedDefault _ -> Some ExportRenamedDefault
  | ETooFewTypeArgs (_, _, _) -> Some MissingTypeArg
  | ETooManyTypeArgs (_, _, _) -> Some ExtraTypeArg
  | ETrustedAnnot _ -> Some InvalidTrustedTypeArg
  | ETrustIncompatibleWithUseOp _ -> Some Error_codes.IncompatibleTrust
  | ETupleArityMismatch _ -> Some InvalidTupleArity
  | ETupleElementNotReadable _ -> Some CannotRead
  | ETupleElementNotWritable _ -> Some CannotWrite
  | ETupleElementPolarityMismatch _ -> Some IncompatibleVariance
  | ETupleNonIntegerIndex _ -> Some InvalidTupleIndex
  | ETupleOutOfBounds _ -> Some InvalidTupleIndex
  | ETupleUnsafeWrite _ -> Some InvalidTupleIndex
  | ETypeParamArity (_, _) -> Some NonpolymorphicTypeApp
  | ETypeParamMinArity (_, _) -> Some MissingTypeArg
  | EUnableToSpread { error_kind; _ } -> begin
    match error_kind with
    | Inexact -> Some CannotSpreadInexact
    | Indexer -> Some CannotSpreadIndexer
  end
  | EUnexpectedTemporaryBaseType _ -> Some InvalidTempType
  | EUnexpectedThisType _ -> Some IllegalThis
  | EUnionSpeculationFailed { use_op; _ } -> error_code_of_use_op use_op ~default:IncompatibleType
  | EUnreachable _ -> Some UnreachableCode
  | EUnsafeGetSet _ -> Some IllegalGetSet
  | EUnsupportedExact (_, _) -> Some InvalidExact
  | EUnsupportedImplements _ -> Some CannotImplement
  | EUnsupportedKeyInObjectType _ -> Some IllegalKey
  | EUnsupportedSetProto _ -> Some CannotWrite
  | EUnsupportedSyntax (_, _) -> Some UnsupportedSyntax
  | EImplicitInstantiationUnderconstrainedError _ -> Some UnderconstrainedImplicitInstantiation
  | EImplicitInstantiationWidenedError _ -> None
  | EObjectThisReference _ -> Some ObjectThisReference
  | EInvalidDeclaration _ -> Some InvalidDeclaration
  | EMalformedCode _
  | EImplicitInstantiationTemporaryError _
  | EUnusedSuppression _
  | EImportInternalReactServerModule _ ->
    None
  | EUseArrayLiteral _ -> Some IllegalNewArray
  | EAnyValueUsedAsType _
  | EValueUsedAsType _ ->
    Some ValueAsType
  | EClassToObject _ -> Some ClassObject
  | EMethodUnbinding _ -> Some MethodUnbinding
  | EInvalidGraphQL _ -> Some InvalidGraphQL
  | EAnnotationInference _ -> Some InvalidExportedAnnotation
  | EAnnotationInferenceRecursive _ -> Some InvalidExportedAnnotationRecursive
  | EDefinitionCycle _ -> Some DefinitionCycle
  | ERecursiveDefinition _ -> Some RecursiveDefinition
  | EDuplicateClassMember _ -> Some DuplicateClassMember
  | EEmptyArrayNoProvider _ -> Some EmptyArrayNoAnnot
  | EBigIntRShift3 _ -> Some BigIntRShift3
  | EBigIntNumCoerce _ -> Some BigIntNumCoerce
  | EInvalidCatchParameterAnnotation _ -> Some InvalidCatchParameterAnnotation
  (* lints should match their lint name *)
  | EUntypedTypeImport _
  | EUntypedImport _
  | ENonstrictImport _
  | EUnclearType _
  | EDeprecatedBool _
  | EDeprecatedType _
  | EUnsafeGettersSetters _
  | ESketchyNullLint _
  | ESketchyNumberLint _
  | EUnnecessaryOptionalChain _
  | EUnnecessaryInvariant _
  | EImplicitInexactObject _
  | EAmbiguousObjectType _
  | EUninitializedInstanceProperty _
  | EUnusedPromise _ -> begin
    match kind_of_msg err with
    | Errors.LintError kind -> Some (Error_codes.code_of_lint kind)
    | _ -> None
  end
  | ETSSyntax _ -> Some TSSyntax
