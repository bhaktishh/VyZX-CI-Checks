Require Import externals.QuantumLib.Quantum.
Require Export ZX.
Require Export Gates.


Lemma ZX_H_is_H : ZX_semantics ZX_H = Cexp (PI/4)%R .* hadamard.
Proof.
  simpl.
  unfold Spider_Semantics_Impl, bra_ket_MN.
  solve_matrix; 
  field_simplify_eq [Cexp_PI2 Cexp_PI4 Ci2 Csqrt2_sqrt2_inv Csqrt2_inv]; 
  try apply c_proj_eq; try simpl; try R_field_simplify; try reflexivity; (try split; try apply RtoC_neq; try apply sqrt2_neq_0; try auto).
Qed.

Lemma ZX_H_H_is_Wire : ZX_semantics (Compose ZX_H ZX_H) = Cexp (PI/2)%R .* ZX_semantics Wire.
Proof.
  Opaque ZX_H.
  simpl.
  Transparent ZX_H.
  rewrite wire_identity_semantics.
  rewrite ZX_H_is_H.
  rewrite Mscale_mult_dist_l.
  rewrite Mscale_mult_dist_r.
  rewrite MmultHH.
  rewrite Mscale_assoc.
  rewrite <- Cexp_add.
  assert ((PI/4+PI/4 = PI/2)%R) as H by lra.
  rewrite H.
  reflexivity.
Qed.

Local Open Scope R_scope.
Lemma ZX_CNOT_l_is_cnot : ZX_semantics ZX_CNOT_l = (/ √ 2)%C .* cnot.
Proof.
  simpl.
  unfold Spider_Semantics_Impl, bra_ket_MN.
  rewrite wire_identity_semantics.
  rewrite Cexp_0.
  solve_matrix.
Qed.

Lemma ZX_CNOT_r_is_cnot : ZX_semantics ZX_CNOT_r = (/ √ 2)%C .* cnot.
Proof.
  simpl.
  unfold Spider_Semantics_Impl, bra_ket_MN.
  rewrite wire_identity_semantics.
  rewrite Cexp_0.
  solve_matrix.
Qed.

Lemma ZX_CNOT_equiv : ZX_semantics ZX_CNOT_l = ZX_semantics ZX_CNOT_r.
Proof.
  rewrite ZX_CNOT_l_is_cnot.
  rewrite <- ZX_CNOT_r_is_cnot.
  reflexivity.
Qed.

Local Close Scope R_scope.