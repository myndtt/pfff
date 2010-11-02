(* Yoann Padioleau
 *
 * Copyright (C) 2010 Facebook
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * version 2.1 as published by the Free Software Foundation, with the
 * special exception on linking described in file license.txt.
 * 
 * This library is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the file
 * license.txt for more details.
 *)

open Common

open Ocaml

open Pil

(*****************************************************************************)
(* Prelude *)
(*****************************************************************************)

(*****************************************************************************)
(* Side effect style visitor *)
(*****************************************************************************)

type visitor_in = {
  kvar: var vin;
  klvalue: lvalue vin;
  kexpr: expr vin;
  kinstr: instr vin;
  kstmt: stmt vin;
}
and visitor_out = {
  vstmt: stmt vout;
  vstmt_list: (stmt list) vout;
}
and 'a vin = ('a  -> unit) * visitor_out -> 'a  -> unit
and 'a vout = 'a -> unit


let default_visitor = { 
  kvar = (fun (k,_) x -> k x);
  klvalue = (fun (k,_) x -> k x);
  kexpr   = (fun (k,_) x -> k x);
  kinstr   = (fun (k,_) x -> k x);
  kstmt   = (fun (k,_) x -> k x);
}

let (mk_visitor: visitor_in -> visitor_out) = fun vin ->

(* TODO ? *)
let rec v_dname _ = ()
and v_tok _ = ()
and v_type_info _ = ()
and v_qualifier _ = ()
and v_name _ = ()
and v_indirect _ = ()
and v_constant _ = ()
and v_binaryOp _ = ()
and v_unaryOp _ = ()
and v_castOp _ = ()
and v_class_name_reference _ = ()
and v_assignOp _ = ()

 (* start of auto generation *)

and v_var x = 
  let k = function
  | Var v1 -> let v1 = v_dname v1 in ()
  | This v1 -> let v1 = v_tok v1 in ()
  in
  vin.kvar (k, all_functions) x

and v_lvalue x = 
  let k = fun (v1, v2) ->
    let v1 = v_lvaluebis v1 and v2 = v_type_info v2 in ()
  in
  vin.klvalue (k, all_functions) x

and v_lvaluebis =
  function
  | VVar v1 -> let v1 = v_var v1 in ()
  | VQualifier ((v1, v2)) -> let v1 = v_qualifier v1 and v2 = v_var v2 in ()
  | ArrayAccess ((v1, v2)) ->
      let v1 = v_var v1 and v2 = v_option v_expr v2 in ()
  | ObjAccess ((v1, v2)) -> let v1 = v_var v1 and v2 = v_name v2 in ()
  | DynamicObjAccess ((v1, v2)) -> let v1 = v_var v1 and v2 = v_var v2 in ()
  | IndirectAccess ((v1, v2)) ->
      let v1 = v_var v1 and v2 = v_indirect v2 in ()

and v_expr x =
  let k = fun (v1, v2) -> let v1 = v_exprbis v1 and v2 = v_type_info v2 
    in ()
  in
  vin.kexpr (k, all_functions) x
and v_exprbis =
  function
  | Lv v1 -> let v1 = v_lvalue v1 in ()
  | C v1 -> let v1 = v_constant v1 in ()
  | ClassConstant v1 ->
      let v1 =
        (match v1 with
         | (v1, v2) -> let v1 = v_qualifier v1 and v2 = v_name v2 in ())
      in ()
  | Binary ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_binaryOp v2 and v3 = v_expr v3 in ()
  | Unary ((v1, v2)) -> let v1 = v_unaryOp v1 and v2 = v_expr v2 in ()
  | CondExpr ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_expr v2 and v3 = v_expr v3 in ()
  | ConsArray v1 -> let v1 = v_list v_expr v1 in ()
  | ConsHash v1 ->
      let v1 =
        v_list (fun (v1, v2) -> let v1 = v_expr v1 and v2 = v_expr v2 in ())
          v1
      in ()
  | Cast ((v1, v2)) -> let v1 = v_castOp v1 and v2 = v_expr v2 in ()
  | InstanceOf ((v1, v2)) ->
      let v1 = v_expr v1 and v2 = v_class_name_reference v2 in ()

and v_instr x =
 let k = function
  | Assign ((v1, v2, v3)) ->
      let v1 = v_lvalue v1 and v2 = v_assign_kind v2 and v3 = v_expr v3 in ()
  | AssignRef ((v1, v2)) -> let v1 = v_lvalue v1 and v2 = v_lvalue v2 in ()
  | Call ((v1, v2, v3)) ->
      let v1 = v_lvalue v1
      and v2 = v_call_kind v2
      and v3 = v_list v_argument v3
      in ()
  | Eval v1 -> let v1 = v_expr v1 in ()
 in
 vin.kinstr (k, all_functions) x

and v_assign_kind =
  function | AssignEq -> () | AssignOp v1 -> let v1 = v_assignOp v1 in ()
and v_call_kind =
  function
  | SimpleCall v1 -> let v1 = v_name v1 in ()
  | StaticMethodCall ((v1, v2)) ->
      let v1 = v_qualifier v1 and v2 = v_name v2 in ()
  | MethodCall ((v1, v2)) -> let v1 = v_var v1 and v2 = v_name v2 in ()
  | DynamicCall ((v1, v2)) ->
      let v1 = v_option v_qualifier v1 and v2 = v_var v2 in ()
  | DynamicMethodCall ((v1, v2)) -> let v1 = v_var v1 and v2 = v_var v2 in ()
  | New v1 -> let v1 = v_class_name_reference v1 in ()
and v_argument =
  function
  | Arg v1 -> let v1 = v_expr v1 in ()
  | ArgRef v1 -> let v1 = v_lvalue v1 in ()

and v_stmt x =
 let k = function
  | Instr v1 -> let v1 = v_instr v1 in ()
  | Block v1 -> let v1 = v_list v_stmt v1 in ()
  | EmptyStmt -> ()
  | If ((v1, v2, v3)) ->
      let v1 = v_expr v1 and v2 = v_stmt v2 and v3 = v_stmt v3 in ()
  | While ((v1, v2)) -> let v1 = v_expr v1 and v2 = v_stmt v2 in ()
  | Break v1 -> let v1 = v_option v_expr v1 in ()
  | Continue v1 -> let v1 = v_option v_expr v1 in ()
  | Return v1 -> let v1 = v_option v_expr v1 in ()
  | Throw v1 -> let v1 = v_expr v1 in ()
  | Try ((v1, v2)) -> let v1 = v_stmt v1 and v2 = v_catch v2 in ()
  | Echo v1 -> let v1 = v_list v_expr v1 in ()
 in
 vin.kstmt (k, all_functions) x

 and v_catch v = v_unit v

 and v_stmt_list xs = List.iter v_stmt xs

 and all_functions =   
    {
      vstmt = v_stmt;
      vstmt_list = v_stmt_list;
    }
  in
  all_functions


let do_visit_with_ref mk_hooks recursor = 
  let res = ref [] in
  let hooks = mk_hooks res in
  begin
    let vout = mk_visitor hooks in
    recursor vout;
    !res
  end

let do_visit_with_h mk_hooks recursor = 
  let h = Hashtbl.create 101 in
  let hooks = mk_hooks h in
  begin 
    let vout = mk_visitor hooks in
    recursor vout;
    h
  end
