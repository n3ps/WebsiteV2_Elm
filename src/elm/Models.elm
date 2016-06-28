module Models exposing (..)

import Date exposing (Date)
import Random 
import Json.Decode as Json exposing ((:=))
import Json.Decode.Extra as JsonX
import Dict

import Components.Sponsors as Sponsors

type Resource val = Loading | Loaded val

type Season = Summer | Winter | InBetween | Ready Event

type alias Model = 
  { next : Resource Season
  , pastEvents : List Event
  , sponsors   : Sponsors.Model
  , board      : List BoardMember
  , videos     : List Video
  , tweets     : Resource (List Tweet)
  , openMenu: Bool
  , showSlack: Bool
  , slackEmail: String
  , version: String
  }

emptyModel = 
  { next = Loading
  , board = []
  , pastEvents = []
  , sponsors = Sponsors.emptyModel
  , videos = []
  , tweets = Loading
  , openMenu = False
  , showSlack = False
  , slackEmail = ""
  , version = "0.0.0-no-hash-here"
  }

type alias TweeterUser ={ id: String, handle: String, name: String, url: String, image: String }

type alias Tweet =
  { text  : String
  , date  : Date
  , user  : TweeterUser
  }

type alias Video = 
  { title:String
  , link: String
  , description: String
  , date: Date
  , thumbnail: String
  }

type alias BoardMember = 
  { name: String
  , image: String
  , role: String
  , contact: String
  }

type alias Venue = { name : String , address : String }

type EventStatus = Live | Completed | Unknown

type alias Event = 
  { title : String
  , date : Date
  , description : String
  , logo : String
  , venue : Venue
  , link : String
  , status: EventStatus
  }

withStatus st e = e.status == st

type alias SlackResponse = 
  { ok: Bool
  , error: Maybe String
  }

-- Decoders
--
slackDecoder =
  Json.object2 
    SlackResponse
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
        "live" -> Live
        "completed" -> Completed
        _ -> Unknown


    seasonDecoder (cfg, events) =
      let
        past = events |> List.filter (withStatus Completed)
        season =
          case cfg of
            (True, _) -> Summer
            (_, True) -> Winter
            _         -> 
              events 
              |> List.filter (withStatus Live) 
              |> List.head
              |> Maybe.map Ready 
              |> Maybe.withDefault InBetween
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
          Event
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
      BoardMember
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
      Video
        ("title"       := Json.string)
        ("link"        := Json.string)
        ("description" := Json.string)
        ("date"        := JsonX.date)
        ("thumbnail"   := Json.string)


tweetDecoder =
  let
    userDecoder =
      Json.object5
        TweeterUser
        ("id"   := Json.string)
        ("screen_name" := Json.string)
        ("name" := Json.string)
        ("url"  := Json.string)
        ("profile_image_url" := Json.string)

  in
    Json.at ["tweets"]
    <| Json.list
    <| Json.object3
        Tweet
        ("text" := Json.string)
        ("created_at" := JsonX.date)
        ("user" := userDecoder)
