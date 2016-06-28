module Messages exposing (..)

import Models exposing (BoardMember, Event, Video, SlackResponse, Season, Tweet)
import Http

import Components.Sponsors as Sponsors

type alias Email = String

type Msg
  = SponsorsMsg Sponsors.Msg
  | LoadBoard    (List BoardMember)
  | LoadEvents   (Season, List Event)
  | LoadVideos   (List Video)
  | LoadTweets   (List Tweet)
  | ToggleMenu
  | ToggleSlack
  | PostToSlack
  | SlackSuccess SlackResponse
  | UpdateEmail  Email
  | ApiFail      Http.Error
  | SetVersion   String
  | NoOp


