module Update exposing (..)

import Dict
import Maybe
import Set

import Data

---------------------------------------------------------------------



{-| Given a coordinate and a district ID to assign it to, assoc it to
the district with that ID or dissoc it from any other district. 
-}
assignCoord
    :  Data.Coord
    -> Data.DistrictId
    -> Data.District
    -> Data.District
assignCoord coord distId district
    = if district.id == distId
      then { district | assigned = Set.insert coord district.assigned }
      else { district | assigned = Set.remove coord district.assigned }

---------------------------------------------------------------------
-- Responses to Events

{-| Assign a coordinate to a district unless it's an HQ (in that case,
do nothing, obviously).
-}
paint : Data.Coord -> Data.DistrictId -> Data.Bureaugraph -> Data.Bureaugraph
paint coord distId bgraph
    =
      let
          canGrow : Data.DistrictId -> Bool
          canGrow districtId
              =
                case Dict.get districtId bgraph.districts of
                    Nothing -> True
                    Just district -> (Data.districtSize district) < bgraph.fullSize

          newDistricts = Dict.map
                         (\_ district -> assignCoord coord distId district)
                         bgraph.districts
     in
         if (  (Data.isHQ coord bgraph)
            || not (canGrow distId)
            || not (Data.validDistricts newDistricts)
            )
         then bgraph
         else { bgraph | districts = newDistricts }


clearDistricts : Data.Bureaugraph -> Data.Bureaugraph
clearDistricts bgraph
    =
      let
          newDistricts = bgraph.districts
                       |> Dict.map (\_ district -> {district | assigned = Set.empty})
      in
          {bgraph | districts = newDistricts}
