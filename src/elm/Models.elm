module Models where

import Date exposing (Date)

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
  }

type alias Sponsor = 
  { name : String
  , url : String
  , image : String
  }


