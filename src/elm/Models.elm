module Models where

import Date exposing (Date)
import Json.Decode as Json exposing ((:=))

type alias Model = 
  { next : Maybe Event
  , pastEvents : List Event
  , sponsors : List Sponsor
  , board : List BoardMember
  }

type alias BoardMember = {name:String, image: String, role: String, contact: String}

type alias Venue = { name : String , address : String }

type alias Event = 
  { title : String
  , date : Date
  , presenter : String
  , description : String
  , logo : String
  , venue : Venue
  , link : String
  }

type alias Sponsor = 
  { name : String
  , url : String
  , image : String
  }

-- Decoders
boardDecoder : Json.Decoder (List BoardMember)
boardDecoder =
  Json.at ["board"]
  <| Json.list 
  <| Json.object4
      BoardMember
      ("name"    := Json.string)
      ("imgUrl"  := Json.string)
      ("role"    := Json.string)
      ("contact" := Json.string)

sponsorDecoder : Json.Decoder (List Sponsor)
sponsorDecoder =
  Json.at ["sponsors"]
  <| Json.list 
  <| Json.object3 
      Sponsor
      ("name"   := Json.string)
      ("url"    := Json.string)
      ("imgUrl" := Json.string)
