port module Notify exposing (..)

port notify : (String, String) -> Cmd msg

type Notification = Info | Error | Warning | Success

notifyUser : Notification -> String -> Cmd msg
notifyUser kind msg =
  ((case kind of
    Info    -> "info"
    Error   -> "error"
    Warning -> "warning"
    Success -> "success")
  , msg)
  |> notify 


