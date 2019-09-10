module Messages exposing (..)

import Http

import Components.Sponsors as Sponsors
import Components.Videos as Videos
import Components.Board as Board
import Components.Events as Events
import Header.Messages as Social
import Components.Tweets as Tweets

type LoadError
  = Events
  | Tweets
  | NotifyUser

type Msg
  = SponsorsMsg Sponsors.Msg
  | VideosMsg   Videos.Msg
  | BoardMsg    Board.Msg
  | SocialMsg   Social.Msg
  | EventsMsg   Events.Msg
  | TweetsMsg   Tweets.Msg
  | ApiFail     LoadError Http.Error
  | NoOp


