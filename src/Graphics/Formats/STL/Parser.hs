{-# LANGUAGE OverloadedStrings #-}

module Graphics.Formats.STL.Parser where

import Prelude hiding (takeWhile)

import Control.Applicative
import Data.Attoparsec.Text
import Data.Text (Text)

import Graphics.Formats.STL.Types

-- | A parser from 'Text' to the @STL@ type.  The parser should be
-- fairly permissive about whitespace, but has not been tested enough
-- against STL files in the wild.
stlParser :: Parser STL
stlParser = STL <$> nameParser <*> many' triangle

nameParser :: Parser Text
nameParser = text "solid" *> takeWhile (inClass " -~") <* skipSpace

triangle = Triangle <$> ss normalParser <*> loop <* text "endfacet"

loop = triple <$> (text "outer loop" *> ss vertex) <*> ss vertex <*> ss vertex <* text "endloop"

normalParser :: Parser Vector
normalParser = text "facet" *> text "normal" *> v3

vertex :: Parser Vector
vertex = text "vertex" *> v3

v3 :: Parser Vector
v3 = triple <$> ss double <*> ss double <*> ss double

ss :: Parser a -> Parser a
ss p = p <* skipSpace

text :: Text -> Parser Text
text t = string t <* skipSpace
