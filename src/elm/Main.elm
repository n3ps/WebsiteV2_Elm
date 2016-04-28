module Main exposing (..)

import Task exposing (Task)
import Html.App as Html
import Date
import Http
import Random

import Views exposing (..)
import Models exposing (..)
import Messages exposing (..)

main = 
  Html.program 
    { init = init, view = view, update = update, subscriptions = \_ -> Sub.none}

--
-- My functions
--
init : (Model, Cmd Msg)
init =
  (emptyModel, Cmd.batch [getSponsors, getBoard, getEvents, getVideos])

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  case msg of
    LoadSponsors loaded  -> ({model | sponsors= loaded }, Cmd.none)
    LoadBoard    members -> ({model | board   = members}, Cmd.none)
    LoadVideos   videos  -> ({model | videos  = videos}, Cmd.none)
    LoadEvents   events  -> (assignEvents events model, Cmd.none)
    ToggleMenu           -> ({model | openMenu=not model.openMenu}, Cmd.none)
    ToggleSlack          -> ({model | showSlack=not model.showSlack}, Cmd.none)
    _ -> (model, Cmd.none)


assignEvents events model =
  let
    completed = events |> List.filter (\e -> e.status == Completed)
    maybeNext = events |> List.filter (\e -> e.status == Live) |> List.head
  in {model | next=maybeNext, pastEvents=completed}

-- Api queries

apiUrl = "http://api.winnipegdotnet.org/api/"
-- apiUrl = "http://localhost:8083/api/"

getResource resource decoder success =
  apiUrl ++ resource
  |> Http.get decoder
  |> Task.perform ResourceFailed success

getEvents = getResource "events" eventDecoder LoadEvents

getBoard = getResource "board" boardDecoder LoadBoard

getSponsors = getResource "sponsors" sponsorDecoder LoadSponsors

getVideos = getResource "videos" videoDecoder LoadVideos

