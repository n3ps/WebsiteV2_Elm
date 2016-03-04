module Main where

import StartApp
import Task exposing (Task)
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)
import Html exposing (Html)
import Date

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
init =
  let
    description = """
Microservices has taken over in the current buzzword barrage.
With a little suave, you can easily charm this latest trend.
Suave.io is a .Net library which delivers a non-blocking and lightweight web server to create restful APIs.
Being written in F# you gain access to type providers, default immutability, and much other coolness. Suave.io has been refined to a 1.0 release which we are currently using to build the new Winnipeg .Net User Group Api.
We'll go over getting started with Suave.io on building a simple web api and deploy it to Azure.
"""
    library = { address = "211 Donald St.", name = "Millenium library" }
    nextMonth = Date.fromString "2011/1/1" |> Result.withDefault (Date.fromTime 0)
    event = {
      title = "Cool APIs with Suave.io"
      , description = description
      , venue = library
      , presenter = "Shane Charles"
      , link = ""
      , logo = "https://img.evbuc.com/https%3A%2F%2Fimg.evbuc.com%2Fhttp%253A%252F%252Fcdn.evbuc.com%252Fimages%252F18085935%252F24010033924%252F1%252Foriginal.jpg%3Frect%3D0%252C20%252C692%252C346%26s%3D5f3ce8546d7761b2d5f8fc097a25dd47?h=200&w=450&s=128fa909fa50d212541a8b832b081ec3"
      , date = nextMonth
    }
    model = { next = Just event, pastEvents = [], sponsors = [] }
  in
    (model, Effects.none)

update : Action -> Model -> (Model, Effects Action)
update action model = 
  case action of
    NoOp -> (model, Effects.none)

