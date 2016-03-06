module Actions (..) where

import Models exposing (Sponsor, BoardMember)

type Action
  = LoadSponsors (Maybe (List Sponsor))
  | LoadBoard    (Maybe (List BoardMember))
  | NoOp


