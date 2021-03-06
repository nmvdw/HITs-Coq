(* The length function for finite sets *)
Require Import HoTT HitTactics.
From representations Require Import cons_repr definition.
From fsets Require Import operations_decidable isomorphism properties_decidable.

Section Length.

  Context {A : Type}.
  Context {A_deceq : DecidablePaths A}.
  Context `{Univalence}.

  Definition length (x : FSetC A) : nat.
  Proof.
    simple refine (FSetC_ind A _ _ _ _ _ _ x ); simpl.
    - exact 0.
    - intros a y n. 
      pose (y' := FSetC_to_FSet y).
      exact (if a ∈_d y' then n else (S n)).
    - intros. rewrite transport_const. simpl.
      simplify_isIn_b. reflexivity.
    - intros. rewrite transport_const. simpl.
      simplify_isIn_b.
      destruct (dec (a = b)) as [Hab | Hab].
      + rewrite Hab. simplify_isIn_b. reflexivity.
      + rewrite ?L_isIn_b_false; auto.
        ++ simpl. 
           destruct (a ∈_d (FSetC_to_FSet x0)), (b ∈_d (FSetC_to_FSet x0))
           ; reflexivity.
        ++ intro p. contradiction (Hab p^).
  Defined.

  Definition length_FSet (x: FSet A) := length (FSet_to_FSetC x).

  Lemma length_singleton: forall (a: A), length_FSet ({|a|}) = 1.
  Proof. 
    intro a.
    cbn. reflexivity. 
  Defined.

End Length.