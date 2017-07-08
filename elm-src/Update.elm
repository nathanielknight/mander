module Update exposing (..)

import Array
import Dict
import Maybe
import Set

import Data
import Message
import Model
import Progress

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

{-| Given a function `fmodel : (Model -> Bureaugraph -> Bureaugraph)
and the current model, update the currently active Bureaugraph by
applying the function to it.
-}
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

{-| If it would result in a legal game-state, paint the given
coordinate in the given Bureaugraph with the given district id.
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

          isCell = case Dict.get coord bgraph.demograph of
                       Nothing -> False
                       Just _ -> True

          newDistricts = Dict.map
                         (\_ district -> assignCoord coord distId district)
                         bgraph.districts
     in
         if (  (Data.isHQ coord bgraph)
            || not (canGrow distId)
            || not (Data.validDistricts newDistricts)
            || not isCell
            )
         then bgraph
         else { bgraph | districts = newDistricts }


clearDistrict : Data.Bureaugraph -> Data.DistrictId -> Data.Bureaugraph
clearDistrict bgraph districtId =
    let
        newDistricts = (Dict.update
                            districtId
                            (\maybeDistrict ->
                                 case maybeDistrict of
                                     Nothing -> Nothing
                                     Just district -> Just { district |
                                                                 assigned = Set.empty })
                            bgraph.districts
                       )
    in
        { bgraph | districts = newDistricts }


clearDistricts : Data.Bureaugraph -> Data.Bureaugraph
clearDistricts bgraph =
    let
        newDistricts = bgraph.districts
                     |> Dict.map (\_ district -> {district | assigned = Set.empty})
    in
        { bgraph | districts = newDistricts}


---------------------------------------------------------------------
{-| Event Handlers. These get invoked in response to an event,
possibly taking event parameters as arguments.
-}

setActiveBureaugraph : Model.Model -> Data.BureaugraphId -> Model.Model
setActiveBureaugraph model bgraphId =
    if Set.member bgraphId model.availableBureaugraphIds
    then
        let
            maxEverBureaugraphId = (Array.length model.bureaugraphs) - 1
            newBureaugraphId = clamp 0 maxEverBureaugraphId bgraphId
        in
            { model | activeBureaugraphId = newBureaugraphId }
    else model

tapCell : Model.Model -> Data.Coord -> Model.Model
tapCell model coord =
    let
        newDistrictId =
            (Maybe.withDefault
                 0
                 ( model.bureaugraphs
                 |> Array.get model.activeBureaugraphId
                 |> Maybe.map (\bgraph -> Maybe.withDefault 0 (Data.districtOf coord bgraph))))
    in
        { model | activeDistrictId = newDistrictId, drawing = True }

enterCell : Model.Model -> Data.Coord -> Model.Model
enterCell model coord =
    if not model.drawing
    then model
    else (updateActiveBureaugraph
              (\model bgraph -> paint coord model.activeDistrictId bgraph)
              model)


resetAll : Model.Model -> Model.Model
resetAll model =
    updateActiveBureaugraph (\model bgraph -> clearDistricts bgraph) model


---------------------------------------------------------------------

updateEvt : Message.Msg -> Model.Model -> Model.Model
updateEvt msg model =
    case msg of
        Message.SetActiveBureaugraph bgraphId -> setActiveBureaugraph model bgraphId
        Message.TapCell coord -> tapCell model coord
        Message.EnterCell coord -> enterCell model coord
        Message.StopDrawing -> { model | drawing = False }
        Message.ResetAll -> resetAll model

updateAuto : Model.Model -> Model.Model
updateAuto model =
    if Progress.solvedCurrent model
    then
        let
            newAvailableBgraphIds = Set.insert
                                    (model.activeBureaugraphId + 1)
                                    model.availableBureaugraphIds
        in
            { model | availableBureaugraphIds = newAvailableBgraphIds }
    else model

update : Message.Msg -> Model.Model -> Model.Model
update msg model =
    updateAuto (updateEvt msg model)
