module ShadingSvg exposing(shadingSvgs)

import Dict
import Maybe
import Set

import Svg
import Svg.Attributes exposing (x, y, width, height, fill, fillOpacity)

import Data
import MapUtil exposing(..)
import Message

---------------------------------------------------------------------
-- Cells to shade a district if it's aligned Red or Blue

districtShadingSvg
    : Set.Set (Data.Coord)
    -> Maybe Data.Alignment
    -> Maybe (List (Svg.Svg Message.Msg))
districtShadingSvg coords algn
    =
      let
          shadingSvg : Data.Coord -> Data.Alignment -> Svg.Svg Message.Msg
          shadingSvg coord algn =
              let
                  (xx, yy) = coord
                  xPx = toPx <| cellDim * xx
                  yPx = toPx <| cellDim * yy
              in
                  Svg.rect [ x xPx
                           , y yPx
                           , width <| toPx cellDim
                           , height <| toPx cellDim
                           , fill <| attrColor algn
                           , fillOpacity "0.35"
                           ] []
      in
          Maybe.map
               (\a -> List.map (\c -> shadingSvg c a)  (Set.toList coords))
               algn

---------------------------------------------------------------------


-- A list of SVGs that shades a Bureaugraph's aligned districts.
shadingSvgs : Data.Bureaugraph -> List (Svg.Svg Message.Msg)
shadingSvgs bgraph =
    let
        alignments  = Data.districtAlignments bgraph
        extents = Dict.map (\id dist -> Data.districtExtent dist)  bgraph.districts
        shadings = extents
                 |> Dict.toList
                 |> List.map (\(id, ext) -> districtShadingSvg ext (Dict.get id alignments))
                 |> List.map (\m -> Maybe.withDefault [] m)
    in
        List.concat shadings
        
