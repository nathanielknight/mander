module Score exposing (scoreView)

import Dict

import Html
import Html.Attributes exposing (..)

import Data
import Message

---------------------------------------------------------------------

districtScore : (String,  Maybe Data.Alignment) -> Html.Html Message.Msg
districtScore (id, alignment)=
    let
        colorClass = case alignment of
                         Just Data.Red -> "aligned-red"
                         Just Data.Blue -> "aligned-blue"
                         Nothing -> "aligned-none"
    in
        Html.li [ class "district-score"
                , class colorClass
                ]
            [Html.text id]

scoreView : Data.Bureaugraph -> Html.Html Message.Msg
scoreView bgraph =
    let
        alignments = Data.districtAlignments bgraph
        districtIds = List.sort <| Dict.keys bgraph.districts
        districtAlignments =
            List.map
                (\id -> (toString id, Dict.get id alignments))
                districtIds
    in
        Html.div
            [id "district-alignments"]
            (List.map districtScore districtAlignments)
