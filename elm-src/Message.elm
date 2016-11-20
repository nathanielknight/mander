module Message exposing (..)

import Data exposing (..)

type Msg = ActivateCell Coord
         | StopDrawing
         | EnterCell Coord
         | Reset
