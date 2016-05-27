module Models exposing (..)

import Date exposing (Date)
import Random 
import Json.Decode as Json exposing ((:=))
import Json.Decode.Extra as JsonX

type Resource val = Loading | Loaded val

type Season = Summer | Winter | Active (Maybe Event)

type alias Model = 
  { next : Resource Season
  , pastEvents : List Event
  , sponsors : List Sponsor
  , board : List BoardMember
  , videos : List Video
  , openMenu: Bool
  , showSlack: Bool
  , slackEmail: String
  , version: String
  }

emptyModel = 
  { next = Loading
  , board = []
  , pastEvents = []
  , sponsors = []
  , videos = []
  , openMenu = False
  , showSlack = False
  , slackEmail = ""
  , version = "0.0.0-no-hash-here"
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

type alias Sponsor = 
  { name : String
  , url : String
  , image : String
  }

type alias SlackResponse = 
  {ok: Bool, error: Maybe String}

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
        next = events |> List.filter (withStatus Live) |> List.head
        toSeason cfg =
          case cfg of
            (True, _) -> Summer
            (_, True) -> Winter
            _         -> Active next
      in
        (toSeason cfg, past)

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
      Sponsor
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
