module Tweets where

import Prelude
import Foreign (ForeignError)
import Milkis as M
import Milkis.Impl.Node (nodeFetch)
import Data.Array (fold)
import Data.Array as Array
import Data.Bifunctor (lmap)
import Data.Either (Either(..))
import Data.Foldable (traverse_)
import Effect (Effect)
import Effect.Aff (Aff)
import Effect.Class.Console (log)
import Data.List.Types (NonEmptyList)
import React.Basic.DOM as R
import React.Basic.DOM.Events (preventDefault, stopPropagation, targetValue)
import React.Basic.Events (handler)
import React.Basic.Hooks (Component, component, useState, (/\))
import React.Basic.Hooks as React
import React.Basic.Hooks.Aff (mkAffReducer, useAffReducer)
import Simple.JSON as JSON

type Analysis
  = { identityAttack :: Boolean
    , insult :: Boolean
    , obscene :: Boolean
    , severeToxicity :: Boolean
    , sexualExplicit :: Boolean
    , threat :: Boolean
    , toxicity :: Boolean
    }

data Acceptable
  = Yes
  | No

isAcceptable :: Analysis -> Acceptable
isAcceptable a =
  if (a.identityAttack || a.insult || a.obscene || a.severeToxicity || a.sexualExplicit || a.threat || a.toxicity) then
    No
  else
    Yes

type Tweet
  = { content :: String
    , analysis :: Analysis
    }

data Action
  = SendTweet String
  | ReceiveAnalysis String Analysis

type State
  = { tweets :: Array Tweet
    }

fetch :: M.Fetch
fetch = M.fetch nodeFetch

combineErrors :: NonEmptyList ForeignError -> String
combineErrors = map show >>> fold

reducer :: String -> State -> Action -> { state :: State, effects :: Array (Aff (Array Action)) }
reducer url state (ReceiveAnalysis content analysis) =
  { state: state { tweets = Array.cons { content, analysis } state.tweets }
  , effects: []
  }

reducer url state (SendTweet content) = { state, effects: [ effects ] }
  where
  effects = do
    log $ "Sending tweet " <> content
    response <- fetch (M.URL (url <> "/api/analysis")) { method: M.postMethod, body: JSON.writeJSON { content: content } }
    let
      toAnalysis :: String -> Either String Analysis
      toAnalysis = JSON.readJSON >>> lmap combineErrors

    maybeAnalysis <- response # M.text <#> toAnalysis
    case maybeAnalysis of
      Left err -> do
        log $ "Failed to get sentiment" <> content <> "\n" <> err
        pure []
      Right analysis -> do
        log $ "Received analysis:\n" <> JSON.writeJSON analysis
        pure $ [ ReceiveAnalysis content analysis ]

mkTweetUI :: String -> Component {}
mkTweetUI url = do
  let
    initialState = { tweets: [] }
  tweetInput <- mkTweetInput
  tweetRow <- mkTweetRow
  affReducer <- mkAffReducer $ reducer url
  component "Tweets" \props -> React.do
    state /\ dispatch <- useAffReducer initialState affReducer
    pure
      $ R.div
          { children:
              [ tweetInput { dispatch }
              , R.div_
                  $ flip map state.tweets \tweet ->
                      tweetRow { tweet }
              ]
          , className: "container"
          }

mkTweetInput :: Component { dispatch :: Action -> Effect Unit }
mkTweetInput = do
  component "TweetInput" \props -> React.do
    tweet /\ setTweet <- useState ""
    let
      sendTweet =
        handler (preventDefault >>> stopPropagation >>> targetValue)
          $ \_ -> do
              props.dispatch $ SendTweet tweet
              setTweet $ const ""

      updateTweetInput =
        handler (preventDefault >>> stopPropagation >>> targetValue)
          $ traverse_ (setTweet <<< const)
    pure
      $ R.form
          { onSubmit: sendTweet
          , children:
              [ R.input
                  { value: tweet
                  , onChange: updateTweetInput
                  , className: "tweet"
                  , placeholder: "Tweet something"
                  }
              ]
          , className: "tweet"
          }

mkTweetRow :: Component { tweet :: Tweet }
mkTweetRow = do
  component "Tweet" \props -> React.do
    pure
      $ R.div
          { children:
              [ R.label
                  { children:
                      [ R.text props.tweet.content
                      , case isAcceptable props.tweet.analysis of
                          Yes -> R.text "🙂"
                          No -> R.text "🤫"
                      ]
                  , className: "tweet"
                  }
              ]
          , className: "tweet"
          }
