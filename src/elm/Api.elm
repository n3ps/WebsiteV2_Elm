module Api exposing (..)

import Json.Decode as Json exposing ((:=))
import Json.Decode.Extra as JsonX
import Task exposing (Task)
import Http exposing (..)

import Models exposing (..)
import Messages exposing (..)
import Components.Videos as Videos
import Components.Sponsors as Sponsors
import Components.Board as Board
import Header.Models as Social
import Components.Tweets as Tweets
import Components.Events as Events exposing (withStatus, Status, Venue)
import Resource exposing (Resource)

-----------------
-- Api queries --
-----------------
urlFor =
  -- (++) "http://localhost:8083/api/"
  (++) "http://api.winnipegdotnet.org/api/"

resources = [getEvents, getBoard, getVideos, getTweets, getSponsors]

--postToSlack : Social.Email -> success -> Cmd Msg
postToSlack email failMsg success =
  { verb = "POST"
  , headers = [("Content-type", "application/x-www-form-urlencoded")]
  , url = urlFor "slack"
  , body = Http.string <| "email=" ++ (uriEncode email)
  }
  |> Http.send Http.defaultSettings
  |> fromJson slackDecoder
  |> Task.perform (ApiFail failMsg) (success >> SocialMsg)

getResource resource decoder fail msg =
  resource
  |> urlFor
  |> Http.get decoder
  |> Task.perform (ApiFail fail) msg

getEvents   = getResource "events"   eventsDecoder  Messages.Events (Events.Load   >> EventsMsg)
getBoard    = getResource "board"    boardDecoder   Messages.NotifyUser (Board.Load    >> BoardMsg)
getSponsors = getResource "sponsors" sponsorDecoder Messages.NotifyUser (Sponsors.Load >> SponsorsMsg)
getVideos   = getResource "videos"   videoDecoder   Messages.NotifyUser (Videos.Load   >> VideosMsg)
getTweets   = getResource "tweets"   tweetDecoder   Messages.Tweets (Resource.Loaded >> Just >> Tweets.Load >> TweetsMsg)


----------------
--- Decoders ---
----------------

slackDecoder =
  Json.object2 
    Social.SlackResponse
    ("ok"    := Json.bool)
    (Json.maybe <| "error" := Json.string)

venueDecoder = 
  Json.object2
    Venue
    ("name"    := Json.string)
    ("address" := Json.string)

eventsDecoder  =
  let 
    toStatus s = 
      case s of
        "live"      -> Events.Live
        "completed" -> Events.Completed
        _           -> Events.Unknown


    seasonDecoder (cfg, events) =
      let
        past = events |> List.filter (withStatus Events.Completed)
        season =
          case cfg of
            (True, _) -> Events.Summer
            (_, True) -> Events.Winter
            _         -> 
              events 
              |> List.filter (withStatus Events.Live) 
              |> List.head
              |> Maybe.map Events.Ready 
              |> Maybe.withDefault Events.InBetween
      in
        (season, past)

    cfgDecoder =
      Json.object2
        (,)
        ("isSummer" := Json.bool)
        ("isWinter" := Json.bool)

    eventsDecoder = 
      Json.list 
      <| Json.object7
          Events.Event
          ("title"       := Json.string)
          ("date"        := JsonX.date)
          ("description" := Json.string)
          ("logo"        := Json.string)
          ("venue"       := venueDecoder)
          ("link"        := Json.string)
          ("status"      := Json.map toStatus Json.string)
  
  in 
    Json.object2
      (,)
      ("config" := cfgDecoder)
      ("events" := eventsDecoder)
    |> Json.map seasonDecoder

boardDecoder =
  Json.at ["board"]
  <| Json.list 
  <| Json.object4
      Board.BoardMember
      ("name"    := Json.string)
      ("imgUrl"  := Json.string)
      ("role"    := Json.string)
      ("contact" := Json.string)

sponsorDecoder =
  Json.at ["sponsors"]
  <| Json.list 
  <| Json.object3 
      Sponsors.Sponsor
      ("name"   := Json.string)
      ("url"    := Json.string)
      ("imgUrl" := Json.string)

videoDecoder =
  Json.at ["videos"]
  <| Json.list
  <| Json.object5
      Videos.Video
        ("title"       := Json.string)
        ("link"        := Json.string)
        ("description" := Json.string)
        ("date"        := JsonX.date)
        ("thumbnail"   := Json.string)


tweetDecoder =
  let
    userDecoder =
      Json.object5
        Tweets.TweeterUser
        ("id"   := Json.string)
        ("screen_name" := Json.string)
        ("name" := Json.string)
        ("url"  := Json.string)
        ("profile_image_url" := Json.string)

  in
    Json.at ["tweets"]
    <| Json.list
    <| Json.object3
        Tweets.Tweet
        ("text" := Json.string)
        ("created_at" := JsonX.date)
        ("user" := userDecoder)

