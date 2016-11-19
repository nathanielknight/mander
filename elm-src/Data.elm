module Data exposing (..)

import Dict
import Set

type alias Coord = (Int, Int)
type alias DistrictId = Int
type Alignment = Red | Blue

type alias Map a = Dict.Dict Coord a
type alias District = Set.Set Coord
