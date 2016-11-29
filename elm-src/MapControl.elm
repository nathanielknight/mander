module MapControl exposing (controlRects)

import Dict

import Svg
import Svg.Attributes exposing(x, y, width, height, opacity)
import Svg.Events exposing (onMouseOver, onMouseDown)

import Data
import MapUtil exposing (cellDim, cellPadding, toPx)
import Message

---------------------------------------------------------------------

controlCell : Data.Coord -> Svg.Svg Message.Msg
controlCell (xx,yy) =
    let
        xPx = cellDim * xx
        yPx = cellDim * yy
    in
        Svg.rect [ x <| toPx xPx
                 , y <| toPx yPx
                 , width <| toPx cellDim
                 , height <| toPx cellDim
                 , opacity "0"
                 , onMouseOver (Message.EnterCell (xx,yy))
                 , onMouseDown (Message.TapCell (xx,yy))
                 ]
                []

---------------------------------------------------------------------

controlRects : Data.Demograph -> List (Svg.Svg Message.Msg)
controlRects data
    = data
    |> Dict.keys
    |> List.map controlCell
