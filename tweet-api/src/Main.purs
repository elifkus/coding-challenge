module Main where


import Data.Maybe (maybe)
import Data.Nullable (toMaybe)
import Effect (Effect)
import Effect.Console (log)
import Env (hostEnv, portEnv)
import Node.Express.App (App, listenHostHttp, get)
import Node.Express.Handler (Handler)
import Node.Express.Response (send)
import Node.HTTP (Server)
import Prelude (bind, identity, show, ($), (<>),(<#>))


health :: Handler
health = send "{\"status\":\"ok\"}"

app :: App
app = do
  get "/" health

main :: Effect Server
main = do
  host <- hostEnv <#> toMaybe <#> maybe "0.0.0.0" identity
  port <- portEnv <#> toMaybe <#> maybe 9000 identity
  listenHostHttp app port host \_ ->
    log $ "Listening on http://" <> host <> ":" <> show port