port module Main exposing (..)

import Task exposing (Task)
import Html.App as Html
import Date
import Http exposing (..)
import Random
import Json.Decode as Json exposing ((:=))
import Json.Encode as JsonEnc

import Views exposing (..)
import Models exposing (..)
import Messages exposing (..)

main = 
  Html.program 
    { init = init, view = view, update = update, subscriptions = \_ -> Sub.none}

--
-- My functions
--
init : (Model, Cmd Msg)
init =
  (emptyModel, Cmd.batch [getSponsors, getBoard, getEvents, getVideos])

port notify : (String, String) -> Cmd msg

type Notification = Info | Error | Warning | Success

notifyUser : Notification -> String -> Cmd msg
notifyUser kind msg =
  let
    msgType = case kind of
      Info    -> "info"
      Error   -> "error"
      Warning -> "warning"
      Success -> "success"
  in
    notify (msgType, msg)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    LoadSponsors loaded  -> { model | sponsors = loaded } ! []
    LoadBoard    members -> { model | board    = members} ! []
    LoadVideos   videos  -> { model | videos   = videos}  ! []
    LoadEvents   events  -> ( model |> assignEvents events) ! []
    ToggleMenu           -> { model | openMenu = not model.openMenu} ! []
    ToggleSlack          -> { model | showSlack = not model.showSlack} ! []
    UpdateEmail  email   -> { model | slackEmail = email} ! []
    PostToSlack          -> model ! [postToSlack model.slackEmail]
    SlackSuccess res     -> { model | showSlack = False, slackEmail = "" } ! [notifySlackResponse res]
    ApiFail error        -> model ! [notifyUser Error <| errorMsg error]
    _ -> model ! []

notifySlackResponse res =
  let 
    error = res.error |> Maybe.withDefault "(no details, sorry)"
  in
    case res.ok of
      True  -> notifyUser Success "Registration sent!"
      False -> notifyUser Error  <| "Something happened with Slack: " ++ error

errorMsg e =
  case e of
    Http.Timeout -> "Sorry, the call timeout"
    Http.NetworkError        -> "Sorry, network error"
    Http.UnexpectedPayload s -> "Sorry, unexpected payload " ++ s
    Http.BadResponse code s  -> "Sorry, server responded with " ++ s

assignEvents events model =
  let
    completed = events |> List.filter (withStatus Completed)
    maybeNext = events |> List.filter (withStatus Live) |> List.head
  in 
    { model | next = maybeNext, pastEvents = completed }

-----------------
-- Api queries --
-----------------
urlFor =
  (++) "http://localhost:8083/api/"
  -- (++) "http://api.winnipegdotnet.org/api/"


postToSlack : Email -> Cmd Msg
postToSlack email =
  Http.send Http.defaultSettings
    { verb = "POST"
    , headers = [("Content-type", "application/x-www-form-urlencoded")]
    , url = urlFor "slack"
    , body = Http.string <| "email=" ++ (uriEncode email)
    }
  |> fromJson slackDecoder
  |> Task.perform ApiFail SlackSuccess

getResource resource decoder success =
  resource
  |> urlFor
  |> Http.get decoder
  |> Task.perform ApiFail success

getEvents = getResource "events" eventDecoder LoadEvents

getBoard = getResource "board" boardDecoder LoadBoard

getSponsors = getResource "sponsors" sponsorDecoder LoadSponsors

getVideos = getResource "videos" videoDecoder LoadVideos

