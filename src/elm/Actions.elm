module Actions (..) where

import Models exposing (Sponsor, BoardMember, Event)

type Action
  = LoadSponsors (Maybe (List Sponsor))
  | LoadBoard    (Maybe (List BoardMember))
  | LoadEvents   (Maybe (List Event))
  | NoOp


