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

import Components.Sponsors as Sponsors

main = 
  Html.programWithFlags
    { init = init, view = view, update = update, subscriptions = (\_ -> Sub.none) }

--
-- My functions
--
init : {version:String} -> (Model, Cmd Msg)
init {version} =
  ({emptyModel|version=version}, Cmd.batch [getSponsors, getBoard, getEvents, getVideos, getTweets])

port notify : (String, String) -> Cmd msg

type Notification = Info | Error | Warning | Success

notifyUser : Notification -> String -> Cmd msg
notifyUser kind msg =
  (case kind of
    Info    -> "info"
    Error   -> "error"
    Warning -> "warning"
    Success -> "success")
  |> flip (,) msg
  |> notify 

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    SponsorsMsg aMsg -> Sponsors.update aMsg model
    LoadBoard    members -> { model | board    = members} ! []
    LoadVideos   videos  -> { model | videos   = videos}  ! []
    LoadEvents   (s, p)  -> { model | pastEvents = p, next = Loaded s } ! []
    LoadTweets   tweets  -> { model | tweets = Loaded tweets } ! []
    ToggleMenu           -> { model | openMenu = not model.openMenu} ! []
    ToggleSlack          -> { model | showSlack = not model.showSlack} ! []
    UpdateEmail  email   -> { model | slackEmail = email} ! []
    PostToSlack          -> model ! [postToSlack model.slackEmail]
    SlackSuccess res     -> { model | showSlack = False, slackEmail = "" } ! [notifySlackResponse res]
    ApiFail error        -> model ! [notifyUser Error <| errorMsg error]
    SetVersion v         -> { model | version = v } ! []
    _ -> model ! []

notifySlackResponse res =
  if res.ok then notifyUser Success "Registration sent!"
  else
    res.error 
    |> Maybe.withDefault "(no details, sorry)"
    |> (++) "Something happened with Slack: "
    |> notifyUser Error  

errorMsg e =
  case e of
    Http.Timeout -> "Sorry, the call timeout"
    Http.NetworkError        -> "Sorry, network error"
    Http.UnexpectedPayload s -> "Sorry, unexpected payload " ++ s
    Http.BadResponse code s  -> "Sorry, server responded with " ++ s


-----------------
-- Api queries --
-----------------
urlFor =
  -- (++) "http://localhost:8083/api/"
  (++) "http://api.winnipegdotnet.org/api/"


postToSlack : Email -> Cmd Msg
postToSlack email =
  { verb = "POST"
  , headers = [("Content-type", "application/x-www-form-urlencoded")]
  , url = urlFor "slack"
  , body = Http.string <| "email=" ++ (uriEncode email)
  }
  |> Http.send Http.defaultSettings
  |> fromJson slackDecoder
  |> Task.perform ApiFail SlackSuccess

getResource resource decoder msg =
  resource
  |> urlFor
  |> Http.get decoder
  |> Task.perform ApiFail msg

getEvents   = getResource "events"   eventsDecoder  LoadEvents
getBoard    = getResource "board"    boardDecoder   LoadBoard
getSponsors = getResource "sponsors" sponsorDecoder Sponsors.LoadSponsors
getVideos   = getResource "videos"   videoDecoder   LoadVideos
getTweets   = getResource "tweets"   tweetDecoder   LoadTweets

