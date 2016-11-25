module Update exposing (..)

import Array
import Dict
import Maybe
import Set

import Data
import Message
import Model

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

updateActiveBureaugraph
    : (Model.Model -> Data.Bureaugraph -> Data.Bureaugraph)
    -> Model.Model
    -> Model.Model
updateActiveBureaugraph fmodel model =
    let
        maybeActiveBureaugraph = Array.get model.activeBureaugraphId model.bureaugraphs
        maybeNewBureaugraph = Maybe.map (\bgraph -> (fmodel model bgraph)) maybeActiveBureaugraph
        maybeNewBureaugraphs =
            (Maybe.map
                 (\bgraph -> Array.set model.activeBureaugraphId bgraph model.bureaugraphs)
                 maybeNewBureaugraph)
    in
        case maybeNewBureaugraphs of
            Nothing -> model
            Just bgraphs -> { model | bureaugraphs = bgraphs }

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
          { bgraph | districts = newDistricts}

---------------------------------------------------------------------

update : Message.Msg -> Model.Model -> Model.Model
update msg model =
    case msg of
        Message.SetActiveBureaugraph bureaugraphId ->
            let
                maxEverBureaugraphId = (Array.length model.bureaugraphs) - 1
                maxBureaugraphId = min model.maxAvailableBureaugraphId maxEverBureaugraphId
                newBureaugraphId = clamp 0 maxBureaugraphId bureaugraphId
            in
                { model | activeBureaugraphId = newBureaugraphId }
        Message.TapCell coord ->
            let
                newDistrictId =
                    (Maybe.withDefault
                         0
                         ( model.bureaugraphs
                         |> Array.get model.activeBureaugraphId
                         |> Maybe.map (\bgraph -> Maybe.withDefault 0 (Data.districtOf coord bgraph))))
            in
                { model | activeDistrictId = newDistrictId, drawing = True }
        Message.EnterCell coord ->
            if not model.drawing
            then model
            else updateActiveBureaugraph (\model bgraph -> paint coord model.activeDistrictId bgraph) model
        Message.StopDrawing ->
            { model | drawing = False }
        Message.ResetAll ->
            updateActiveBureaugraph (\model bgraph -> clearDistricts bgraph) model
