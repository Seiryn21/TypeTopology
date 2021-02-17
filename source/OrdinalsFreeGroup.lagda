Martin Escardo, Marc Bezem, Thierry Coquand, and Peter Dybjer.
15 February 2021.

We prove the following:

  For any universe 𝓤, there is a group in the successor universe 𝓤⁺
  which is not isomorphic to any group in 𝓤.

Of course, in the other direction, any group in 𝓤 has an isomorphic
copy in 𝓤⁺, so the above says that there are strictly more groups in
𝓤⁺ than in 𝓤.

We use the group freely generated by the (large) type of ordinals, in
conjunction with the Burali-Forti argument, for that purpose.

We work in a spartan Martin-Löf type theory, with the assumption that
propositional truncations exist and that the univalence axiom
holds. No other features from HoTT/UF are needed. In particular,
quotients (which we use to construct free groups) are constructed
using propositional truncation and function extensionality and
prositional extensionality. In this module, as well as in the module
Burali-Forti.lagda, univalence plays a crucial role in various
ways. In particular, it allows us to resize down our quotient
construction.

The main difficulty is to show that the carrier of the group freely
generated by the type of ordinals in the universe 𝓤 is large, that is,
lives in the universe 𝓤⁺ and doesn't have a copy in the universe 𝓤.
In particular, we need to know that the inclusion of generators is
injective. But this is is not enough: for example, the unique map
P → 𝟙 is an embedding if P is a proposition, and the terminal type 𝟙
is small but P doesn't need to be small (cf. work with Tom de Jong on
size matters).

\begin{code}

