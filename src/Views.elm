module Views (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Signal, Address)

import Actions exposing (..)
import Models exposing (..)

view : Address Action -> Model -> Html
view address model = 
  div [class "outside-container"]
    [ div [class "social-media"] [text "Social media"]
    , div [class "wpg-header"] [text "Winnipeg .NET User Group"] 
    , div [class "next-event"] [text "Next event goes here"] 
    ]

