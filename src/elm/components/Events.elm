module Components.Events exposing (..)

import String exposing (split)
import Date exposing (Date)
import Date.Format exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (..) -- (aBlank, anchor, divT, divL, simple, icon, simple', image)
import Resource exposing (..)

-- Model
type Season = Summer | Winter | InBetween | Ready Event

type alias Model =
  { next : Resource Season
  , pastEvents : List Event
  }

type alias Venue = 
  { name : String
  , address : String 
  }

type Status 
  = Live 
  | Completed 
  | Unknown

type alias Event = 
  { title : String
  , date : Date
  , description : String
  , logo : String
  , venue : Venue
  , link : String
  , status: Status
  }

withStatus st e = e.status == st

emptyModel =
  { next = Loading
  , pastEvents = []
  }

-- Update
type Msg
  = Load (Season, List Event)

update (Load (season, past)) model = 
  { model | pastEvents = past, next = Resource.Loaded season } ! []

-- View
renderPast model = 
  let
    mkWidget e = 
      div [class "past-event"]
        [ image "image" e.logo
        , div [class "info"]
            [ divT "title" e.title
            , divT "date"  (e.date |> format "%b %e, %Y")
            , divL "view" [aBlank [class "button -outline", href e.link] [text "View"]]
            ]
        ]

    ofEmpty l = if List.isEmpty l then Nothing else Just l

    eventBrite = "http://www.eventbrite.ca/o/winnipeg-dot-net-user-group-1699161450"
    mkArticle content =
      [ article [] content
      , footer [] [aBlank [class "button -large", href eventBrite] [text "View All"]]
      ]

    content =
      model.pastEvents 
      |> List.take 4 
      |> List.map mkWidget
      |> ofEmpty
      |> Maybe.map mkArticle
      |> Maybe.withDefault [loading]

  in
    section [class "past-events section"]
      ([anchor "past-events", header [] [text "Past Events"]] ++ content)


renderNext model =
  let 
    mkParagraphs txt = txt |> String.split "\n" |> List.map (single p)
    showEvent e =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , article []
            [ image "event-img" e.logo
            , div [class "event-info"]
                [ simple div "title" e.title
                , mkParagraphs e.description |> simple' div "description"
                ]
            , div [class "presenter"] []
            , div [class "details"]
                [ div [class "date"]
                  [ icon "icon" "calendar"
                  , text <| format "%A, %B %e, %Y" e.date
                  ]
                , div [class "venue"]
                  [ icon "icon" "map-marker"
                  , divT "name"    e.venue.name
                  , divT "address" e.venue.address
                  ]
                ]
            , footer [] [aBlank [class "button -large", href e.link] [text "Count me in!"]]
            ]
        ]

    workingOnIt =
      section [class "next-event section -empty"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article [] 
            [ img [src "/assets/images/placeholder.png"] []
            , span [class "placeholder"] [
              text "We are working on it"]
            ]
        ]
        
    loadingEvents =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , loading
        ]

    summer =
      section [class "next-event section summer"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article []
            [ div [class "text"] 
                [ div [class "back-in"] [text "We will be back in Sep"]
                , div [class "message"] [text "Happy Summer!"]
                , div [class "signature"] [text "C#, F# & VB.NET"]
                ]
            ]
        ]

    winter = 
      section [class "next-event section winter"]
        [ anchor "next-event"
        , header  [] [text "Next Event"]
        , article []
            [ div [class "text"] 
                [ div [class "back-in"] [text "We will be back in Jan"]
                , div [class "message"] [text "Happy Holidays!"]
                , div [class "signature"] [text "C#, F# & VB.NET"]
                ]
            ]
        ]

  in 
    case model.next of
      Loading -> loadingEvents
      Loaded Summer -> summer
      Loaded Winter -> winter
      Loaded InBetween     -> workingOnIt
      Loaded (Ready event) -> showEvent event


