module Main exposing (..)

import Dict
import Set
import Maybe

import Svg exposing (svg, g)
import Svg.Attributes exposing (width, height, transform)
import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onMouseUp)
import Html.App

import Data exposing(..)
import Message
import MapSvg exposing (mapSvg)
import DistrictSvg exposing (districtSvg)
import Update

---------------------------------------------------------------------

type alias Model = { map: Data.Map Data.Alignment
                   , districts: Dict.Dict DistrictId District
                   , activeDistrict: DistrictId
                   , drawing: Bool
                   }

---------------------------------------------------------------------

getDistrict
    :  Data.Coord
    -> Dict.Dict Data.DistrictId Data.District
    -> Maybe Data.DistrictId
getDistrict coord districts =
    let
        getId id district maybeId =
            case maybeId of
                Just id -> Just id
                Nothing -> if Set.member coord district
                           then Just id
                           else Nothing
    in
        Dict.foldl getId Nothing districts


clearDistrict : Coord -> Dict.Dict DistrictId District ->
                Dict.Dict DistrictId District
clearDistrict coord districts =
    Dict.map (\id district -> Set.remove coord district) districts


update : Message.Msg -> Model -> Model
update msg model =
    case msg of
        Message.StopDrawing ->
            { model | drawing = False }
        Message.EnterCell coord ->
            if not model.drawing
            then model
            else 
                let
                    newDistricts =
                        Update.addToDistrict
                            coord model.activeDistrict model.districts
                in
                    { model | districts = newDistricts }
        Message.ActivateCell coord ->
            let newDistrict =
                    Maybe.withDefault 0 (getDistrict coord model.districts)
            in 
                { model
                    | activeDistrict = newDistrict
                    , drawing = True
                }

---------------------------------------------------------------------

svgAttributes = [ height "300px"
                , width "300px"
                ]


view : Model -> Html Message.Msg
view model =
    let
        mapSvg' = mapSvg model.map
        districtSvgs = model.districts
                     |> Dict.values
                     |> List.map districtSvg
                     |> List.concat
    in
        div [ style [ ("margin", "1em")
                    , ("padding", "1em")]
            , onMouseUp Message.StopDrawing
            ]
            [Svg.svg svgAttributes
                 [g [transform "translate(3,3)"]
                   (mapSvg' ++ districtSvgs)]
            , text <| toString model
            ]

---------------------------------------------------------------------

exampleMap = Dict.fromList [ ((0,0), Red)
                           , ((0,1), Red)
                           , ((1,0), Red)
                           , ((1,1), Blue)
                           ]


exampleDistricts =
    Dict.fromList
        [ (1, Set.fromList [(0,0)])
        , (2, Set.fromList [(1,1)])
        ]


main =
    Html.App.beginnerProgram
        { model = { map = exampleMap
                  , districts = exampleDistricts
                  , activeDistrict = 1
                  , drawing = False
                  }
        , view = view
        , update = update
        }
