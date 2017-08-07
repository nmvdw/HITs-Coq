Require Import HoTT HitTactics.
Require Export representations.definition disjunction fsets.operations.

(* Lemmas relating operations to the membership predicate *)
Section operations_isIn.

  Context {A : Type}.
  Context `{Univalence}.

  Lemma union_idem : forall x: FSet A, x ∪ x = x.
  Proof.
    hinduction ; try (intros ; apply set_path2).
    - apply nl.
    - apply idem.
    - intros x y P Q.
      rewrite assoc.
      rewrite (comm x y).
      rewrite <- (assoc y x x).
      rewrite P.
      rewrite (comm y x).
      rewrite <- (assoc x y y).
      f_ap. 
  Defined.

  (** ** Properties about subset relation. *)
  Lemma subset_union (X Y : FSet A) : 
    X ⊆ Y -> X ∪ Y = Y.
  Proof.
    hinduction X ; try (intros; apply path_forall; intro; apply set_path2).
    - intros. apply nl.
    - intros a.
      hinduction Y ; try (intros; apply path_forall; intro; apply set_path2).
      + intro.
        contradiction.
      + intro a0.
        simple refine (Trunc_ind _ _).
        intro p ; simpl. 
        rewrite p; apply idem.
      + intros X1 X2 IH1 IH2.
        simple refine (Trunc_ind _ _).
        intros [e1 | e2].
        ++ rewrite assoc.
           rewrite (IH1 e1).
           reflexivity.
        ++ rewrite comm.
           rewrite <- assoc.
           rewrite (comm X2).
           rewrite (IH2 e2).
           reflexivity.
    - intros X1 X2 IH1 IH2 [G1 G2].
      rewrite <- assoc.
      rewrite (IH2 G2).
      apply (IH1 G1).
  Defined.
  
  Lemma subset_union_l (X : FSet A) :
    forall Y, X ⊆ X ∪ Y.
  Proof.
    hinduction X ; try (repeat (intro; intros; apply path_forall);
                        intro ; apply equiv_hprop_allpath ; apply _).
    - apply (fun _ => tt).
    - intros a Y.
      apply (tr(inl(tr idpath))).
    - intros X1 X2 HX1 HX2 Y.
      split. 
      * rewrite <- assoc. apply HX1.
      * rewrite (comm X1 X2). rewrite <- assoc. apply HX2.
  Defined.

  (* simplify it using extensionality *)
  Lemma comprehension_or : forall ϕ ψ (x: FSet A),
      comprehension (fun a => orb (ϕ a) (ψ a)) x
      = (comprehension ϕ x) ∪ (comprehension ψ x).
  Proof.
    intros ϕ ψ.
    hinduction ; try (intros; apply set_path2). 
    - apply (union_idem _)^.
    - intros.
      destruct (ϕ a) ; destruct (ψ a) ; symmetry.
      * apply union_idem.
      * apply nr. 
      * apply nl.
      * apply union_idem.
    - simpl. intros x y P Q.
      rewrite P.
      rewrite Q.
      rewrite <- assoc.
      rewrite (assoc  (comprehension ψ x)).
      rewrite (comm  (comprehension ψ x) (comprehension ϕ y)).
      rewrite <- assoc.
      rewrite <- assoc.
      reflexivity.
  Defined.

End operations_isIn.

(* Other properties *)
Section properties.

  Context {A : Type}.
  Context `{Univalence}.

  (** isIn properties *)
  Definition empty_isIn (a: A) : a ∈ E -> Empty := idmap.
  
  Definition singleton_isIn (a b: A) : a ∈ {|b|} -> Trunc (-1) (a = b) := idmap.

  Definition union_isIn (X Y : FSet A) (a : A)
    : a ∈ X ∪ Y = a ∈ X ∨ a ∈ Y := idpath.

  Lemma comprehension_isIn (ϕ : A -> Bool) (a : A) : forall X : FSet A,
      a ∈ (comprehension ϕ X) = if ϕ a then a ∈ X else False_hp.
  Proof.
    hinduction ; try (intros ; apply set_path2) ; cbn.
    - destruct (ϕ a) ; reflexivity.
    - intros b.
      assert (forall c d, ϕ a = c -> ϕ b = d ->
                          a ∈ (if ϕ b then {|b|} else ∅)
                          =
                          (if ϕ a then BuildhProp (Trunc (-1) (a = b)) else False_hp)) as X.
      {
        intros c d Hc Hd.
        destruct c ; destruct d ; rewrite Hc, Hd ; try reflexivity
        ; apply path_iff_hprop ; try contradiction ; intros ; strip_truncations
        ; apply (false_ne_true).
        * apply (Hd^ @ ap ϕ X^ @ Hc). 
        * apply (Hc^ @ ap ϕ X @ Hd).
      }
      apply (X (ϕ a) (ϕ b) idpath idpath).
    - intros X Y H1 H2.
      rewrite H1, H2.
      destruct (ϕ a).
      * reflexivity.
      * apply path_iff_hprop.
        ** intros Z ; strip_truncations.
           destruct Z ; assumption.
        ** intros ; apply tr ; right ; assumption.
  Defined.

  Context {B : Type}.
  
  Definition isIn_product : forall (a : A) (b : B) (X : FSet A) (Y : FSet B),
      isIn a X -> isIn b Y -> isIn (a,b) (product X Y).
  Proof.
    intros a b X Y.
    hinduction X ; try (intros ; apply path_forall ; intro ; apply path_ishprop).
    - contradiction.
    - intros c Hc.
      hinduction Y ; try (intros ; apply path_forall ; intro ; apply path_ishprop).
      * contradiction.
      * intros d Hd.
        strip_truncations.
        apply tr.
        rewrite Hc, Hd.
        reflexivity.
      * intros Y1 Y2 HY1 HY2 HOr.
        strip_truncations.
        apply tr.
        destruct HOr as [H1 | H2].
        ** apply (inl (HY1 H1)).
        ** apply (inr (HY2 H2)).
    - intros X1 X2 HX1 HX2 Hor HY.
      strip_truncations.
      apply tr.
      destruct Hor as [H1 | H2].
      * apply (inl(HX1 H1 HY)).
      * apply (inr (HX2 H2 HY)).
  Defined.

  (* The proof can be simplified using extensionality *)
  (** comprehension properties *)
  Lemma comprehension_false Y : comprehension (fun (_ : A) => false) Y = ∅.
  Proof.
    hrecursion Y; try (intros; apply set_path2).
    - reflexivity.
    - reflexivity.
    - intros x y IHa IHb.
      rewrite IHa, IHb.
      apply union_idem.
  Defined.

  (* Can be simplified using extensionality *)
  Lemma comprehension_subset : forall ϕ (X : FSet A),
      (comprehension ϕ X) ∪ X = X.
  Proof.
    intros ϕ.
    hrecursion; try (intros ; apply set_path2) ; cbn.
    - apply union_idem.
    - intro a.
      destruct (ϕ a).
      * apply union_idem.
      * apply nl.
    - intros X Y P Q.
      rewrite assoc.
      rewrite <- (assoc (comprehension ϕ X) (comprehension ϕ Y) X).
      rewrite (comm (comprehension ϕ Y) X).
      rewrite assoc.
      rewrite P.
      rewrite <- assoc.
      rewrite Q.
      reflexivity.
  Defined.
  
  Lemma merely_choice : forall X : FSet A, hor (X = ∅) (hexists (fun a => a ∈ X)).
  Proof.
    hinduction; try (intros; apply equiv_hprop_allpath ; apply _).
    - apply (tr (inl idpath)).
    - intro a.
      refine (tr (inr (tr (a ; tr idpath)))).
    - intros X Y TX TY.
      strip_truncations.
      destruct TX as [XE | HX] ; destruct TY as [YE | HY] ; try(strip_truncations ; apply tr).
      * refine (tr (inl _)).
        rewrite XE, YE.
        apply (union_idem E).
      * destruct HY as [a Ya].
        refine (inr (tr _)).
        exists a.
        apply (tr (inr Ya)).
      * destruct HX as [a Xa].
        refine (inr (tr _)).
        exists a.
        apply (tr (inl Xa)).
      * destruct (HX, HY) as [[a Xa] [b Yb]].
        refine (inr (tr _)).
        exists a.
        apply (tr (inl Xa)).
  Defined.
  
End properties.
