module Main exposing (..)

import Dict
import Maybe
import Set

import Svg exposing (svg, g)
import Svg.Attributes exposing (width, height, transform)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseUp, onClick)
import Html.App

import Data exposing(..)
import Message
import MapSvg exposing (mapSvg)
import DistrictSvg exposing (districtSvg)
import Score
import Update

---------------------------------------------------------------------

type alias Model = { bureaugraph: Data.Bureaugraph
                   , activeDistrict: DistrictId
                   , drawing: Bool
                   }

---------------------------------------------------------------------

update : Message.Msg -> Model -> Model
update msg model =
    case msg of
        Message.StopDrawing ->
            { model | drawing = False }
        Message.ActivateCell coord ->
            let newDistrict =
                    Maybe.withDefault 0 (Data.districtOf coord model.bureaugraph)
            in
                { model
                    | activeDistrict = newDistrict
                    , drawing = True
                }
        Message.EnterCell coord ->
            if not model.drawing
            then model
            else
                let
                    newBureaugraph =
                        Update.paint coord model.activeDistrict model.bureaugraph
                in
                    { model | bureaugraph = newBureaugraph }
        Message.Reset ->
            { model | bureaugraph = Update.clearDistricts model.bureaugraph }

---------------------------------------------------------------------

svgAttributes = [ height "300px"
                , width "300px"
                ]


view : Model -> Html Message.Msg
view model =
    let
        mapSvg' = mapSvg model.bureaugraph.demograph
        districtSvgs = model.bureaugraph.districts
                     |> Dict.values
                     |> List.map districtSvg
                     |> List.concat
    in
        div [ style [ ("margin", "1em")
                    , ("padding", "1em")]
            , onMouseUp Message.StopDrawing
            ]
            [ button [onClick Message.Reset] [text "Reset"]
            , Svg.svg svgAttributes
                 [g [transform "translate(3,3)"]
                   (mapSvg' ++ districtSvgs)]
            , Score.scoreView model.bureaugraph
            ]

---------------------------------------------------------------------

exampleDemograph = Dict.fromList [ ((0,0), Red) , ((1,0), Red) , ((2,0), Blue)
                                 , ((0,1), Blue), ((1,1), Blue), ((2,1), Blue)
                                 , ((0,2), Blue), ((1,2), Red), ((2,2), Red)
                                 ]

exampleDistricts = Dict.fromList
                   [ (1, {id = 1, hq = (0,0), assigned = Set.empty})
                   , (2, {id = 2, hq = (1,1), assigned = Set.empty})
                   , (3, {id = 3, hq = (2,2), assigned = Set.empty})
                   ]

exampleBureaugraph = { id = 0
                    , fullSize = 3
                    , demograph = exampleDemograph
                    , districts = exampleDistricts
                    }

exampleModel = { activeDistrict = 0
               , drawing = False
               , bureaugraph = exampleBureaugraph
               }

main =
    Html.App.beginnerProgram
        { model = exampleModel
        , view = view
        , update = update
        }