{-# OPTIONS --without-K --safe #-}

open import UF-PropTrunc
open import UF-Univalence
open import SpartanMLTT

module OrdinalsFreeGroup
        (pt : propositional-truncations-exist)
        (ua : Univalence)
       where

open import UF-FunExt
open import UF-UA-FunExt
open import UF-Subsingletons

fe : Fun-Ext
fe {𝓤} {𝓥} = Univalence-gives-FunExt ua 𝓤 𝓥

pe : Prop-Ext
pe {𝓤} = univalence-gives-propext (ua 𝓤)

open import UF-Base
open import UF-Embeddings
open import UF-Equiv hiding (_≅_)
open import UF-EquivalenceExamples
open import UF-Quotient pt fe pe
open import UF-Size

open import BuraliForti ua
open import List
open import OrdinalsType hiding (⟨_⟩)
open import OrdinalOfOrdinals
open import SRTclosure

open import Groups
open import FreeGroup
open FreeGroupInterface pt fe pe

\end{code}

Applying our free group construction in the module FreeGroup.lagda to
the type of ordinals in the universe 𝓤, we get a type in 𝓤⁺⁺ rather
than 𝓤⁺. We use angle brackets to denote the carrier of a group.

\begin{code}

ufgo : (𝓤 : Universe) → universe-of ⟨ free-group (Ordinal 𝓤) ⟩ ≡ 𝓤 ⁺ ⁺
ufgo 𝓤 = refl

\end{code}

Our first lemma will construct an isomorphic copy of this group in the
universe 𝓤⁺, exploiting the fact that the type of ordinals is (large
but) locally small (meaning that its identity types, which have values
in 𝓤⁺⁺, have equivalent copies in 𝓤⁺), thanks to univalence.

Our second lemma will show that this group doesn't have an isomorphic
copy in 𝓤.

Combining these two lemmas, we get the main theorem of this module,
which says that for any universe 𝓤, there is a group in the universe
𝓤⁺ which is not isomorphic to any group in the universe 𝓤.

We work with a fixed, arbitrary universe 𝓤 is the remainder of this
file.

\begin{code}

module _ {𝓤 : Universe} where

 private
  𝓤⁺  = 𝓤 ⁺
  𝓤⁺⁺ = 𝓤⁺ ⁺

 A : 𝓤⁺ ̇
 A = Ordinal 𝓤

 A-is-set : is-set A
 A-is-set = type-of-ordinals-is-set ua

 open free-group-construction A

\end{code}

Our free group is constructed as a quotient of a set of words FA by a
certain equivalence relation _∾_ : FA → FA → 𝓤⁺. To reduce the size of
the quotient, we reduce the size of (propositional) values of this
equivalence relation, using univalence, where _≃ₒ_ is equivalence of
ordinals, which is equivalent to identity, but has (propositional)
values in the lower universe 𝓤. This amounts to saying that the large
type of ordinals is locally small.

At this point, in order to understand the following constructions, it
is necessary to first understand the constructions in the module
FreeGroup.lagda, because here we resize down several of the
constructions performed in that file, exploiting the local smalless of
the type A.

\begin{code}

 _≡[X]_ : X → X → 𝓤 ̇
 (m , a) ≡[X] (n , b) = (m ≡ n) × (a ≃ₒ b)

 from-≡[X] : {x y : X} → x ≡[X] y → x ≡ y
 from-≡[X] {m , a} {n , b} (p , q) = to-×-≡ p (eqtoidₒ ua a b q)

 to-≡[X] : {x y : X} → x ≡ y → x ≡[X] y
 to-≡[X] {m , a} {m , a} refl = refl , ≃ₒ-refl a

 _≡[FA]_ : FA → FA → 𝓤 ̇
 []      ≡[FA] []      = 𝟙
 []      ≡[FA] (y ∷ t) = 𝟘
 (x ∷ s) ≡[FA] []      = 𝟘
 (x ∷ s) ≡[FA] (y ∷ t) = (x ≡[X] y) × (s ≡[FA] t)

 from-≡[FA] : {s t : FA} → s ≡[FA] t → s ≡ t
 from-≡[FA] {[]}    {[]}    e       = refl
 from-≡[FA] {x ∷ s} {y ∷ t} (p , q) = ap₂ _∷_ (from-≡[X] p) (from-≡[FA] q)

 to-≡[FA] : {s t : FA} → s ≡ t → s ≡[FA] t
 to-≡[FA] {[]} {[]}       p = *
 to-≡[FA] {x ∷ s} {y ∷ t} p = to-≡[X]  (equal-heads p) ,
                              to-≡[FA] (equal-tails p)

 _◗_ : FA → FA → 𝓤 ̇
 []          ◗ t = 𝟘
 (x ∷ [])    ◗ t = 𝟘
 (x ∷ y ∷ s) ◗ t = (y ≡[X] (x ⁻)) × (s ≡[FA] t)

 _▶_ : FA → FA → 𝓤 ̇
 []      ▶ t       = 𝟘
 (x ∷ s) ▶ []      = (x ∷ s) ◗ []
 (x ∷ s) ▶ (y ∷ t) = ((x ∷ s) ◗ (y ∷ t)) + (x ≡[X] y × (s ▶ t))

 ▶-lemma : (x y : X) (s : List X) → y ≡ x ⁻ → (x ∷ y ∷ s) ▶ s
 ▶-lemma x _ []      refl = to-≡[X] {x ⁻} refl , *
 ▶-lemma x _ (z ∷ s) refl = inl (to-≡[X]  {x ⁻} refl ,
                                 to-≡[X]  {z}   refl ,
                                 to-≡[FA] {s}   refl)
\end{code}

The reduction relation _▷_ is defined in the module FreeGroup.lagda,
and its propositional, symmetric, reflexive, transitive closure gives
the relation _∾_ that we use in order to quotient the type FA to get
the group freely generated by A.

\begin{code}

 ▶-gives-▷ : {s t : FA} → s ▶ t → s ▷ t

 ▶-gives-▷ {[]} {t} r = 𝟘-elim r

 ▶-gives-▷ {x ∷ y ∷ s} {[]} (p , q) = [] , s , x ,
                                      ap (λ - → x ∷ - ∷ s) (from-≡[X] p) ,
                                      ((from-≡[FA] q)⁻¹)

 ▶-gives-▷ {x ∷ y ∷ s} {z ∷ t} (inl (p , q)) = γ (from-≡[X] p)
                                                 (from-≡[FA] q)
  where
   γ : y ≡ x ⁻ → s ≡ z ∷ t → x ∷ y ∷ s ▷ z ∷ t
   γ p q = [] , s , x , ap (λ - → x ∷ (- ∷ s)) p , (q ⁻¹)

 ▶-gives-▷ {x ∷ s} {y ∷ t} (inr (p , r)) = γ (from-≡[X] p) IH
  where
   IH : s ▷ t
   IH = ▶-gives-▷ r

   γ : x ≡ y → s ▷ t → (x ∷ s) ▷ (y ∷ t)
   γ refl = ∷-▷ x

 ▷-gives-▶ : {s t : FA} → s ▷ t → s ▶ t

 ▷-gives-▶ (u , v , x , refl , refl) = f u v x
  where
   f : (u v : FA) (x : X) → (u ++ [ x ] ++ [ x ⁻ ] ++ v) ▶ (u ++ v)
   f []      []      x = to-≡[X] {x ⁻} refl , *
   f []      (y ∷ v) x = inl (to-≡[X] {x ⁻} refl , to-≡[X] {y} refl , to-≡[FA] {v} refl)
   f (y ∷ u) v       x = inr (to-≡[X] {y} refl , f u v x)

\end{code}

The usual way to define the transitive closure of a relation (cf. the
file SRTclosure.lagda) applied to the relation _▶_ would increase
universe levels back to those of the relation _∾_.

In order to overcome this problem, we consider a type of redexes.

\begin{code}

 redex : FA → 𝓤 ̇
 redex []          = 𝟘
 redex (x ∷ [])    = 𝟘
 redex (x ∷ y ∷ s) = (y ≡[X] (x ⁻)) + redex (y ∷ s)

 reduct : (s : FA) → redex s → FA
 reduct (x ∷ y ∷ s) (inl p) = s
 reduct (x ∷ y ∷ s) (inr r) = x ∷ reduct (y ∷ s) r

\end{code}

We want that s ▶ t if and only the word t is the reduct of s at some
redex r, which is what we prove next:

\begin{code}

 lemma-reduct→ : (s : FA) (r : redex s) → s ▶ reduct s r
 lemma-reduct→ (x ∷ y ∷ s) (inl p) = ▶-lemma x y s (from-≡[X] p)
 lemma-reduct→ (x ∷ y ∷ s) (inr r) = inr (to-≡[X] {x} refl ,
                                         lemma-reduct→ (y ∷ s) r)

 lemma-reduct← : (s t : FA) → s ▶ t → Σ r ꞉ redex s , reduct s r ≡ t
 lemma-reduct← (x ∷ [])    (z ∷ t) (inl ())
 lemma-reduct← (x ∷ [])    (z ∷ t) (inr ())
 lemma-reduct← (x ∷ y ∷ s) []      (p , q)       = inl p , from-≡[FA] q
 lemma-reduct← (x ∷ y ∷ s) (z ∷ t) (inl (p , q)) = inl p , from-≡[FA] q
 lemma-reduct← (x ∷ y ∷ s) (z ∷ t) (inr (p , r)) = inr (pr₁ IH) ,
                                                   ap₂ _∷_ (from-≡[X] p) (pr₂ IH)
  where
   IH : Σ r ꞉ redex (y ∷ s) , reduct (y ∷ s) r ≡ t
   IH = lemma-reduct← (y ∷ s) t r

\end{code}

Next we define a type of chains of redexes of length n and a
corresponding notion of reduct for such chains:

\begin{code}

 redex-chain : ℕ → FA → 𝓤 ̇
 redex-chain 0        s = 𝟙
 redex-chain (succ n) s = Σ r ꞉ redex s , redex-chain n (reduct s r)

 chain-reduct : (s : FA) (n : ℕ) → redex-chain n s → FA
 chain-reduct s 0        ρ       = s
 chain-reduct s (succ n) (r , ρ) = chain-reduct (reduct s r) n ρ

 chain-lemma→ : (s : FA) (n : ℕ) (ρ : redex-chain n s) → s ▷[ n ] chain-reduct s n ρ
 chain-lemma→ s 0        ρ       = refl
 chain-lemma→ s (succ n) (r , ρ) = reduct s r ,
                                   ▶-gives-▷ (lemma-reduct→ s r) ,
                                   chain-lemma→ (reduct s r) n ρ

 chain-lemma← : (s t : FA) (n : ℕ)
              → s ▷[ n ] t
              → Σ ρ ꞉ redex-chain n s , chain-reduct s n ρ ≡ t
 chain-lemma← s t 0        r           = * , r
 chain-lemma← s t (succ n) (u , b , c) = γ IH l
  where
   IH : Σ ρ ꞉ redex-chain n u , chain-reduct u n ρ ≡ t
   IH = chain-lemma← u t n c

   b' : s ▶ u
   b' = ▷-gives-▶ b

   l : Σ r ꞉ redex s , reduct s r ≡ u
   l = lemma-reduct← s u b'

   γ : type-of IH
     → type-of l
     → Σ ρ' ꞉ redex-chain (succ n) s , chain-reduct s (succ n) ρ' ≡ t
   γ (ρ , refl) (r , refl) = (r , ρ) , refl

\end{code}

And with this we obtain a relation _≏_ whose propositional truncation
will be logically equivalent to the equivalence relation _∾_ used to
quotient FA to get the group freely generated by A. The relation _∾_
itself is the propositional truncation of a suitable relation _∿_.

\begin{code}

 _≏_ : FA → FA → 𝓤 ̇
 s ≏ t = Σ m ꞉ ℕ ,
         Σ n ꞉ ℕ ,
         Σ ρ ꞉ redex-chain m s ,
         Σ σ ꞉ redex-chain n t , chain-reduct s m ρ  ≡[FA] chain-reduct t n σ

 ≏-gives-∿ : (s t : FA) → s ≏ t → s ∿ t
 ≏-gives-∿ s t (m , n , ρ , σ , p) = γ
  where
   a : s ▷* chain-reduct s m ρ
   a = m , chain-lemma→ s m ρ

   b : t ▷* chain-reduct t n σ
   b = n , chain-lemma→ t n σ

   c : Σ u ꞉ FA , (s ▷* u) × (t ▷* u)
   c = chain-reduct t n σ  , transport (s ▷*_) (from-≡[FA] p) a , b

   γ : s ∿ t
   γ = to-∿ s t c

 ∿-gives-≏ : (s t : FA) → s ∿ t → s ≏ t
 ∿-gives-≏ s t e = γ a
  where
   a : Σ u ꞉ FA , (s ▷* u) × (t ▷* u)
   a = from-∿ Church-Rosser s t e

   γ : type-of a → s ≏ t
   γ (u , (m , ρ) , (n , σ)) = δ b c
    where
     b : Σ ρ ꞉ redex-chain m s , chain-reduct s m ρ ≡ u
     b = chain-lemma← s u m ρ

     c : Σ σ ꞉ redex-chain n t , chain-reduct t n σ ≡ u
     c = chain-lemma← t u n σ

     δ : type-of b → type-of c → s ≏ t
     δ (ρ , p) (σ , q) = m , n , ρ , σ , to-≡[FA] (p ∙ q ⁻¹)

 open free-group-construction-step₁ pt

 _∥≏∥_ : FA → FA → 𝓤 ̇
 s ∥≏∥ t = ∥ s ≏ t ∥

 ∿-is-logically-equivalent-to-∥≏∥ : (s t : FA) → s ∾ t ⇔ s ∥≏∥ t
 ∿-is-logically-equivalent-to-∥≏∥ s t = ∥∥-functor (∿-gives-≏ s t) ,
                                       ∥∥-functor (≏-gives-∿ s t)

\end{code}

And so we also get a type equivalence, because logically equivalent
propositions are equivalent types:

\begin{code}

 ∿-is-equivalent-to-∥≏∥ : (s t : FA) → (s ∾ t) ≃ (s ∥≏∥ t)
 ∿-is-equivalent-to-∥≏∥ s t = logically-equivalent-props-are-equivalent
                               ∥∥-is-prop
                               ∥∥-is-prop
                               (lr-implication (∿-is-logically-equivalent-to-∥≏∥ s t))
                               (rl-implication (∿-is-logically-equivalent-to-∥≏∥ s t))

\end{code}

Being logically equivalent to an equivalence relation, the relation
∥≏∥ is itself an equivalence relation (this is proved in the module
Groups.lagda).

\begin{code}

 open free-group-construction-step₂ fe pe

 -∥≏∥- : EqRel {𝓤⁺} {𝓤} FA
 -∥≏∥- = _∥≏∥_ , is-equiv-rel-transport _∾_ _∥≏∥_ (λ s t → ∥∥-is-prop)
                 ∿-is-logically-equivalent-to-∥≏∥ ∾-is-equiv-rel
\end{code}

By a general construction in the module UF-Quotient.lagda, we conclude
that FA/∾ ≃ FA/∥≏∥. The difference is that FA/∥≏∥ lives in the lower
universe 𝓤⁺, while FA/∾ lives in the higher universe 𝓤⁺⁺.

\begin{code}

 FA/∥≏∥ : 𝓤⁺ ̇
 FA/∥≏∥ = FA / -∥≏∥-

 FA/∾-is-equivalent-to-FA/∥≏∥ : FA/∾ ≃ FA/∥≏∥
 FA/∾-is-equivalent-to-FA/∥≏∥ = quotients-equivalent FA -∾- -∥≏∥-
                                (λ {s} {t} → ∿-is-logically-equivalent-to-∥≏∥ s t)

 native-universe-of-ordinals-free-group : universe-of ⟨ free-group (Ordinal 𝓤) ⟩ ≡ 𝓤 ⁺⁺
 native-universe-of-ordinals-free-group = refl

 resizing-ordinals-free-group-carrier : ⟨ free-group (Ordinal 𝓤) ⟩ has-size 𝓤⁺
 resizing-ordinals-free-group-carrier = γ
  where
   γ : Σ F ꞉ 𝓤⁺ ̇ , F ≃ ⟨ free-group (Ordinal 𝓤) ⟩
   γ = FA/∥≏∥ , ≃-sym FA/∾-is-equivalent-to-FA/∥≏∥

\end{code}

With this we get the proof of the first lemma needed for our proof of
the main theorem in this module. This relies on transporting group
structures along equivalences, which implemented in the module
Group.lagda (unfortunately, one cannot apply univalence for that
purpose, because the types live in different universes and hence one
can't form their identity type, and so this transport has to be done
manually).

\begin{code}

 Lemma₁ : Σ F ꞉ Group 𝓤⁺ , F ≅ free-group (Ordinal 𝓤)
 Lemma₁ = resize-group (free-group (Ordinal 𝓤)) resizing-ordinals-free-group-carrier

\end{code}

We say that a type has size 𝓥 if it is equivalent to some type in the
universe 𝓥, and that a map has size 𝓥 if its fibers all have size 𝓥.

The native size of the universal map ηᴳʳᵖ : FA → FA/∾ into the free
group is rather large:

\begin{code}

 ηᴳʳᵖ-native-size : ηᴳʳᵖ Has-size 𝓤⁺⁺
 ηᴳʳᵖ-native-size y = fiber ηᴳʳᵖ y , ≃-refl _

\end{code}

Using the above development, we can make it smaller. In the following
construction, η/∾ : FA → FA/∾ is the universal map into the quotient.

\begin{code}

 ηᴳʳᵖ-is-medium : ηᴳʳᵖ Has-size 𝓤⁺
 ηᴳʳᵖ-is-medium = /-induction -∾- (λ y → fiber ηᴳʳᵖ y has-size 𝓤⁺)
                   (λ y → has-size-is-prop ua (fiber ηᴳʳᵖ y) 𝓤⁺) γ
  where
   e : (a : A) (s : FA) → (η/∾ (η a) ≡ η/∾ s) ≃ (η a ∥≏∥ s)
   e a s = (η/∾ (η a) ≡ η/∾ s) ≃⟨ I ⟩
           (η a ∾ s)           ≃⟨ II ⟩
           (η a ∥≏∥ s)         ■
    where
     I = logically-equivalent-props-are-equivalent
            (quotient-is-set -∾-)
            ∥∥-is-prop
            η/∾-relates-identified-points
            η/∾-identifies-related-points
     II = ∿-is-equivalent-to-∥≏∥ (η a) s

   d : (s : FA) → fiber ηᴳʳᵖ (η/∾ s) ≃ (Σ a ꞉ A , η a ∥≏∥ s)
   d s = (Σ a ꞉ A , η/∾ (η a) ≡ η/∾ s) ≃⟨ Σ-cong (λ a → e a s) ⟩
         (Σ a ꞉ A , η a ∥≏∥ s)          ■

   γ : (s : FA) → fiber ηᴳʳᵖ (η/∾ s) has-size 𝓤⁺
   γ s = (Σ a ꞉ A , η a ∥≏∥ s) , ≃-sym (d s)
    where
     notice : universe-of (fiber ηᴳʳᵖ (η/∾ s)) ≡ 𝓤⁺⁺
     notice = refl

\end{code}

But the above resizing of ηᴳʳᵖ is not small enough for our purposes.

The fiber type Σ a ꞉ A , η a ≡ s lives in the universe 𝓤⁺. In the next
step we construct a copy in the first universe 𝓤₀.

The following construction also shows that the map η : A → FA has
decidable fibers, which is used implicitly in our definitions by
pattern matching.

\begin{code}

 native-universe-fiber-η : (s : FA) → universe-of (Σ a ꞉ A , η a ≡ s) ≡ 𝓤⁺
 native-universe-fiber-η s = refl

 fiber₀-η : FA → 𝓤₀ ̇
 fiber₀-η []             = 𝟘
 fiber₀-η (x ∷ y ∷ s)    = 𝟘
 fiber₀-η ((₀ , a) ∷ []) = 𝟙
 fiber₀-η ((₁ , a) ∷ []) = 𝟘

 NB-fiber₀-η-decidable : (s : FA) → fiber₀-η s + ¬ (fiber₀-η s)
 NB-fiber₀-η-decidable []             = inr id
 NB-fiber₀-η-decidable (x ∷ y ∷ s)    = inr id
 NB-fiber₀-η-decidable ((₀ , a) ∷ []) = inl *
 NB-fiber₀-η-decidable ((₁ , a) ∷ []) = inr id

 fiber-η→ : (s : FA) → fiber₀-η s → (Σ a ꞉ A , η a ≡ s)
 fiber-η→ [] ()
 fiber-η→ (₀ , a ∷ []) * = a , refl
 fiber-η→ (₁ , a ∷ []) ()
 fiber-η→ (x ∷ y ∷ s) ()

 fiber-η← : (s : FA) → (Σ a ꞉ A , η a ≡ s) → fiber₀-η s
 fiber-η← .(η a) (a , refl) = *

 η-fiber₀-η : (a : A) → fiber₀-η (η a)
 η-fiber₀-η a = *

\end{code}

Using this, next we want to reduce the size of the type
Σ a ꞉ A , η a ∾ s, which we informally refer to as
the ∾-fiber of s over η.

\begin{code}

 generator : FA → 𝓤 ̇
 generator s = Σ n ꞉ ℕ , Σ ρ ꞉ redex-chain n s , fiber₀-η (chain-reduct s n ρ)

 is-generator : FA → 𝓤 ̇
 is-generator s = ∥ generator s ∥

 the-∾-fibers-of-η-are-props : (s : FA) → is-prop (Σ a ꞉ A , η a ∾ s)
 the-∾-fibers-of-η-are-props s (a , e) (a' , e') = to-subtype-≡ (λ x → ∥∥-is-prop) γ
  where
   δ : η a ∾ η a'
   δ = psrt-transitive (η a) s (η a') e (psrt-symmetric (η a') s e')

   γ : a ≡ a'
   γ = η-identifies-∾-related-points A-is-set δ

 ∾-fiber-η-lemma→ : (s : FA) → (Σ a ꞉ A , η a ∾ s) → is-generator s
 ∾-fiber-η-lemma→ s (a , e) = ∥∥-functor γ e
  where
   γ : η a ∿ s → Σ n ꞉ ℕ , Σ ρ ꞉ redex-chain n s , fiber₀-η (chain-reduct s n ρ)
   γ e = δ (d c)
    where
     c : Σ u ꞉ FA , (η a ▷* u) × (s ▷* u)
     c = from-∿ Church-Rosser (η a) s e

     d : type-of c → Σ n ꞉ ℕ , Σ ρ ꞉ redex-chain n s , chain-reduct s n ρ ≡ η a
     d (u , r , r₁) = δ r₂
      where
       p : η a ≡ u
       p = η-irreducible* r

       r₂ : s  ▷* η a
       r₂ = transport (s ▷*_) (p ⁻¹) r₁

       δ : s  ▷* η a → Σ n ꞉ ℕ , Σ ρ ꞉ redex-chain n s , chain-reduct s n ρ ≡ η a
       δ (n , r₃) = (n , chain-lemma← s (η a) n r₃)

     δ : type-of (d c) → codomain γ
     δ (n , ρ , p) = n , ρ , transport fiber₀-η (p ⁻¹) (η-fiber₀-η a)

 ∾-fiber-η-lemma← : (s : FA) → is-generator s → (Σ a ꞉ A , η a ∾ s)
 ∾-fiber-η-lemma← s = ∥∥-rec (the-∾-fibers-of-η-are-props s) γ
  where
   γ : generator s → (Σ a ꞉ A , η a ∾ s)
   γ (n , ρ , i) = δ σ
    where
     r : s ▷[ n ] chain-reduct s n ρ
     r = chain-lemma→ s n ρ

     e : chain-reduct s n ρ ∾ s
     e = ∣ to-∿ (chain-reduct s n ρ) s (chain-reduct s n ρ , (0 , refl) , (n , r)) ∣

     σ : Σ a ꞉ A , η a ≡ chain-reduct s n ρ
     σ = fiber-η→ (chain-reduct s n ρ) i

     δ : type-of σ → Σ a ꞉ A , η a ∾ s
     δ (a , p) = a , transport (_∾ s) (p ⁻¹) e

\end{code}

And this is the desired size reduction:

\begin{code}

 ∾-fiber-η-lemma : (s : FA) → (Σ a ꞉ A , η a ∾ s) ≃ is-generator s
 ∾-fiber-η-lemma s = logically-equivalent-props-are-equivalent
                      (the-∾-fibers-of-η-are-props s)
                      ∥∥-is-prop
                      (∾-fiber-η-lemma→ s)
                      (∾-fiber-η-lemma← s)

\end{code}

With this we can further reduce the size of ηᴳʳᵖ to 𝓤:

\begin{code}

 ηᴳʳᵖ-is-small : ηᴳʳᵖ Has-size 𝓤
 ηᴳʳᵖ-is-small = /-induction -∾- (λ y → fiber ηᴳʳᵖ y has-size 𝓤)
                  (λ y → has-size-is-prop ua (fiber ηᴳʳᵖ y) 𝓤) γ
  where
   e : (a : A) (s : FA) → (η/∾ (η a) ≡ η/∾ s) ≃ (η a ∾ s)
   e a s = logically-equivalent-props-are-equivalent
             (quotient-is-set -∾-)
             ∥∥-is-prop
             η/∾-relates-identified-points
             η/∾-identifies-related-points

   d : (s : FA) → fiber ηᴳʳᵖ (η/∾ s) ≃ is-generator s
   d s = (Σ a ꞉ A , η/∾ (η a) ≡ η/∾ s) ≃⟨ Σ-cong (λ a → e a s) ⟩
         (Σ a ꞉ A , η a ∾ s)           ≃⟨ ∾-fiber-η-lemma s ⟩
         is-generator s                ■

   γ : (s : FA) → fiber ηᴳʳᵖ (η/∾ s) has-size 𝓤
   γ s = is-generator s , ≃-sym (d s)
    where
     notice : universe-of (fiber ηᴳʳᵖ (η/∾ s)) ≡ 𝓤⁺⁺
     notice = refl

\end{code}

So we finally obtain our desired result. A result by Tom de Jong and
Martin Escardo, recorded in the module UF-Size.lagda and recently
submitted for publication in a paper about size, says that if a map
has size 𝓥, and if also its codomain has size 𝓥, then so does its
domain. Because the type of ordinals is large by Burali-Forti, and
because ηᴳʳᵖ has size 𝓤, as proved above, it follows that the free group
must also be large, which proves the promised second lemma:

\begin{code}

 Lemma₂ : ¬ (⟨ free-group (Ordinal 𝓤) ⟩ has-size 𝓤)
 Lemma₂ h = the-type-of-ordinals-is-large
             (size-contravariance ηᴳʳᵖ ηᴳʳᵖ-is-small h)

\end{code}

And putting the two lemmas together, we get the promised theorem in a
straightforward way:

\begin{code}

 Main-Theorem : Σ F ꞉ Group 𝓤⁺ , ((G : Group 𝓤) → ¬ (G ≅ F))
 Main-Theorem = γ Lemma₁
  where
   γ : (Σ F ꞉ Group 𝓤⁺ , F ≅ free-group (Ordinal 𝓤))
     → (Σ F ꞉ Group 𝓤⁺ , ((G : Group 𝓤) → ¬ (G ≅ F)))
   γ (F , f , f-is-equiv , f-is-hom) = F , δ
    where
     δ : (G : Group 𝓤) → G ≅ F → 𝟘
     δ G (g , g-is-equiv , g-is-hom) = Lemma₂ (⟨ G ⟩ ,
                                               f ∘ g ,
                                               ∘-is-equiv g-is-equiv f-is-equiv)
\end{code}

TODO (easy but tedious). The majority of this module doesn't have
anything to do with ordinals, and works with any locally small type
A : 𝓤⁺ so that we get its free group in the universe 𝓤⁺ rather than the
universe 𝓤⁺⁺ as in the module FreeGroup.lagda. In particular, Lemma₁
holds for any locally small type A : 𝓤⁺.

Appendix.

The following are lemmas we thought we were going to need, but in the
end were not useful (for the reason explained below):

\begin{code}

 _▶[_]_ : FA → ℕ → FA → 𝓤 ̇
 s ▶[ 0 ]      t = s ≡[FA] t
 s ▶[ succ n ] t = Σ r ꞉ redex s , reduct s r ▶[ n ] t


 ▶[]-gives-▷[] : (n : ℕ) (s t : FA) → s ▶[ n ] t → s ▷[ n ] t
 ▶[]-gives-▷[] 0        s t r       = from-≡[FA] r
 ▶[]-gives-▷[] (succ n) s t (r , ρ) = reduct s r ,
                                      ▶-gives-▷ (lemma-reduct→ s r) ,
                                      ▶[]-gives-▷[] n (reduct s r) t ρ

 ▷[]-gives-▶[] : (n : ℕ) (s t : FA) → s ▷[ n ] t → s ▶[ n ] t
 ▷[]-gives-▶[] 0        s t r           = to-≡[FA] r
 ▷[]-gives-▶[] (succ n) s t (u , b , c) = γ
  where
   b' : s ▶ u
   b' = ▷-gives-▶ b

   IH : u ▶[ n ] t
   IH = ▷[]-gives-▶[] n u t c

   l : Σ re ꞉ redex s , reduct s re ≡ u
   l = lemma-reduct← s u b'

   re : redex s
   re = pr₁ l

   IH' : reduct s re ▶[ n ] t
   IH' = transport (λ - → - ▶[ n ] t) ((pr₂ l)⁻¹) IH

   γ : s ▶[ succ n ] t
   γ = re , IH'

 _▶*_ : FA → FA → 𝓤 ̇
 s ▶* t = Σ n ꞉ ℕ , s ▶[ n ] t

 ▶*-gives-▷* : (s t : FA) → s ▶* t → s ▷* t
 ▶*-gives-▷* s t (n , r) = n , ▶[]-gives-▷[] n s t r

 ▷*-gives-▶* : (s t : FA) → s ▷* t → s ▶* t
 ▷*-gives-▶* s t (n , r) = n , ▷[]-gives-▶[] n s t r

\end{code}

This is not useful because the universe level gets too big with this
approach:

\begin{code}

 _≍_ : FA → FA → 𝓤⁺ ̇
 s ≍ t = Σ u ꞉ FA , (s ▶* u) × (t ▶* u)

\end{code}

The approach with redex chains, together with other ideas, reduces the
target universe of the equivalence relation from 𝓤⁺ to 𝓤, which is
what allows us to prove the main theorem.
