Require Import QuantumLib.Quantum.
Require Import QuantumLib.Proportional.
Require Import QuantumLib.VectorStates.

From VyZX Require Export SemanticCore.

(** Base constructions for the ZX calculus, lets us build every diagram inductively.
    We have included some "unnecessary" objects because they are common and useful. *)

Declare Scope ZX_scope.
Delimit Scope ZX_scope with ZX.
Open Scope ZX_scope.

Inductive ZX : nat -> nat -> Type :=
  | Empty : ZX 0 0
  | Cap  : ZX 0 2
  | Cup  : ZX 2 0
  | Swap : ZX 2 2
  | Wire : ZX 1 1
  | Box  : ZX 1 1
  | X_Spider n m (α : R) : ZX n m
  | Z_Spider n m (α : R) : ZX n m
  | Stack {n_0 m_0 n_1 m_1} (zx0 : ZX n_0 m_0) (zx1 : ZX n_1 m_1) : ZX (n_0 + n_1) (m_0 + m_1)
  | Compose {n m o} (zx0 : ZX n m) (zx1 : ZX m o) : ZX n o
  | Cast (n m : nat) {n' m'} (eqIn : n = n') (eqOut : m = m') (zx : ZX n' m') : ZX n m.

(* Notations for the ZX diagrams *)
Notation "⦰" := Empty : ZX_scope. (* \revemptyset *)
Notation "⊂" := Cap : ZX_scope. (* \subset *)
Notation "⊃" := Cup : ZX_scope. (* \supset *)
Notation "⨉" := Swap : ZX_scope. (* \bigtimes *)
Notation "—" := Wire : ZX_scope. (* \emdash *)
Notation "□" := Box : ZX_scope. (* \square *)
Notation "A ⟷ B" := (Compose A B) (left associativity, at level 40) : ZX_scope. (* \longleftrightarrow *)
Notation "A ↕ B" := (Stack A B) (left associativity, at level 40) : ZX_scope. (* \updownarrow *)
Notation "'Z'" := Z_Spider (left associativity, at level 40) : ZX_scope.
Notation "'X'" := X_Spider (left associativity, at level 40) : ZX_scope.
Notation "$ A" := (Cast _ _ _ _ A) (at level 49) : ZX_scope.

(** We provide two separate options for semantic functions, one based on sparse matrices
    and one based on dirac notation. *)

Fixpoint ZX_semantics {n m} (zx : ZX n m) : 
  Matrix (2 ^ m) (2 ^n) := 
  match zx with
  | ⦰ => I 1
  | X _ _ α => X_semantics n m α
  | Z _ _ α => Z_semantics n m α
  | ⊃ => list2D_to_matrix [[C1;C0;C0;C1]]
  | ⊂ => list2D_to_matrix [[C1];[C0];[C0];[C1]]  
  | ⨉ => swap
  | — => I 2
  | □ => hadamard
  | zx0 ↕ zx1 => (ZX_semantics zx0) ⊗ (ZX_semantics zx1) 
  | Compose zx0 zx1 => (ZX_semantics zx1) × (ZX_semantics zx0)
  | $ zx => ZX_semantics zx
  end.

Fixpoint ZX_dirac_sem {n m} (zx : ZX n m) : 
  Matrix (2 ^ m) (2 ^n) := 
  match zx with
  | ⦰ => I 1
  | X _ _ α => X_dirac_semantics n m α
  | Z _ _ α => Z_dirac_semantics n m α
  | ⊃ => list2D_to_matrix [[C1;C0;C0;C1]]
  | ⊂ => list2D_to_matrix [[C1];[C0];[C0];[C1]]  
  | ⨉ => swap
  | — => I 2
  | □ => hadamard
  | zx0 ↕ zx1 => (ZX_dirac_sem zx0) ⊗ (ZX_dirac_sem zx1)
  | zx0 ⟷ zx1 => (ZX_dirac_sem zx1) × (ZX_dirac_sem zx0)
  | $ zx => ZX_dirac_sem zx
  end.

Lemma ZX_semantic_equiv : forall n m (zx : ZX n m),
  ZX_semantics zx = ZX_dirac_sem zx.
Proof.
  intros.
  induction zx; try lma; simpl.
  rewrite X_semantics_equiv; reflexivity.
  rewrite Z_semantics_equiv; reflexivity.
  1,2: subst; rewrite IHzx1, IHzx2; reflexivity.
  assumption.
Qed.

