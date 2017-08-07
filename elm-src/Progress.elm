module Progress exposing (solvedCurrent, nextBureaugraphId)

import Array
import Dict
import Maybe

import Data
import Model

---------------------------------------------------------------------

{-| The next BureaugraphId that would be available to the
player. Doesn't tell you whether they should be allowed to have it
though.
-}
nextBureaugraphId : Model.Model -> Data.BureaugraphId
nextBureaugraphId model =
    case model.activeBureaugraphId of
        Data.Finished -> Data.Finished
        Data.BureaugraphId n ->
            let
                maxEverBureaugraphId = (Array.length model.bureaugraphs) - 1
            in
                if n >= maxEverBureaugraphId
                then Data.Finished
                else Data.BureaugraphId (n + 1)

---------------------------------------------------------------------

notNothing : Maybe a -> Bool
notNothing m =
    case m of
        Nothing -> False
        Just _ -> True

{-| Check whether all of the districts have been drawn (eveyone has
been allocated a vote).
-}
allDistrictsDrawn : Data.Bureaugraph -> Bool
allDistrictsDrawn bgraph =
    let
        alignments = Data.districtAlignments bgraph
    in
        (Dict.keys bgraph.districts)
            |> List.map (\id -> Dict.get id alignments)
            |> List.all notNothing


{-| Check whether a majority of distrits are aligned Red.
-}
redAligned : Data.Bureaugraph -> Bool
redAligned bgraph =
    let
        alignments = Data.districtAlignments bgraph
        redAligned = (Dict.values alignments)
                   |> List.filter (\a -> a == Data.Red)
                   |> List.length
        blueAligned = (Dict.values alignments)
                    |> List.filter (\a -> a == Data.Blue)
                    |> List.length
    in
        redAligned > blueAligned

{-| Checks whether the player has solved the currently active
Bureaugraph.
-}
solvedCurrent : Model.Model -> Bool
solvedCurrent model =
    let
        -- conditions
        mBureaugraph =
            case model.activeBureaugraphId of
                Data.BureaugraphId n -> Array.get n model.bureaugraphs
                Data.Finished -> Nothing
        checkFunction f = (Maybe.withDefault
                               False
                               (Maybe.map f mBureaugraph))
    in
        (checkFunction redAligned) && (checkFunction allDistrictsDrawn)
