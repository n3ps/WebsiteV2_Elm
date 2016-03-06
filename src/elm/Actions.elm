module Actions (..) where

import Models exposing (Sponsor)

type Action
  = LoadSponsors (Maybe (List Sponsor))
  | NoOp


