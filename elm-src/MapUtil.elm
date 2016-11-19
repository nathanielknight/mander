module MapUtil exposing (..)

import Dict
import List

---------------------------------------------------------------------
-- Global location for the size of cells. Perhaps we can make this
-- responsive, but I'm not sure precisely how. There's a bunch of
-- rounding, so make the dimensions/inner dimensions/padding appropriate
-- sizes in order to avoid weird rounding errors.
cellDim = 80  -- cell side-length in pixels
cellInnerDim = round <| 0.9 * cellDim
cellPadding = (cellDim - cellInnerDim)
              |> toFloat
              |> (*) 0.5
              |> round

toPx : Int -> String
toPx x = (toString x) ++ "px"