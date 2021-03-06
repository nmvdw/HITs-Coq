(** Operations on [FSetC A] *)
Require Import HoTT HitTactics.
Require Import list_representation.

Section operations.
  Global Instance fsetc_union : forall A, hasUnion (FSetC A).
  Proof.
    intros A x y.
    hinduction x.
    - apply y.
    - apply Cns.
    - apply dupl.
    - apply comm_s.
  Defined.

  Global Instance fsetc_singleton : forall A, hasSingleton (FSetC A) A := fun A a => a;;∅.

End operations.