(* [FSet] is a (strong and stable) finite powerset monad *)
Require Import definition properties.
Require Import HoTT HitTactics.

Definition fmap {A B : Type} : (A -> B) -> FSet A -> FSet B.
Proof.
  intro f.
  hrecursion.
  - exact ∅.
  - intro a. exact {| f a |}.
  - exact U.
  - apply assoc.
  - apply comm.
  - apply nl.
  - apply nr.
  - simpl. intro x. apply idem.
Defined.

Lemma fmap_1 {A : Type} `{Funext} : @fmap A A idmap = idmap.
Proof.
  apply path_forall.
  intro x. hinduction x; try (cbn; intros; f_ap);
             try (intros; apply set_path2).
Defined.

Lemma fmap_compose {A B C : Type} `{Funext} (f : A -> B) (g : B -> C) :
  fmap (g o f) = fmap g o fmap f.
Proof.
  apply path_forall. intro x.
  hrecursion x; try (cbn; intros; f_ap);
    try (intros; apply set_path2).
Defined.

Definition join {A : Type} : FSet (FSet A) -> FSet A.
Proof.
hrecursion.
- exact ∅.
- exact idmap.
- exact U.
- apply assoc.
- apply comm.
- apply nl.
- apply nr.
- simpl. apply union_idem.
Defined.

Lemma join_assoc {A : Type} (X : FSet (FSet (FSet A))) :
  join (fmap join X) = join (join X).
Proof.
  hrecursion X; try (cbn; intros; f_ap);
    try (intros; apply set_path2).
Defined.

Lemma join_return_1 {A : Type} (X : FSet A) :
  join ({| X |}) = X.
Proof. reflexivity. Defined.

Lemma join_return_fmap {A : Type} (X : FSet A) :
  join ({| X |}) = join (fmap (fun x => {|x|}) X).
Proof.
  hrecursion X; try (cbn; intros; f_ap);
    try (intros; apply set_path2).
Defined.

Lemma join_fmap_return_1 {A : Type} (X : FSet A) :
  join (fmap (fun x => {|x|}) X) = X.
Proof. refine ((join_return_fmap _)^ @ join_return_1 _). Defined.
