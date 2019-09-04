module Header.Messages exposing (..)

import Header.Models exposing (SlackResponse, Email)

type Msg
  = ToggleMenu
  | ToggleSlack
  | PostToSlack
  | SlackSuccess SlackResponse
  | UpdateEmail  Email
  | NoOp

