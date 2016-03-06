module Main where

import StartApp
import Task exposing (Task)
import Signal exposing (Signal, Address)
import Effects exposing (Effects, Never)
import Html exposing (Html)
import Date
import Http

import Views exposing (..)
import Models exposing (..)
import Actions exposing (..)

--
-- StartApp boilerplate
--
app = StartApp.start { init = init, view = view, update = update, inputs = [] }

main : Signal Html
main = app.html

port tasks : Signal (Task Never ())
port tasks = app.tasks

dateWD = Date.fromString >> Result.withDefault (Date.fromTime 0)

--
-- My functions
--
init : (Model, Effects Action)
init =
  let
    empty = {title="", description="", venue=library, presenter=event.presenter, link=event.link, logo=event.logo, date=dateWD "2016/1/1"}
    description = """
Microservices has taken over in the current buzzword barrage.
With a little suave, you can easily charm this latest trend.
Suave.io is a .Net library which delivers a non-blocking and lightweight web server to create restful APIs.
Being written in F# you gain access to type providers, default immutability, and much other coolness. Suave.io has been refined to a 1.0 release which we are currently using to build the new Winnipeg .Net User Group Api.
We'll go over getting started with Suave.io on building a simple web api and deploy it to Azure.
"""
    library = { address = "211 Donald St.", name = "Millenium library" }
    event = {
      title = "Cool APIs with Suave.io"
      , description = description
      , venue = library
      , presenter = "Shane Charles"
      , link = "https://www.eventbrite.ca/e/faster-apis-with-suaveio-featuring-shane-charles-tickets-20930172710"
      , logo = "https://img.evbuc.com/https%3A%2F%2Fimg.evbuc.com%2Fhttp%253A%252F%252Fcdn.evbuc.com%252Fimages%252F18085935%252F24010033924%252F1%252Foriginal.jpg%3Frect%3D0%252C20%252C692%252C346%26s%3D5f3ce8546d7761b2d5f8fc097a25dd47?h=200&w=450&s=128fa909fa50d212541a8b832b081ec3"
      , date = dateWD "2016/5/1"
    }
    model = { 
      next = Just event, 
      board = [],
      pastEvents = [
          {empty | title="Stealing Time with the .Net ThreadPool", date=dateWD "2016/4/1", link="http://www.eventbrite.ca/e/stealing-time-with-the-net-threadpool-with-adam-krieger-tickets-18061938745"}
        , {empty | title="VS Code-- The Visual Studio For Everyone", date=dateWD "2016/3/1"}
        , {empty | title="Not just for games: Creating slick UIs with Unity, C# and XAML", date=dateWD "2016/2/1"}
        , {empty | title="What to Expect with MVC 6", date=dateWD "2016/1/1"}
      ], 
      sponsors = [] 
    }
  in
    (model, getBoard)

update : Action -> Model -> (Model, Effects Action)
update action model = 
  case action of
    LoadSponsors (Just loaded)  -> ({model | sponsors=loaded}, Effects.none)
    LoadBoard    (Just members) -> ({model | board=members  }, Effects.none)
    _ -> (model, Effects.none)

-- Api queries

-- apiUrl = "http://wpgdotnetapi.azurewebsites.net/api/"
apiUrl = "http://localhost:8083/api/"

getBoard =
  apiUrl ++ "board"
  |> Http.get boardDecoder
  |> Task.toMaybe
  |> Task.map LoadBoard
  |> Effects.task

getSponsors =
  apiUrl ++ "sponsors"
  |> Http.get sponsorDecoder
  |> Task.toMaybe
  |> Task.map LoadSponsors
  |> Effects.task

