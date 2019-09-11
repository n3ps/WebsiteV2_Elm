module Api exposing (..)

import Json.Decode as Decode exposing (Decoder, nullable, bool, int, list, string, succeed)
import Json.Decode.Pipeline exposing (optional, required)
import Time
import Task exposing (Task)
import Http 
import Url
import Iso8601

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
  (++) "https://winnipegdotnetugapi.azurewebsites.net/api/"
  --(++) "http://api.winnipegdotnet.org/api/"

resources = [getEvents, getBoard, getVideos, getTweets, getSponsors]



handleSlackResponse fail success result =
  case result of
    (Ok data) -> SocialMsg (success data)
    (Err msg) -> ApiFail fail msg 

postToSlack email fail success =
  let 
      body = Http.stringBody "application/x-www-form-urlencoded" <| ("email=" ++ (Url.percentEncode email))
  in
     Http.post { url = urlFor "slack"
               , body = body
               , expect = Http.expectJson (handleSlackResponse fail success) slackDecoder
               }
     --|> Http.get (handleSlackResponse fail success)

handleResourceResponse fail msg result =
  case result of
    (Ok data) -> msg data
    (Err m)   -> fail m


getResource resource decoder fail msg =
  Http.get { url = urlFor resource
           , expect = Http.expectJson (handleResourceResponse (ApiFail fail) msg) decoder
           }
  --|> Http.get (handleResourceResponse (ApiFail fail) msg)
--resource
--  |> urlFor
--  |> Http.get decoder
--  |> Task.perform (ApiFail fail) msg

getEvents   = getResource "events"   eventsDecoder  Messages.Events (Events.Load   >> EventsMsg)
getBoard    = getResource "board"    boardDecoder   Messages.NotifyUser (Board.Load    >> BoardMsg)
getSponsors = getResource "sponsors" sponsorDecoder Messages.NotifyUser (Sponsors.Load >> SponsorsMsg)
getVideos   = getResource "videos"   videoDecoder   Messages.NotifyUser (Videos.Load   >> VideosMsg)
getTweets   = getResource "tweets"   tweetDecoder   Messages.Tweets (Resource.Loaded >> Just >> Tweets.Load >> TweetsMsg)


----------------
--- Decoders ---
----------------

slackDecoder =
  Decode.succeed Social.SlackResponse
    |> required "ok" bool
    |> required "error" (nullable string) 

venueDecoder = 
  Decode.succeed  Venue
    |> required "name" string
    |> required "address" string


decodeTime : Decode.Decoder Time.Posix
decodeTime = Iso8601.decoder

eventsDecoder  =
  let 
    toStatus s = 
      case s of
        "upcoming"  -> Events.Live
        "completed" -> Events.Completed
        _           -> Events.Unknown


    seasonDecoder (cfg, events) =
      let
        past = events |> List.filter (withStatus Events.Completed)
        live = events |> List.filter (withStatus Events.Live) 
        (season, upcoming) =
          case cfg of
            (True, _) -> (Events.Summer, [])
            (_, True) -> (Events.Winter, [])
            _         -> 
              case live of
                []     -> (Events.InBetween, [])
                hd::tl -> (Events.Ready hd, tl) 
              
      in
        (season, upcoming, past)

    cfgDecoder =
      Decode.succeed (\summer winter -> (summer, winter))
        |> required "isSummer" bool
        |> required "isWinter" bool

    eventDecoder = 
        Decode.succeed Events.Event
          |> required "title"  string
          |> required "date"   decodeTime
          |> required "description" string
          |> required "logo"        string
          |> required "venue"       venueDecoder
          |> required "link"        string
          |> required "status"      (Decode.map toStatus string)
  
 
    eventListDecoder = 
        Decode.list eventDecoder
        
  in 
    Decode.succeed
      (\config events -> (config, events))
      |> required "config" cfgDecoder
      |> required "events" eventListDecoder
    |> Decode.map seasonDecoder

boardDecoder =
  Decode.at ["board"]
  <| Decode.list 
  <| (Decode.succeed
      Board.BoardMember
      |> required "name"    string
      |> required "imgUrl"  string
      |> required "role"    string
      |> required "contact" string)

sponsorDecoder =
  Decode.at ["sponsors"]
  <| Decode.list 
  <| (Decode.succeed
      Sponsors.Sponsor
      |> required "name"   string
      |> required "url"    string
      |> required "imgUrl" string)

videoDecoder =
  Decode.at ["videos"]
  <| Decode.list
  <| (Decode.succeed
      Videos.Video
        |> required "title"       string
        |> required "link"        string
        |> required "description" string
        |> required "date"        decodeTime
        |> required "thumbnail"   string)


tweetDecoder =
  let
    userDecoder =
      Decode.succeed
        Tweets.TweeterUser
        |> required "id"   string
        |> required "screen_name" string
        |> required "name" string
        |> required "url"  string
        |> required "profile_image_url" string
    
    entityDecoder =
      Decode.succeed
        Tweets.TweetEntity
        |> required "urls" (list urlDecoder)
    
    urlDecoder =
      Decode.succeed
        Tweets.TweetUrl
        |> required "url" string

  in
    Decode.at ["tweets"]
    <| Decode.list
    <| (Decode.succeed
        Tweets.Tweet
        |> required "text" string
        |> required "created_at" decodeTime
        |> required "user" userDecoder
        |> required "entity" entityDecoder)
