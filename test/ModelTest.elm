module ModelTest where

import ElmTest exposing (..)

import Date exposing (Date)
import Json.Decode as Json exposing ((:=))
import Json.Decode.Extra as JsonX
import Result 
import Date.Format

import Models as M


tests = suite "Models Tests"
    [ dateDecodeTests, eventDecodeTests ]


dateDecodeTests =
  let
    sameFormat = Date.Format.format "%d %b %Y %H:%M"
    actual =
      "\"2016-03-22T17:30:00.0000000+00:00\""
      |> Json.decodeString JsonX.date
      |> Result.withDefault (Date.fromTime 100)
      |> sameFormat
    expected =
      "2016-03-22T17:30" 
      |> Date.fromString
      |> Result.withDefault (Date.fromTime 0)
      |> sameFormat
  in
    test "The date decoder parses JSON date" <| assertEqual expected actual


eventDecodeTests =
  let
    jsonStr = """
      {"events": [
        { "title": "Property-based testing",
          "date": "2016-03-22T17:30:00.0000000+00:00",
          "id": "18029560902",
          "description": "F# and FsCheck",
          "enddate": "2016-03-22T20:30:00.0000000+00:00",
          "status": "live",
          "logo": "http://somelogo.com",
          "link": "http://eventbrite.com/event" ,
          "venue": { "name": "Millenium Library", "address": "251 Donald", "id": "13677727" } 
        }]
      }
      """
    actual = jsonStr |> Json.decodeString M.eventDecoder |> Result.withDefault []
    expected = [{
      title="Property-based testing",
      date=Date.fromTime 0,
      description="F# and FsCheck",
      status=M.Live,
      logo="http://somelogo.com",
      link="http://eventbrite.com/event",
      venue={name="Millenium Library", address="251 Donald"}
    }]
    assertion = assertEqual expected actual
  in
    test "The event decoder returns an event" assertion
