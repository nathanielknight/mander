module Main exposing (..)

import Array
import Dict

import Html

import Data exposing(..)
import Game
import Update
import View

---------------------------------------------------------------------

initModel = { activeBureaugraphId = Data.BureaugraphId 0
            , availableBureaugraphIds = [Data.BureaugraphId 0]
            , bureaugraphs = Game.bureaugraphs
            , activeDistrictId = 0
            , drawing = False
            }

main =
    Html.beginnerProgram
        { model = initModel
        , view = View.view
        , update = Update.update
        }
