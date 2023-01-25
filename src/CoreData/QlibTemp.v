From QuantumLib Require Import Matrix.

Lemma transpose_matrices : forall {n m} (A B : Matrix n m),
  A ⊤ = B ⊤ -> A = B.
Proof.
  intros.
  rewrite <- transpose_involutive.
  rewrite <- H.
  rewrite transpose_involutive.
  easy.
Qed.

Lemma adjoint_matrices : forall {n m} (A B : Matrix n m),
  A † = B † -> A = B.
Proof.
  intros.
  rewrite <- adjoint_involutive.
  rewrite <- H.
  rewrite adjoint_involutive.
  easy.
Qed.


Lemma kron_id_dist_r : forall {n m o p} (A : Matrix n m) (B : Matrix m o),
WF_Matrix A -> WF_Matrix B -> (A × B) ⊗ (I p) = (A ⊗ (I p)) × (B ⊗ (I p)).
Proof.
  intros.
  rewrite <- (Mmult_1_l _ _ (I p)).
  rewrite kron_mixed_product.
  Msimpl.
  easy.
  auto with wf_db.
Qed.

Lemma kron_id_dist_l : forall {n m o p} (A : Matrix n m) (B : Matrix m o),
WF_Matrix A -> WF_Matrix B -> (I p) ⊗ (A × B) = ((I p) ⊗ A) × ((I p) ⊗ B).
Proof.
  intros.
  rewrite <- (Mmult_1_l _ _ (I p)).
  rewrite kron_mixed_product.
  Msimpl.
  easy.
  auto with wf_db.
Qed.
