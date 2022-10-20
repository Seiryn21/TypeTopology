Martin Escardo, Paulo Oliva, 2-27 July 2021

Example: Tic-tac-toe. We have two versions. The other version is in
another file.

\begin{code}

{-# OPTIONS --without-K --safe --auto-inline #-} -- --exact-split

open import MLTT.Spartan hiding (J)
open import UF.Base
open import UF.FunExt
open import TypeTopology.SigmaDiscreteAndTotallySeparated


module Games.TicTacToe
        (fe : Fun-Ext)
       where

open import TypeTopology.CompactTypes
open import UF.Subsingletons
open import TypeTopology.DiscreteAndSeparated
open import UF.Miscelanea

open import MLTT.NonSpartanMLTTTypes hiding (Fin ; 𝟎 ; 𝟏 ; 𝟐 ; 𝟑 ; 𝟒 ; 𝟓 ; 𝟔 ; 𝟕 ; 𝟖 ; 𝟗)
open import MLTT.Fin
open import MLTT.Fin-Properties


𝟛 : Type
𝟛 = Fin 3

open import Games.TypeTrees
open import Games.FiniteHistoryDependent 𝟛 fe
open import Games.Constructor 𝟛 fe

tic-tac-toe₁ : Game
tic-tac-toe₁ = build-Game draw Board transition 9 board₀
 where
  open import TypeTopology.CompactTypes
  open import UF.Subsingletons
  open import TypeTopology.DiscreteAndSeparated
  open import UF.Miscelanea

  open import MLTT.NonSpartanMLTTTypes hiding (Fin ; 𝟎 ; 𝟏 ; 𝟐 ; 𝟑 ; 𝟒 ; 𝟓 ; 𝟔 ; 𝟕 ; 𝟖 ; 𝟗)
  open import MLTT.Fin
  open import MLTT.Fin-Properties

  data Player : Type where
   X O : Player

  opponent : Player → Player
  opponent X = O
  opponent O = X

  pattern X-wins = 𝟎
  pattern draw   = 𝟏
  pattern O-wins = 𝟐

  Grid   = 𝟛 × 𝟛
  Matrix = Grid → Maybe Player
  Board  = Player × Matrix

\end{code}

Convention: in a board (p , A), p is the opponent of the the current player.

\begin{code}

  Grid-is-discrete : is-discrete Grid
  Grid-is-discrete = ×-is-discrete Fin-is-discrete Fin-is-discrete

  Grid-compact : Compact Grid {𝓤₀}
  Grid-compact = ×-Compact Fin-Compact Fin-Compact

  board₀ : Board
  board₀ = X , (λ _ → Nothing)

  Move : Board → Type
  Move (_ , A) = Σ g ꞉ Grid , A g ＝ Nothing

  Move-decidable : (b : Board) → decidable (Move b)
  Move-decidable (_ , A) = Grid-compact
                            (λ g → A g ＝ Nothing)
                            (λ g → Nothing-is-isolated' (A g))

  Move-compact : (b : Board) → Compact (Move b)
  Move-compact (x , A) = complemented-subset-of-compact-type
                          Grid-compact
                          (λ g → Nothing-is-isolated' (A g))
                          (λ g → Nothing-is-h-isolated' (A g))

  selection : (b : Board) → Move b → J (Move b)
  selection b@(X , A) m p = pr₁ (compact-argmax p (Move-compact b) m)
  selection b@(O , A) m p = pr₁ (compact-argmin p (Move-compact b) m)

  _is_ : Maybe Player → Player → Bool
  Nothing is _ = false
  Just X  is X = true
  Just O  is X = false
  Just X  is O = false
  Just O  is O = true

  infix 30 _is_

  wins : Player → Matrix → Bool
  wins p A = line || col || diag
   where
    l₀ = A (𝟎 , 𝟎) is p && A (𝟎 , 𝟏) is p && A (𝟎 , 𝟐) is p
    l₁ = A (𝟏 , 𝟎) is p && A (𝟏 , 𝟏) is p && A (𝟏 , 𝟐) is p
    l₂ = A (𝟐 , 𝟎) is p && A (𝟐 , 𝟏) is p && A (𝟐 , 𝟐) is p

    c₀ = A (𝟎 , 𝟎) is p && A (𝟏 , 𝟎) is p && A (𝟐 , 𝟎) is p
    c₁ = A (𝟎 , 𝟏) is p && A (𝟏 , 𝟏) is p && A (𝟐 , 𝟏) is p
    c₂ = A (𝟎 , 𝟐) is p && A (𝟏 , 𝟐) is p && A (𝟐 , 𝟐) is p

    d₀ = A (𝟎 , 𝟎) is p && A (𝟏 , 𝟏) is p && A (𝟐 , 𝟐) is p
    d₁ = A (𝟎 , 𝟐) is p && A (𝟏 , 𝟏) is p && A (𝟐 , 𝟎) is p

    line = l₀ || l₁ || l₂
    col  = c₀ || c₁ || c₂
    diag = d₀ || d₁

  update : (p : Player) (A : Matrix)
         → Move (p , A) → Matrix
  update p A (m , _) m' = f (Grid-is-discrete m m')
   where
    f : decidable (m ＝ m') → Maybe Player
    f (inl _) = Just p
    f (inr _) = A m'

  play : (b : Board) (m : Move b) → Board
  play (p , A) m = opponent p , update p A m

  transition : Board → 𝟛 + (Σ M ꞉ Type , (M → Board) × J M)
  transition (p , A) = f p A (wins p A) refl
   where
    f : (p : Player) (A : Matrix) (b : Bool) → wins p A ＝ b
      → 𝟛 + (Σ M ꞉ Type , (M → Board) × J M)
    f X A true e  = inl X-wins
    f O A true e  = inl O-wins
    f p A false e = Cases (Move-decidable (p , A))
                     (λ (g , e) → inr (Move (p , A) ,
                                       (λ m → opponent p , update p A m) ,
                                       selection (p , A) (g , e)))
                     (λ ν → inl draw)

t₁ : 𝟛
t₁ = optimal-outcome tic-tac-toe₁

\end{code}

The above computation takes too long, due to the use of brute-force
search. A more efficient one is in another file.