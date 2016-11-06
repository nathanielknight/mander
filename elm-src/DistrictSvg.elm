module DistrictSvg exposing (districtSvg)

import Set

import Svg exposing (..)
import Svg.Attributes exposing (..)

import Data exposing (..)
import MapUtil exposing (..)
import DebugSvg

---------------------------------------------------------------------

type Side = North | South | East | West

containsNeighbor : District -> Coord -> Side -> Bool
containsNeighbor d c s =
    let
        (x,y) = c
        neighborCoord = case s of
                            North -> (x,y-1)
                            South -> (x, y+1)
                            East -> (x+1,y)
                            West -> (x-1,y)
    in
        Set.member neighborCoord d

sidesInDistrictFor : District -> Coord -> List (Coord, Side)
sidesInDistrictFor d c
    = [North, South, East, West]
    |> List.filter (\s -> not (containsNeighbor d c s))
    |> List.map (\s -> (c, s))

districtBorders : District -> List (Coord, Side)
districtBorders d = (Set.toList d)
                  |> List.map (\c -> sidesInDistrictFor d c)
                  |> List.concat

---------------------------------------------------------------------

type alias Vec = { x1 : Int
                 , x2 : Int
                 , y1 : Int
                 , y2 : Int
                 }

borderVec : Coord -> Side -> Vec
borderVec (x,y) s =
    case s of
        North -> { x1 = x * cellDim
                 , x2 = (x + 1) * cellDim
                 , y1 = y * cellDim
                 , y2 = y * cellDim
                 }
        South -> { x1 = x * cellDim
                 , x2 = (x + 1) * cellDim
                 , y1 = (y + 1) * cellDim
                 , y2 = (y + 1) * cellDim
                 }
        East -> { x1 = (x + 1) * cellDim
                , x2 = (x + 1) * cellDim
                , y1 = y * cellDim
                , y2 = (y + 1) * cellDim
                }
        West -> { x1 = x * cellDim
                , x2 = x * cellDim
                , y1 = y * cellDim
                , y2 = (y + 1) * cellDim
                }

borderSvg : Vec -> Svg msg
borderSvg v =
    line [ strokeWidth <| toPx 2
         , stroke "black"
         , x1 <| toPx v.x1
         , x2 <| toPx v.x2
         , y1 <| toPx v.y1
         , y2 <| toPx v.y2
         ] 
        []
            
border : (Coord, Side) -> Svg msg
border (c,s) = borderVec c s
           |> borderSvg

---------------------------------------------------------------------

districtSvg : District -> List (Svg msg)
districtSvg coords = coords
                   |> districtBorders
                   |> List.map border

---------------------------------------------------------------------
-- Debugging

{-
example = Set.fromList [ (0,0)
                       , (1,0)
                       , (0,1)
                       , (0,2)
                       , (1,2)
                       ]

main = DebugSvg.svgShower districtSvg example
--}
