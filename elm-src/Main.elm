module Main exposing (..)

import Array
import Dict
import Maybe
import Set

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseUp, onClick)
import Html.App

import Data exposing(..)
import Message
import Update
import View

---------------------------------------------------------------------

exampleBureaugraph0 = { id = 0
                      , fullSize = 3
                      , demograph =
                          (Dict.fromList
                               [ ((0,0), Red) , ((1,0), Red) , ((2,0), Blue)
                               , ((0,1), Blue), ((1,1), Blue), ((2,1), Blue)
                               , ((0,2), Blue), ((1,2), Red), ((2,2), Red)
                               ])
                      , districts =
                          (Dict.fromList
                               [ (1, {id = 1, hq = (0,0), assigned = Set.empty})
                               , (2, {id = 2, hq = (1,1), assigned = Set.empty})
                               , (3, {id = 3, hq = (2,2), assigned = Set.empty})
                               ])
                      }
exampleBureaugraph1 = { id = 0
                      , fullSize = 5
                      , demograph =
                          (Dict.fromList
                               [ ((1,0), Red), ((2,0), Red), ((3,0), Blue), ((4,0), Red)
                               , ((1,1), Red), ((2,1), Blue), ((3,1), Blue), ((4,1), Blue), ((5,1), Blue)
                               , ((0,2), Blue), ((1,2), Red), ((2,2), Red), ((3,2), Blue), ((4,2), Blue)
                               , ((1,3), Blue)])
                      , districts =
                          (Dict.fromList
                               [ (1, {id = 1, hq = (3,0), assigned = Set.empty})
                               , (2, {id = 2, hq = (4,1), assigned = Set.empty})
                               , (3, {id = 3, hq = (2,2), assigned = Set.empty})
                               ])
                      }

exampleModel = { activeBureaugraphId = 0
               , maxAvailableBureaugraphId = 1
               , bureaugraphs = Array.fromList [exampleBureaugraph0, exampleBureaugraph1]
               , activeDistrictId = 0
               , drawing = False
               }

main =
    Html.App.beginnerProgram
        { model = exampleModel
        , view = View.view
        , update = Update.update
        }
