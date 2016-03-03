module Views (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Signal, Address)

import Actions exposing (..)
import Models exposing (..)

view : Address Action -> Model -> Html
view address model = 
  div [class "container"]
    [ header [] [socialMedia, bannerMenu]
    , section [class "next-event"] [text "Next event goes here"] 
    , section [class "past-events"] [text "View all past events"]
    , div [class "subscribe-list"] [text "subscribe & twitter stream"]
    , section [class "sponsors"] [text "sponsors go heere"]
    , section [class "contact-us"] [text "Amir, David & Roy"]
    , footer [] [text "here goes the footer"]
    ]

bannerMenu =
  div [class "banner-menu"] [text "Winnipeg Dot Net User Group ponnies and rainbows"]

socialMedia = div [class "social-media"] [slackForm, socialIcons]

iconFor icn = i [class <| "fa fa-" ++ icn] []

slackForm =
  div
    [class "slack-form"]
    [ Html.form
        [class "form-inline"]
        [ div
            [class "form-group"]
            [ label [] [iconFor "slack", text "slack"]
            , div
                [class "input-group"]
                [ input [class "form-control", type' "text", placeholder "you@domain.com"] []
                , div [class "input-group-addon"]
                   [iconFor "chevron-right"]
                ]
            ]
        ]
    ]

socialIcons =
  let 
    icon id =
      span
        [class "fa-stack fa-2x"]
        [ i [class "fa fa-circle fa-stack-2x"] []
        , i [class <| "fa fa-stack-1x fa-" ++ id] []
        ]
      
    linkTo link i t = a [class "sm-link", href link, target "_blank"] [icon i, text t]
    twitter  = "https://twitter.com/wpgnetug" 
    facebook = "https://www.facebook.com/winnipegdotnet"
    youTube  = "https://www.youtube.com/channel/UC6OzdI6-htXE_97zamJRaaA"
    gitHub   = "https://github.com/WpgDotNetUG/UserGroupWebsite"
  in 
  div [class "social-icons"]
    [ linkTo twitter  "twitter"  "Follow"
    , linkTo facebook "facebook" "Like"
    , linkTo youTube  "youtube-play" "Subscribe"
    , linkTo gitHub   "github"   "Fork"
    ]

