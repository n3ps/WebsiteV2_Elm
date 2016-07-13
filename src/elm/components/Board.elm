module Components.Board exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (aBlank, anchor, divT, divL)

-- Model
type alias Model = List BoardMember

type alias BoardMember = 
  { name: String
  , image: String
  , role: String
  , contact: String
  }

emptyModel = []

-- Update
type Msg
  = Load Model

update (Load members) model = 
  { model | board = members } ! []

-- View
view members =
  let
    mailTo = (++) "mailto:winnipegdotnet@gmail.com?subject=ATTN: "
    mkContact mbr = div [class "member", title mbr.name]
      [ div [class "avatar"] [img [src mbr.image] []]
      , divT "name" mbr.name
      , divT "role" mbr.role
      , divL "contact" [a [class "button -outline -small", href <| mailTo mbr.contact] [text mbr.contact]]
      ] 
    contactMap = case members of
      [] -> [text "No contact information available at the moment"]
      xs -> xs |> List.map mkContact

  in section [class "contact-us section"] 
      [ anchor "contact-us"
      , header  [] [text "Contact Us"]
      , article [] 
          [ divT "message" "Looking to reach out directly to the Winnipeg .NET User Group board? Click on the board member to ask your query."
          , divL "members" contactMap
          ]
      ]


