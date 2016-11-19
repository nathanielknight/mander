module Update exposing (..)

import Dict
import Maybe
import Set

import Data

---------------------------------------------------------------------

addToDistrict
    :  Data.Coord
    -> Data.DistrictId
    -> Dict.Dict Data.DistrictId Data.District
    -> Dict.Dict Data.DistrictId Data.District
addToDistrict coord dId districts =
    (Dict.map (\id district -> if id == dId
                               then Set.insert coord district
                               else Set.remove coord district)
         districts)
