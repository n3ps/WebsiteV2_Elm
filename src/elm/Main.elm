module Main exposing (..)

import Task exposing (Task)
import Html.App as Html
import Date
import Http exposing (..)
import Random
import Json.Decode as Json exposing ((:=))
import Json.Encode as JsonEnc

import Views exposing (..)
import Models exposing (..)
import Messages exposing (..)
import Api
import Notify exposing (..)

import Components.Sponsors as Sponsors
import Components.Videos as Videos
import Components.Board as Board
import Header.Update as Social
import Components.Events as Events
import Components.Tweets as Tweets
import Resource exposing (Resource)

main = 
  Html.programWithFlags
    { init = init, view = view, update = update, subscriptions = (\_ -> Sub.none) }

--
-- My functions
--
init : {version:String} -> (Model, Cmd Msg)
init {version} =
  ({emptyModel | version = version}, Cmd.batch Api.resources)

mapFst f (a, b) = (f a, b)

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  let
    updateEvents ev = { model | events = ev } 
    updateSocial sc = { model | social = sc }
    updateTweets tw = { model | tweets = tw }
  in
    case msg of
      SponsorsMsg msg' -> Sponsors.update msg' model
      VideosMsg   msg' -> Videos.update   msg' model
      BoardMsg    msg' -> Board.update    msg' model
      EventsMsg   msg' -> Events.update   msg' model.events |> mapFst updateEvents
      SocialMsg   msg' -> Social.update   msg' model.social |> mapFst updateSocial
      TweetsMsg   msg' -> Tweets.update   msg' model.tweets |> mapFst updateTweets
      ApiFail error    -> model ! [notifyUser Error <| errorMsg error]
      _ -> model ! []


errorMsg e =
  case e of
    Http.Timeout -> "Sorry, the call timeout"
    Http.NetworkError        -> "Sorry, network error"
    Http.UnexpectedPayload s -> "Sorry, unexpected payload " ++ s
    Http.BadResponse code s  -> "Sorry, server responded with " ++ s