Theorem WF_ZX : forall nIn nOut (zx : ZX nIn nOut), WF_Matrix (ZX_semantics zx).
Proof.
  intros.
  induction zx; try (simpl; auto 10 with wf_db).
  1,2: try (simpl; auto 10 with wf_db);
    apply WF_list2D_to_matrix;
    try easy; (* case list of length 4 *)
    try intros; simpl in H; repeat destruct H; try discriminate; try (subst; easy). (* Case of 4 lists length 1 *)
    subst; easy.
Qed.

#[export] Hint Resolve WF_ZX : wf_db.

(* Parametrized diagrams *)

Reserved Notation "n ⇑ zx" (at level 40). (* \Uparrow - maybe change to ⇕ (\Updownarrow) *)
Fixpoint nStack {nIn nOut} n (zx : ZX nIn nOut) : ZX (n * nIn) (n * nOut) :=
  match n with
  | 0 => ⦰
  | S n' => zx ↕ (n' ⇑ zx)
  end
  where "n ⇑ zx" := (nStack n zx).

Reserved Notation "n ↑ zx" (at level 41).
Fixpoint nStack1 n (zx : ZX 1 1) : ZX n n :=
  match n with
  | 0 => ⦰
  | S n' => zx ↕ (n' ↑ zx)
  end
  where "n ↑ zx" := (nStack1 n zx).

Lemma nStack1_n_kron : forall n (zx : ZX 1 1), ZX_semantics (n ↑ zx) = n ⨂ ZX_semantics zx.
Proof.
  intros.
  induction n.
  - unfold nStack. reflexivity.
  - simpl.
    rewrite IHn.
    restore_dims.
    rewrite <- kron_n_assoc; auto.
    apply WF_ZX.
Qed.

Definition nWire := fun n => n ↑ Wire.
Definition nBox := fun n => n ↑ Box.

Lemma nWire_semantics {n} : ZX_semantics (nWire n) = I (2^n).
Proof.
  induction n; auto.
  simpl.
  unfold nWire in IHn.
  rewrite IHn.
  rewrite id_kron.
  auto.
Qed.

Lemma nBox_semantics {n} : ZX_semantics (nBox n) = n ⨂ hadamard.
Proof.
  induction n; auto.
  simpl.
  unfold nBox in IHn.
  rewrite IHn.
  rewrite <- kron_n_assoc by auto with wf_db.
  auto.
Qed.

#[export] Hint Rewrite @nWire_semantics @nBox_semantics : zx_sem_db.

(** Global operations on ZX diagrams *)

(* Transpose of a diagram *)

Reserved Notation "zx ⊤" (at level 0). (* \top *)
Fixpoint transpose {nIn nOut} (zx : ZX nIn nOut) : ZX nOut nIn :=
  match zx with
  | ⦰ => ⦰
  | Z mIn mOut α => Z mOut mIn α
  | X mIn mOut α => X mOut mIn α
  | zx0 ⟷ zx1 => (zx1 ⊤) ⟷ (zx0 ⊤)
  | zx1 ↕ zx2 => (zx1 ⊤) ↕ (zx2 ⊤)
  | ⊂ => ⊃
  | ⊃ => ⊂
  | Cast n m prfn prfm zx => Cast m n prfm prfn (zx ⊤) 
  | other => other
  end
  where "zx ⊤" := (transpose zx) : ZX_scope.

Lemma transpose_involutive_eq : forall {nIn nOut} (zx : ZX nIn nOut),
  zx = (zx ⊤)⊤.
Proof.
  intros; induction zx; try auto.
  1,2: simpl; rewrite <- IHzx1, <- IHzx2; try rewrite eq_sym_involutive; auto.
  subst; simpl; rewrite <- IHzx.
  reflexivity.
Qed.

(* Negating the angles of a diagram, complex conjugate *)

Reserved Notation "zx ^*" (at level 10).
Fixpoint conjugate {n m} (zx : ZX n m) : ZX n m :=
  match zx with
  | Z n m α => Z n m (-α)
  | X n m α => X n m (-α)
  | zx0 ⟷ zx1 => (zx0^*) ⟷ (zx1^*)
  | zx1 ↕ zx2 => zx1^* ↕ zx2^*
  | Cast n m prfn prfm zx => Cast n m prfn prfm (zx ^*)
  | other => other
  end
  where "zx ^*" := (conjugate zx) : ZX_scope.

Definition adjoint {n m} (zx : ZX n m) : ZX m n :=
  (zx^*)⊤.
Notation "zx †" := (adjoint zx) (at level 0) : ZX_scope.

