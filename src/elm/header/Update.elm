module Header.Update exposing (update)

import Header.Messages exposing (..)
import Notify exposing (notifyUser)
import Api

update msg sm = 
  case msg of
    ToggleMenu         -> { sm | openMenu   = not sm.openMenu } ! []
    ToggleSlack        -> { sm | showSlack  = not sm.showSlack} ! []
    UpdateEmail  email -> { sm | slackEmail = email} ! []
    SlackSuccess res   -> { sm | showSlack  = False, slackEmail = "" } ! [notify res]
    PostToSlack        -> sm ! [Api.postToSlack sm.slackEmail SlackSuccess]
    _ -> sm ! []

notify res =
  if res.ok then notifyUser Notify.Success "Registration sent!"
  else
    res.error 
    |> Maybe.withDefault "(no details, sorry)"
    |> (++) "Something happened with Slack: "
    |> notifyUser Notify.Error  

