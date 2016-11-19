module Message exposing (..)

import Data exposing (..)

type Msg = EnterCell Coord
         | ActivateCell Coord
         | StopDrawing
