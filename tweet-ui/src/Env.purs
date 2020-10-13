module Env where

import Data.Nullable (Nullable)
import Effect (Effect)

foreign import baseUrlEnv :: Effect (Nullable String)
