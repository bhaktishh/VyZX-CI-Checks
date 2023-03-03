Require Import CoreData.CoreData.
Require Import castRules.
Require Import SpiderInduction.
Require Export StackRules.
Require Export WireRules.
Require Export ComposeRules.

Local Open Scope ZX_scope.
Lemma nwire_stack_compose_topleft : forall {topIn botIn topOut botOut} 
                       (zx0 : ZX botIn botOut) (zx1 : ZX topIn topOut),
((nWire topIn) ↕ zx0) ⟷ (zx1 ↕ (nWire botOut)) ∝ 
(zx1 ↕ zx0).
Proof.
  intros.
  prop_exists_nonzero 1.
  simpl.
  repeat rewrite nWire_semantics.
  Msimpl.
  easy.
Qed.

Lemma nwire_stack_compose_botleft : forall {topIn botIn topOut botOut} 
                       (zx0 : ZX botIn botOut) (zx1 : ZX topIn topOut),
(zx0 ↕ (nWire topIn)) ⟷ ((nWire botOut) ↕ zx1) ∝ 
(zx0 ↕ zx1).
Proof.
  intros.
  prop_exists_nonzero 1.
  simpl.
  repeat rewrite nWire_semantics.
  Msimpl.
  easy.
Qed.

Lemma push_out_top : forall {nIn nOut nOutAppendix} (appendix : ZX 0 nOutAppendix) (zx : ZX nIn nOut), appendix ↕ zx ∝ zx ⟷ (appendix ↕ (nWire nOut)).
Proof.
  intros.
  rewrite <- (ZX_Stack_Empty_l zx) at 2.
  replace ⦰ with (nWire 0) by easy.
  rewrite (nwire_stack_compose_topleft zx appendix).
  easy.
Qed.

Lemma push_out_bot : forall {nIn nOut nOutAppendix} (appendix : ZX 0 nOutAppendix) (zx : ZX nIn nOut), zx ↕ appendix ∝ (cast _ _ (Nat.add_0_r _) (Nat.add_0_r _) zx) ⟷ ((nWire nOut) ↕ appendix).
Proof.
  intros.
  rewrite (ZX_Stack_Empty_r_rev ($ _, _ ::: zx $)).
  replace ⦰ with (nWire 0) by easy.
  prop_exists_nonzero 1.
  simpl.
  simpl_cast_semantics.
  simpl.
  simpl_cast_semantics.
  restore_dims.
  rewrite kron_mixed_product.
  rewrite nWire_semantics.
  Msimpl.
  easy.
Qed.

Lemma pull_out_top : forall {nIn nOut nInAppendix} (appendix : ZX nInAppendix 0) (zx : ZX nIn nOut), appendix ↕ zx ∝ (appendix ↕ (nWire nIn)) ⟷ zx.
Proof.
  intros.
  rewrite <- (ZX_Stack_Empty_l zx) at 2.
  replace ⦰ with (nWire 0) by easy.
  rewrite (nwire_stack_compose_botleft appendix zx).
  easy.
Qed.

Lemma pull_out_bot : forall {nIn nOut nInAppendix} (appendix : ZX nInAppendix 0) (zx : ZX nIn nOut), zx ↕ appendix ∝ ((nWire nIn) ↕ appendix) ⟷ (cast _ _ (Nat.add_0_r _) (Nat.add_0_r _) zx).
Proof.
  intros.
  rewrite (ZX_Stack_Empty_r_rev ($ _, _ ::: zx $)).
  replace ⦰ with (nWire 0) by easy.
  prop_exists_nonzero 1.
  simpl.
  simpl_cast_semantics.
  simpl.
  simpl_cast_semantics.
  restore_dims.
  rewrite kron_mixed_product.
  rewrite nWire_semantics.
  Msimpl.
  easy.
Qed.

Lemma disconnected_stack_compose_l : forall {n m} (zxIn : ZX n 0) (zxOut : ZX 0 m), zxIn ↕ zxOut ∝ cast _ _ (@Nat.add_0_r _) (eq_refl) (zxIn ⟷ zxOut).
Proof.
  intros.
  rewrite <- (ZX_Compose_Empty_l zxOut) at 1.
  rewrite <- (ZX_Compose_Empty_r zxIn) at 1.
  rewrite ZX_Stack_Compose_distr.
  rewrite ZX_Stack_Empty_l.
  rewrite ZX_Stack_Empty_r.
  rewrite cast_compose_l.
  simpl_casts.
  easy.
Qed.

Lemma disconnected_stack_compose_r : forall {n m} (zxIn : ZX n 0) (zxOut : ZX 0 m), zxOut ↕ zxIn ∝ cast _ _ (eq_refl) (@Nat.add_0_r _) (zxIn ⟷ zxOut).
Proof.
  intros.
  rewrite <- (ZX_Compose_Empty_l zxOut) at 1.
  rewrite <- (ZX_Compose_Empty_r zxIn) at 1.
  rewrite ZX_Stack_Compose_distr.
  rewrite ZX_Stack_Empty_l.
  rewrite ZX_Stack_Empty_r.
  rewrite cast_compose_r.
  simpl_casts.
  easy.
Qed.