module Messages exposing (..)

import Models exposing (Sponsor, BoardMember, Event, Video)
import Http


type Msg
  = LoadSponsors (List Sponsor)
  | LoadBoard    (List BoardMember)
  | LoadEvents   (List Event)
  | LoadVideos   (List Video)
  | ToggleMenu
  | ToggleSlack
  | ResourceFailed Http.Error
  | NoOp


