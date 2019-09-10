module Components.Sponsors exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (aBlank, anchor)

-- Model
type alias Model = List Sponsor

type alias Sponsor = 
  { name : String
  , url : String
  , image : String
  }

emptyModel = []

-- Update
type Msg
  = Load Model

update (Load list) model =
  ({ model | sponsors = list }, Cmd.none)

-- View
view sponsors =
  let
    sponsorImage sponsor = 
      div [class "sponsor", title sponsor.name] 
        [aBlank [href sponsor.url] [img [src sponsor.image] []] ]
    sponsorMap = case sponsors of
      [] -> [text "No sponsors information available at the moment"]
      xs -> xs |> List.map sponsorImage

  in section [class "sponsors section"] 
      [ anchor "sponsors"
      , header  [] [text "Sponsors"]
      , article [] sponsorMap
      ]


