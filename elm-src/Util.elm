module Util exposing (..)

import Array

import Data
import Model


maxEverBureaugraphNum : Model.Model -> Int
maxEverBureaugraphNum model =
    (Array.length model.bureaugraphs) - 1


nextBgraphIsAvailable : Model.Model -> Bool
nextBgraphIsAvailable model =
    case model.activeBureaugraphId of
        Data.Finished -> False
        _ ->
            let
                next = nextBureaugraphId model
            in
                List.member next model.availableBureaugraphIds

prevBgraphIsAvailable : Model.Model -> Bool
prevBgraphIsAvailable model =
    case model.activeBureaugraphId of
        Data.Finished -> True
        Data.BureaugraphId n -> n > 0
            
nextBureaugraphId : Model.Model -> Data.BureaugraphId
nextBureaugraphId model =
    case model.activeBureaugraphId of
        Data.Finished -> Data.Finished
        Data.BureaugraphId n ->
            if n == (maxEverBureaugraphNum model)
            then Data.Finished
            else Data.BureaugraphId (n + 1)

previousBureaugraphId : Model.Model -> Data.BureaugraphId
previousBureaugraphId model =
    case model.activeBureaugraphId of
        Data.Finished -> Data.BureaugraphId <| maxEverBureaugraphNum model
        Data.BureaugraphId n -> Data.BureaugraphId <| n - 1

currentBureaugraph : Model.Model -> Maybe Data.Bureaugraph
currentBureaugraph model =
    case model.activeBureaugraphId of
        Data.Finished -> Nothing
        Data.BureaugraphId n -> Array.get n model.bureaugraphs 
