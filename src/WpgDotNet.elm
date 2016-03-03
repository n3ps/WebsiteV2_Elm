module WpgDotNet where

import StartApp
import Task exposing (Task)
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)
import Html exposing (..)
import Html.Attributes exposing (..)
import Date exposing (Date)

--
-- StartApp boilerplate
--
app =
  StartApp.start { init = init, view = view, update = update, inputs = [] }

main : Signal Html
main =
  app.html

port tasks : Signal (Task Never ())
port tasks =
  app.tasks

--
-- My type declarations
--
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

type Action = NoOp

--
-- My functions
--
init : (Model, Effects Action)
init = ({ next = Nothing, pastEvents = [], sponsors = [] }, Effects.none)

update : Action -> Model -> (Model, Effects Action)
update action model = 
  case action of
    NoOp -> (model, Effects.none)

view : Address Action -> Model -> Html
view address model = 
  div [class "outside-container"]
    [ div [class "social-media"] [text "Social media"]
    , div [class "wpg-header"] [text "Winnipeg .NET User Group"] 
    , div [class "next-event"] [text "Next event goes here"] 
    ]
