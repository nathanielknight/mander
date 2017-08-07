module View exposing (view)

import Array
import Dict
import Set

import Html exposing (div, button, text, p)
import Html.Attributes exposing (style, class, id)
import Html.Events exposing (onMouseUp, onClick)
import Svg
import Svg.Attributes exposing(viewBox, preserveAspectRatio)

import Data
import DistrictSvg
import MapSvg
import MapControl
import Message
import Model
import Progress
import ShadingSvg
import Util

---------------------------------------------------------------------
-- Utils

toggleButton : Message.Msg -> String -> Bool -> Html.Html Message.Msg
toggleButton msg label available =
    (button
         [ class (if available
                  then ""
                  else "unavailable")
         , onClick msg
         ]
         [text label])

---------------------------------------------------------------------
-- Controls

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
            [ text (toString id) ]

scoreView : Maybe Data.Bureaugraph -> Html.Html Message.Msg
scoreView bgraph =
    case bgraph of
        Nothing -> div [] []
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


stage : Data.BureaugraphId -> Int -> Html.Html Message.Msg
stage current total =
    let
        content =
            case current of
                Data.Finished -> ""
                Data.BureaugraphId n ->
                    let
                        currentS = toString n
                        totalS = toString total
                    in
                        "Lvl: " ++ currentS ++ " / " ++ totalS
    in
        p [] [text content]


controlsView : Model.Model -> Html.Html Message.Msg
controlsView model =
    let
         activeBureaugraph = Util.currentBureaugraph model
    in
        (div
         [id "controls"]
         [ (stage
                model.activeBureaugraphId
                (Util.maxEverBureaugraphNum model))
         , (toggleButton
                (Message.SetActiveBureaugraph
                     (Util.previousBureaugraphId model))
                "Prev"
                (Util.prevBgraphIsAvailable model))
         , (toggleButton
                (Message.SetActiveBureaugraph
                     (Util.nextBureaugraphId model))
                "Next"
                (Util.nextBgraphIsAvailable model))
         , scoreView activeBureaugraph
         ]
        )

---------------------------------------------------------------------
-- Map

bureaugraphSvg : Maybe Data.Bureaugraph -> Html.Html Message.Msg
bureaugraphSvg mbgraph =
    case mbgraph of
        Nothing -> div [] [text "The End"]
        Just bgraph ->
            let
                demographSvg = MapSvg.mapSvg bgraph.demograph
                districtSvgs = bgraph.districts
                             |> Dict.values
                             |> List.map DistrictSvg.districtSvg
                             |> List.concat
                shadingSvgs = ShadingSvg.shadingSvgs bgraph
            in
                div [ id "map" ]
                    [ button [onClick Message.ResetAll] [text "Reset"]
                    , p [] [text bgraph.name]
                    , Svg.svg
                        [ viewBox "-3 -3 804 804"
                        , preserveAspectRatio "xMidYMid meet"
                        ]
                        (demographSvg ++ shadingSvgs ++ districtSvgs ++ MapControl.controlRects)
                    ]

---------------------------------------------------------------------
-- Synthesis

view : Model.Model -> Html.Html Message.Msg
view model =
    div [ style [ ("margin", "1em")
                , ("padding", "1em")]
        , onMouseUp Message.StopDrawing
        , id "appcontainer"
        ]
        [ bureaugraphSvg (Util.currentBureaugraph model)
        , controlsView model
        ]
