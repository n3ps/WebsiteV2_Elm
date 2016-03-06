module Models where

import Date exposing (Date)
import Json.Decode as Json exposing ((:=))

type alias Model = 
  { next : Maybe Event
  , pastEvents : List Event
  , sponsors : List Sponsor
  }

type alias Venue =
  { name : String
  , address : String
  }

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

sponsorList : Json.Decoder (List Sponsor)
sponsorList =
  Json.at ["sponsors"]
  <| Json.list 
  <| Json.object3 
      Sponsor
      ("name"   := Json.string)
      ("url"    := Json.string)
      ("imgUrl" := Json.string)
