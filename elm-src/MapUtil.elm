module MapUtil exposing (..)

import Dict
import List

import Data

---------------------------------------------------------------------
-- Global location for the size of cells. Perhaps we can make this
-- responsive, but I'm not sure precisely how. There's a bunch of
-- rounding, so make the dimensions/inner dimensions/padding appropriate
-- sizes in order to avoid weird rounding errors.
cellDim = 100  -- cell side-length in pixels
cellInnerDim = round <| 0.8 * cellDim
cellPadding = (cellDim - cellInnerDim)
              |> toFloat
              |> (*) 0.5
              |> round

-- Given an integer, returns the string representation that
-- elm-lang/svg expects for a pixel value.
toPx : Int -> String
toPx x = (toString x) ++ "px"

-- Given a Data.Alignment, returns the string-representation of color
-- as elm-lang/svg expects it.
attrColor alignment =
    case alignment of
        Data.Red -> "red"
        Data.Blue -> "blue"
