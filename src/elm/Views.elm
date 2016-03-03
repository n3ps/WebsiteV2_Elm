module Views (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Signal, Address)

import Actions exposing (..)
import Models exposing (..)

view : Address Action -> Model -> Html
view address model = 
  div [class "container"]
    [ header [] [socialMedia, logoMenu]
    , section [class "next-event"] [text "Next event goes here"] 
    , section [class "past-events"] [text "View all past events"]
    , div [class "subscribe-list"] [text "subscribe & twitter stream"]
    , section [class "sponsors"] [text "sponsors go heere"]
    , section [class "contact-us"] [text "Amir, David & Roy"]
    , footer [] [text "here goes the footer"]
    ]

logoMenu =
  div [class "logo-menu"]
    [ img [src "/assets/images/logo.png"] []
    , section [class "motto"]
        [ header [] [text "Winnipeg Dot Net User Group"]
        , div [class "description"] [text "A user group full of lambdas, folds, MVC, ponnies and rainbows!"]
        ]
    , div [class "main-menu"]
        [ a [title "Open Event Brite page", href "http://www.eventbrite.com/org/1699161450", target "_blank"] [text "Events"]
        , a [title "Watch past presentations", href "#watch-us"] [text "Videos"]
        , a [title "Contact us", href "#contact-us"] [text "Contact"]
        ]
    ]

socialMedia = div [class "social-media"] [slackForm, socialIcons]

iconFor icn = i [class <| "fa fa-" ++ icn] []

slackForm =
  div [class "slack-form"]
    [ Html.form
        [class "form-inline", title "Chat with us on Slack"]
        [ div
            [class "form-group"]
            [ label [] [iconFor "slack", text "slack"]
            , div
                [class "input-group"]
                [ input [title "Enter your email and submit to get an invite", class "form-control", type' "text", placeholder "you@domain.com"] []
                , div [class "input-group-addon"]
                   [iconFor "chevron-right"]
    ] ] ] ]

socialIcons =
  let 
    icon id =
      span
        [class "fa-stack fa-2x"]
        [ i [class "fa fa-circle fa-stack-2x"] []
        , i [class <| "fa fa-stack-1x fa-" ++ id] []
        ]
      
    linkTo link i t hint = a [title hint, class "sm-link", href link, target "_blank"] [icon i, text t]
    twitter  = "https://twitter.com/wpgnetug" 
    facebook = "https://www.facebook.com/winnipegdotnet"
    youTube  = "https://www.youtube.com/channel/UC6OzdI6-htXE_97zamJRaaA"
    gitHub   = "https://github.com/WpgDotNetUG/UserGroupWebsite"
  in 
  div [class "social-icons"]
    [ linkTo twitter  "twitter"  "Follow" "Follow us on Twitter"
    , linkTo facebook "facebook" "Like" "Like us on Facebook"
    , linkTo youTube  "youtube-play" "Subscribe" "Subscribe to our YouTube channel to get notifications"
    , linkTo gitHub   "github"   "Fork" "Fork us on GitHub and collaborate"
    ]

