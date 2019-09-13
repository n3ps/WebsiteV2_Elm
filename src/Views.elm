module Views exposing (..) 

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html as App
import Array
import DateFormat exposing (format)
import Random
import String
import Json.Decode as Json

import Branding 
import Messages exposing (..)
import Models exposing (..)

import Components.HtmlHelpers as Helpers exposing (..)
import Components.Sponsors as Sponsors
import Components.Videos as Videos
import Components.Board as Board
import Header.Views as Social
import Components.Events as Events
import Components.Tweets as Tweets
import Resource exposing (Resource)

view : Model -> Html Msg
view model = 
  let ctnrClass = "container" |> toggleIf model.social.openMenu "drawer-open"
  in div [class ctnrClass]
    [ App.map SocialMsg (Social.view model.social)
    , Events.renderNext model.events 
    , Events.renderUpcoming model.events
    --, Events.renderPast model.events
    , Videos.view model.videos
    , Tweets.view model.tweets
    , Sponsors.view model.sponsors
    , Board.view model.board
    , footer [class "main-footer"] 
        [ divL "menu" menuOptions
        , divT "copyright" ("© " ++ Branding.title ++ " 2019")
        , divT "version" model.version
        ]
    , div [class "backdrop"] []
    ]

img_asset s = "/assets/images/" ++ s



menuOptions =
  [ aBlank [title "Open events page", href Events.eventsUrl ] [text "Events"]
  , a [title "Watch past presentations", href "#watch-us"] [text "Videos"]
  , a [title "Contact us", href "#contact-us"] [text "Contact"]
  ]

