module Main where

import StartApp
import Task exposing (Task)
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)
import Html exposing (Html)

import Views exposing (..)
import Models exposing (..)
import Actions exposing (..)

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
-- My functions
--
init : (Model, Effects Action)
init = ({ next = Nothing, pastEvents = [], sponsors = [] }, Effects.none)

update : Action -> Model -> (Model, Effects Action)
update action model = 
  case action of
    NoOp -> (model, Effects.none)