Lemma ZX_semantics_transpose_comm {nIn nOut} : forall (zx : ZX nIn nOut),
  ZX_semantics (zx ⊤) = ((ZX_semantics zx) ⊤)%M.
Proof.
  assert (Mmult_trans_dep : forall n m o p (A : Matrix n m) (B : Matrix o p), m = o -> ((A × B) ⊤ = B ⊤ × A ⊤)%M).
    {
      intros; rewrite Mmult_transpose; rewrite H in *; reflexivity.      
    }
  induction zx.
  - Msimpl; reflexivity.
  - simpl; solve_matrix.
  - simpl; solve_matrix.
  - simpl; lma.
  - simpl; rewrite id_transpose_eq; reflexivity.
  - simpl; rewrite hadamard_st; reflexivity.
  - simpl; rewrite X_semantics_transpose; reflexivity.
  - simpl; rewrite Z_semantics_transpose; reflexivity.
  - simpl; rewrite IHzx1, IHzx2; rewrite <- kron_transpose; reflexivity.
  - simpl; rewrite IHzx1, IHzx2; restore_dims; rewrite Mmult_transpose; reflexivity.
  - subst; simpl; auto.
Qed.

Lemma ZX_semantics_adjoint_comm {nIn nOut} : forall (zx : ZX nIn nOut),
  ZX_semantics (zx †) = (ZX_semantics zx) †%M.
Proof.
  intros.
  induction zx.
  - simpl; Msimpl; reflexivity.
  - simpl; solve_matrix.
  - simpl; solve_matrix.
  - simpl; lma.
  - simpl; Msimpl; reflexivity.
  - simpl; lma.
  - simpl; rewrite X_semantics_adj; reflexivity.
  - simpl; rewrite Z_semantics_adj; reflexivity.
  - simpl; fold (zx1†); fold (zx2†); rewrite IHzx1, IHzx2; rewrite <- kron_adjoint; reflexivity.
  - simpl; fold (zx1†); fold(zx2†); rewrite IHzx1, IHzx2; restore_dims; rewrite Mmult_adjoint; reflexivity.
  - subst; simpl; auto.
Qed.

Opaque adjoint.

Reserved Notation "⊙ zx" (at level 10). (* \odot *) 
Fixpoint ColorSwap {nIn nOut} (zx : ZX nIn nOut) : ZX nIn nOut := 
  match zx with
  | X n m α   => Z n m α
  | Z n m α   => X n m α
  | zx1 ↕ zx2 => (⊙ zx1) ↕ (⊙ zx2)
  | zx0 ⟷ zx1 => (⊙zx0) ⟷ (⊙zx1)
  | Cast n m nprf mprf zx => Cast n m nprf mprf (⊙ zx)
  | otherwise => otherwise
  end
  where "⊙ zx" := (ColorSwap zx) : ZX_scope.

Lemma ZX_semantics_Colorswap_comm {nIn nOut} : forall (zx : ZX nIn nOut),
  ZX_semantics (⊙ zx) = nOut ⨂ hadamard × (ZX_semantics zx) × nIn ⨂ hadamard.
Proof.
  induction zx.
  - simpl; Msimpl; reflexivity.
  - solve_matrix.
  - solve_matrix.
  - simpl.
    Msimpl.
    solve_matrix.
  - simpl; Msimpl; restore_dims; rewrite MmultHH; reflexivity.
  - simpl; Msimpl; restore_dims; rewrite MmultHH; Msimpl; reflexivity.
  - simpl. unfold X_semantics.
    rewrite <- 2 Mmult_assoc.
    rewrite kron_n_mult.
    rewrite 2 Mmult_assoc.
    rewrite kron_n_mult.
    rewrite MmultHH.
    rewrite 2 kron_n_I.
    Msimpl; reflexivity.
  - reflexivity.
  - simpl.
    rewrite IHzx1, IHzx2.
    rewrite 2 kron_n_m_split; try auto with wf_db.
    repeat rewrite <- kron_mixed_product.
    restore_dims.
    reflexivity.
  - simpl.
    rewrite IHzx1, IHzx2.
    rewrite Mmult_assoc.
    restore_dims.
    subst.
    rewrite <- 2 Mmult_assoc with (m ⨂ hadamard) _ _.
    rewrite kron_n_mult.
    rewrite MmultHH.
    rewrite kron_n_I.
    Msimpl.
    repeat rewrite Mmult_assoc.
    reflexivity.
  - simpl; subst; auto.
Qed.

Local Close Scope ZX_scope.