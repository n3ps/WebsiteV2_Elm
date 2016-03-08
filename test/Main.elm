-- Example.elm
import String
import Graphics.Element exposing (Element)

import ElmTest exposing (..)
import Console
import Task

import ModelTest

tests : Test
tests = 
  suite "A Test Suite"
    [ ModelTest.tests
    ]


port runner : Signal (Task.Task x ())
port runner = Console.run (consoleRunner tests)
