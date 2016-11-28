module View exposing (view)

import Array
import Dict

import Html exposing (div, button, text)
import Html.Attributes exposing (style, class, id)
import Html.Events exposing (onMouseUp, onClick)
import Svg
import Svg.Attributes as S

import Data
import DistrictSvg
import MapSvg
import Message
import Model
import Progress

---------------------------------------------------------------------

districtAlignControl : (Data.DistrictId,  Maybe Data.Alignment) -> Html.Html Message.Msg
districtAlignControl (id, alignment)=
    let
        colorClass = case alignment of
                         Just Data.Red -> "aligned-red"
                         Just Data.Blue -> "aligned-blue"
                         Nothing -> "aligned-none"
    in
        Html.li [ class "district-score"
                , class colorClass
                ]
            [ text (toString id)
            , button [onClick (Message.ResetDistrict id)] [text "X"]
            ]

scoreView : Maybe Data.Bureaugraph -> Html.Html Message.Msg
scoreView bgraph =
    case bgraph of
        Nothing -> div [] [text "Error: No active bureaugraph?"]
        Just bgraph ->
            let
                alignments = Data.districtAlignments bgraph
                districtIds = List.sort <| Dict.keys bgraph.districts
                districtAlignments =
                    List.map
                        (\id -> (id, Dict.get id alignments))
                        districtIds
            in
                Html.ul
                    [id "district-alignments"]
                    (List.map districtAlignControl districtAlignments)

toggleButton : Message.Msg -> String -> Bool -> Html.Html Message.Msg
toggleButton msg label available =
    (button
         [ class (if available
                  then ""
                  else "unavailable")
         , onClick msg
         ]
         [text label])


controlsView : Model.Model -> Html.Html Message.Msg
controlsView model =
    let
        activeBureaugraph = Array.get model.activeBureaugraphId model.bureaugraphs
        canLegislate = Progress.ready model
        nextAvailable = model.activeBureaugraphId < model.maxAvailableBureaugraphId
        prevAvailable = model.activeBureaugraphId > 0
    in
        (div
         [id "controls"]
         [ (toggleButton Message.Legislate "Legislate!" canLegislate)
         , scoreView activeBureaugraph
         , (toggleButton
                (Message.SetActiveBureaugraph (model.activeBureaugraphId - 1))
                "Prev"
                prevAvailable)
         , (toggleButton
                (Message.SetActiveBureaugraph (model.activeBureaugraphId + 1))
                "Next"
                nextAvailable)
         ]
        )

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
                div [ id "map" ]
                    [ button [onClick Message.ResetAll] [text "Reset"]
                    , Svg.svg
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
        , id "appcontainer"
        ]
        [ bureaugraphSvg (Array.get model.activeBureaugraphId model.bureaugraphs)
        , controlsView model
        ]
