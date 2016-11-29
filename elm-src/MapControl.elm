module MapControl exposing (controlRects)

import Json.Decode
import Dict

import Html
import Html.Events exposing(onWithOptions)
import Svg
import Svg.Attributes exposing(x, y, width, height, opacity)

import Data
import MapUtil exposing (cellDim, cellPadding, toPx)
import Message

---------------------------------------------------------------------

onClick : Data.Coord -> Html.Attribute Message.Msg
onClick coord
    = onWithOptions
        "mousedown"
        {stopPropagation = True, preventDefault = True}
        (Json.Decode.succeed (Message.TapCell coord))

onEnter : Data.Coord -> Html.Attribute Message.Msg
onEnter coord
    = onWithOptions
        "mouseenter"
        {stopPropagation = True, preventDefault = True}
        (Json.Decode.succeed (Message.EnterCell coord))

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
                 , onClick (xx, yy)
                 , onEnter (xx, yy)
                 ]
                []

---------------------------------------------------------------------

controlRects : Data.Demograph -> List (Svg.Svg Message.Msg)
controlRects data
    = data
    |> Dict.keys
    |> List.map controlCell
