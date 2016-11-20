module MapSvg exposing (mapSvg)

import Dict
import List

import Html exposing (div, Html)
import Html.App

import Svg exposing(..)
import Svg.Attributes exposing(..)
import Svg.Events exposing (onMouseOver, onMouseDown)

import Data
import MapUtil exposing(..)
import DebugSvg
import Message exposing (..)

---------------------------------------------------------------------

attrColor alignment =
    case alignment of
        Data.Red -> "red"
        Data.Blue -> "blue"


cell : Data.Coord -> Data.Alignment -> Svg Msg
cell (xx,yy) alignment =
    let
        xPx = cellDim * xx + cellPadding
        yPx = cellDim * yy + cellPadding
    in
        rect [ x <| toPx xPx
             , y <| toPx yPx
             , width <| toPx cellInnerDim
             , height <| toPx cellInnerDim
             , fill <| attrColor alignment
             , onMouseOver (EnterCell (xx,yy))
             , onMouseDown (ActivateCell (xx,yy))
             ]
            []


mapSvg : Data.Demograph -> List (Svg Msg)
mapSvg data =
    (data
    |> Dict.map cell
    |> Dict.values
    )

---------------------------------------------------------------------
-- Debugging

{-
exampleMap = Dict.fromList [ ((0,0), Data.Red)
                          , ((0,1), Data.Blue)
                          , ((1,0), Data.Red)
                          , ((1,1), Data.Blue)
                          ]

main = DebugSvg.svgShower mapSvg exampleMap
---}
