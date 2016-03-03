module Models(..) where

import Date exposing (Date)

type alias Model = 
  { next : Maybe Event
  , pastEvents : List Event
  , sponsors : List Sponsor
  }

type alias Event = 
  { title : String
  , date : Date
  , presenter : String
  , location : String
  }

type alias Sponsor = 
  { name : String
  , url : String
  , image : String
  }


