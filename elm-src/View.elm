module View exposing (view)

import Array
import Dict

import Html exposing (div, button, text)
import Html.Attributes exposing (style, class, id)
import Html.Events exposing (onMouseUp, onClick)
import Svg exposing (svg, g)
import Svg.Attributes exposing (width, height, transform)

import Data
import DistrictSvg
import MapSvg
import Message
import Model

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
            [text id]

scoreView : Maybe Data.Bureaugraph -> Html.Html Message.Msg
scoreView bgraph =
    case bgraph of
        Nothing -> div [] [text "Error: No active bureaugraph"]
        Just bgraph -> 
            let
                alignments = Data.districtAlignments bgraph
                districtIds = List.sort <| Dict.keys bgraph.districts
                districtAlignments =
                    List.map
                        (\id -> (toString id, Dict.get id alignments))
                        districtIds
            in
                div
                    [id "district-alignments"]
                    (List.map districtScore districtAlignments)

---------------------------------------------------------------------

bureaugraphSvg : Maybe Data.Bureaugraph -> Html.Html Message.Msg
bureaugraphSvg mbgraph =
    case mbgraph of
        Nothing -> div [] [text "Error; no active bureagraph"]
        Just bgraph ->
            let
                demographSvg = MapSvg.mapSvg bgraph.demograph
                districtSvgs = bgraph.districts
                             |> Dict.values
                             |> List.map DistrictSvg.districtSvg
                             |> List.concat
            in
                div []
                    [Svg.svg
                         [ S.viewBox "-3 -3 800 800"
                         , S.preserveAspectRatio "xMidYMid meet"
                         ]
                         (demographSvg ++ districtSvgs)
                    ]

---------------------------------------------------------------------

view : Model.Model -> Html.Html Message.Msg
view model =
    div [ style [ ("margin", "1em")
                , ("padding", "1em")]
        , onMouseUp Message.StopDrawing
        ]
        [ button [onClick Message.ResetAll] [text "Reset"]
        , bureaugraphSvg (Array.get model.activeBureaugraphId model.bureaugraphs)
        , button
              [onClick (Message.SetActiveBureaugraph (model.activeBureaugraphId - 1))]
              [text "Prev"]
        , button
              [onClick (Message.SetActiveBureaugraph (model.activeBureaugraphId + 1))]
              [text "Next"]
        , scoreView (Array.get model.activeBureaugraphId model.bureaugraphs)
        ]
