module Header.Update exposing (update)

import Header.Messages exposing (..)
import Notify exposing (notifyUser)
import Api
import Messages

update msg sm = 
  case msg of
    ToggleMenu         -> ({ sm | openMenu   = not sm.openMenu }, Cmd.none )
    ToggleSlack        -> ({ sm | showSlack  = not sm.showSlack}, Cmd.none )
    UpdateEmail  email -> ({ sm | slackEmail = email}, Cmd.none)
    SlackSuccess res   -> ({ sm | showSlack  = False, slackEmail = "" }, notify res)
    PostToSlack        -> (sm, Api.postToSlack sm.slackEmail Messages.NotifyUser SlackSuccess)
    _ -> (sm, Cmd.none)

notify res =
  if res.ok then notifyUser Notify.Success "Registration sent!"
  else
    res.error 
    |> Maybe.withDefault "(no details, sorry)"
    |> (++) "Something happened with Slack: "
    |> notifyUser Notify.Error  

