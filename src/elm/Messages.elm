module Messages exposing (..)

import Models exposing (Sponsor, BoardMember, Event, Video, SlackResponse)
import Http

type alias Email = String

type Msg
  = LoadSponsors (List Sponsor)
  | LoadBoard    (List BoardMember)
  | LoadEvents   (List Event)
  | LoadVideos   (List Video)
  | ToggleMenu
  | ToggleSlack
  | PostToSlack
  | SlackSuccess SlackResponse
  | UpdateEmail  Email
  | ApiFail      Http.Error
  | SetVersion   String
  | NoOp


