module Components.Events exposing (..)

import Task exposing (Task)
import Time exposing (Posix)
import String exposing (split)
import DateFormat exposing (format)
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (..) -- (aBlank, anchor, divT, divL, simple, icon, simpleClass, image)
import Resource exposing (..)

-- Model
type Season = Summer | Winter | InBetween | Ready Event

type alias Model =
  { next : Maybe (Resource Season)
  , upcomingEvents : List Event
  , pastEvents : Maybe (List Event)
  , timeZone : Time.Zone
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
  , date : Time.Posix 
  , description : String
  , logo : String
  , venue : Venue
  , link : String
  , status: Status
  }

eventsUrl = "https://www.meetup.com/fullstackmb/events/"
withStatus st e = e.status == st

displayUtc zone =
  case zone == Time.utc of
    True -> "(UTC)"
    _    -> ""

standardEventDate timeZone date = 
  format [ DateFormat.monthNameAbbreviated
         , DateFormat.text " "
         , DateFormat.dayOfMonthNumber
         , DateFormat.text ", "
         , DateFormat.yearNumber
         ]
         timeZone
         date

emptyModel =
  { next = Just Loading
  , upcomingEvents = []
  , pastEvents = Just [] 
  , timeZone = Time.utc 
  }

initCmd = Task.perform GotTimeZone Time.here

ofEmpty l = if List.isEmpty l then Nothing else Just l

-- Update
type Msg
  = Load (Season, List Event, List Event)
  | Error
  | GotTimeZone Time.Zone

update msg model =
  case msg of
    Load (season, upcoming, past) -> ({ model | pastEvents = Just past, upcomingEvents = upcoming, next = Just (Resource.Loaded season) }, Cmd.none)

    Error -> ({ model | pastEvents = Nothing, next = Nothing, upcomingEvents = [] }, Cmd.none)

    GotTimeZone zone ->
      ({ model | timeZone = zone }, Cmd.none)

-- View
renderUpcoming model =
  case model.upcomingEvents of
    []     -> section [] []
    events -> 
      let 
          mkWidget e = 
            div [class "past-event"]
              [ image "image" e.logo
              , div [class "info"]
                  [ divT "title" e.title
                  , divT "date"  (e.date |> standardEventDate model.timeZone)
                  , divL "view" [aBlank [class "button -outline", href e.link] [text "View"]]
                  ]
              ]

          mkArticle details =
              [ article [] details
              , footer [] []
              ]

          content =
              events 
              |> List.take 4 
              |> List.map mkWidget
              |> ofEmpty
              |> Maybe.map mkArticle
              |> Maybe.withDefault [loading]
      in 
        section [class "past-events section"]
          ([anchor "past-events", header [] [text "Upcoming Events"]] ++ content)

renderPast model = 
  let
    mkWidget e = 
      div [class "past-event"]
        [ image "image" e.logo
        , div [class "info"]
            [ divT "title" e.title
            , divT "date"  (e.date |> standardEventDate model.timeZone)
            , divL "view" [aBlank [class "button -outline", href e.link] [text "View"]]
            ]
        ]
    
    errorLoading = 
      [ div [class "error"]
          [ h1 [] [text ";("]
          , div [] [text "Could not load past events"]
          ]]

    mkArticle details =
      [ article [] details
      , footer [] [aBlank [class "button -large", href eventsUrl] [text "View All"]]
      ]

    content =
      case model.pastEvents of
        Nothing -> errorLoading
        Just pastEvents ->
          pastEvents 
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
                , mkParagraphs e.description |> simpleClass div "description"
                ]
            , div [class "presenter"] []
            , div [class "details"]
                [ div [class "date"]
                  [ icon "icon" "calendar"
                  , text  (format  [ DateFormat.dayOfWeekNameFull
                                   , DateFormat.text ", "
                                   , DateFormat.monthNameFull
                                   , DateFormat.text " "
                                   , DateFormat.dayOfMonthNumber
                                   , DateFormat.text " at "
                                   , DateFormat.hourNumber
                                   , DateFormat.text ":"
                                   , DateFormat.minuteFixed
                                   , DateFormat.text " "
                                   , DateFormat.amPmUppercase
                                   ] model.timeZone e.date)
                  , text (" " ++ displayUtc model.timeZone)
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
    errorLoading =
      section [class "next-event section"]
        [ anchor "next-event"
        , simple header "header" "Next Event"
        , article []
            [ div [class "error"]
              [ h1 [] [text ";("]
              , div [] [text "Could not load next event"]
              ]
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
      Nothing -> errorLoading
      Just Loading -> loadingEvents
      Just (Loaded Summer) -> summer
      Just (Loaded Winter) -> winter
      Just (Loaded InBetween)     -> workingOnIt
      Just (Loaded (Ready event)) -> showEvent event


