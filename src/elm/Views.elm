module Views (..) where

import Html exposing (..)
import Html.Attributes exposing (..)
import Signal exposing (Signal, Address)
import Date
import Date.Format exposing (format)

import Actions exposing (..)
import Models exposing (..)

view : Address Action -> Model -> Html
view address model = 
  div [class "container"]
    [ header [] [socialMedia, logoMenu]
    , nextEvent model.next
    , pastEvents model.pastEvents
    , featuredVideos
    , listRegistration
    , section [class "sponsors"] [text "sponsors go heere"]
    , section [class "contact-us"] [text "Amir, David & Roy"]
    , footer [] [text "here goes the footer"]
    ]

aBlank xs = a <| target "_blank"::xs

featuredVideos =
  div [class "featured-videos"] [text "Features videos from youtube"]

listRegistration =
  div [class "list-n-twitter"]
    [ article [class "subscribe"]
        [ header [] [text "Want to make sure you don't miss a meeting?"]
        , div [class "signup"] [text "Then take a minute and sign up for the Winnipeg .NET user group mailing list!"]
        , div [class "schedule"] [text "You can be on top of our event schedule, and all you need to do is check you email. Sign up now and don't miss another meeting." ]
        , footer [] [aBlank [href "http://eepurl.com/clTOr"] [text "Add me to the list"]]
        ]
    , article [class "twitter-stream"]
        [text "twitter stream"]
    ]

pastEvents events =
  let
    mkWidget e = 
      div [class "past-event"]
        [ div [class "image"] [img [src e.logo] []]
        , div [class "info"]
            [ div [class "title"] [text e.title]
            , div [class "date"] [text <| format "%b %e, %Y" e.date]
            , div [class "view"] [aBlank [href e.link] [text "View"]]
            ]
        ]
  in
    section [class "past-events"]
      [ header  [class "event-header"] [text "Past Events"] 
      , article [] (events |> List.take 4 |> List.map mkWidget)
      , footer [] [aBlank [href "http://www.eventbrite.ca/o/winnipeg-dot-net-user-group-1699161450"] [text "View All"]]
      ]

nextEvent =
  let 
    showEvent e =
      section [class "next-event"]
        [
          header  [class "event-header"] [text "Next Event"]
        , article []
            [ div [class "event-img"] [img [src e.logo] []]
            , div [class "event-info"]
                [ div [class "title"] [text e.title]
                , label [] [text "Description"]
                , div [class "description"] [text e.description ]
                , div [class "date"       ]
                    [ div [class "icon"] [iconFor "calendar"]
                    , text <| format "%A, %B %e, %Y" e.date
                    ]
                , div [class "venue"]
                    [ div [class "icon"] [iconFor "map-marker"]
                    , span [class "name"] [text e.venue.name]
                    , span [class "address"] [text e.venue.address]
                    ]
                , footer [] [aBlank [href e.link] [text "Count me in!"]]
                ]
            ]
        ]

    workingOnIt =
      section [class "next-event"]
        [
          header  [] [text "We are working on it"]
        , article [] [text "Like crazy"]
        ]

  in Maybe.map showEvent >> Maybe.withDefault workingOnIt

logoMenu =
  div [class "logo-menu"]
    [ img [src "/assets/images/logo.png"] []
    , section [class "motto"]
        [ header [] [text "Winnipeg Dot Net User Group"]
        , div [class "description"] [text "A user group full of lambdas, folds, MVC, ponnies and rainbows!"]
        ]
    , div [class "main-menu"]
        [ aBlank [title "Open Event Brite page", href "http://www.eventbrite.com/org/1699161450"] [text "Events"]
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

