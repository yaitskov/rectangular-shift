module Lib where

import Control.Lens
import Data.Generics.Labels as X ()
import Data.MinMax1 (minmaxP)
import Data.Text qualified as T
import Emacs
import Relude

{-# ANN exe (Haddock "Shift region by number of columns between cursor column and column with first non space char of the line with the cursor.") #-}
{-# ANN exe Interactive #-}
exe :: EmacsM ()
exe = do
  (mn, mx) <- minmaxP <$> point <*> mark
  saveExcursion do
    void $ gotoChar mn
    void $ beginningOfLine
    a <- (\x -> x - mn  - 1) <$> reSearchForward "[^ ]"
    void $ beginningOfLine
    cp <- point
    let customize o = o & #start ?~ cp & #end ?~ mx
    if a > 0  -- <~ monad     -- ?~
      then replaceRegexp
           (EmacsRegexp $ "^" <> T.replicate (unBufPos a) " ")
           ""
           customize
      else replaceRegexp "^"
           (T.replicate (unBufPos (-a)) " ")
           customize
    void $ gotoChar mn
