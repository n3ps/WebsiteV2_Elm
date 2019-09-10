module Models exposing (..)

import Random 
import Dict

import Components.Sponsors as Sponsors
import Components.Board as Board
import Components.Videos as Videos
import Header.Models as Social
import Components.Events as Events
import Components.Tweets as Tweets
import Resource exposing (..)


type alias Model = 
  { sponsors   : Sponsors.Model
  , board      : Board.Model
  , videos     : Videos.Model
  , social     : Social.Model
  , events     : Events.Model
  , tweets     : Tweets.Model
  , version: String
  }

emptyModel = 
  { board  = Board.emptyModel 
  , videos = Videos.emptyModel
  , social = Social.emptyModel
  , events = Events.emptyModel
  , sponsors = Sponsors.emptyModel
  , tweets = Just Loading
  , version = "0.0.0-no-hash-here"
  }

