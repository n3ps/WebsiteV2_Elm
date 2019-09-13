module Components.Videos exposing (..)

import Time
import Branding
import Html exposing (..)
import Html.Attributes exposing (..)
import Components.HtmlHelpers exposing (aBlank, anchor, iconFor)

-- Model
type alias Model = List Video

type alias Video = 
  { title:String
  , link: String
  , description: String
  , date: Time.Posix 
  , thumbnail: String
  }

emptyModel = []

youTube  = "https://www.youtube.com/channel/UC6OzdI6-htXE_97zamJRaaA"

-- Update
type Msg
  = Load Model

update msg model =
  case msg of
    Load loaded  -> ({ model | videos = loaded }, Cmd.none) 

-- View
view videos =
  let
    featured = videos |> List.take 3

    mkFeature v = div [class "video"]
      [ header [] [aBlank [href v.link] [img [src v.thumbnail] []]]
      , div [class "descr"] [text v.description]
      ]

  in section [class "featured-videos section"]
    [ anchor "watch-us"
    , header [] 
        [span [class "title"] [text Branding.title],
         aBlank [href youTube]
          [iconFor "youtube-play", span [] [text "Subscribe"]]]
    , article [] (featured |> List.map mkFeature)
    ]
