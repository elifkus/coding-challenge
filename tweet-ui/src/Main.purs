module Main where

import Prelude

import Data.Maybe (Maybe(..), maybe)
import Data.Nullable (toMaybe)
import Effect (Effect)
import Effect.Class.Console (log)
import Effect.Exception (throw)
import Env (baseUrlEnv)
import React.Basic.DOM (render)
import Tweets (mkTweetUI)
import Web.DOM.NonElementParentNode (getElementById)
import Web.HTML (window)
import Web.HTML.HTMLDocument (toNonElementParentNode)
import Web.HTML.Window (document)

main :: Effect Unit
main = do
  baseUrl <- baseUrlEnv <#> toMaybe <#> maybe "" identity
  log $ "baseUrl in Purescript" <> baseUrl
  container <- getElementById "container" =<< (map toNonElementParentNode $ document =<< window)
  case container of
    Nothing -> throw "Container element not found."
    Just c -> do
      ui <- mkTweetUI baseUrl
      render (ui {}) c
