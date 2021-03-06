module DebugSvg exposing (svgShower)

import Html
import Svg exposing (svg, Svg)
import Svg.Attributes exposing (height, width)

---------------------------------------------------------------------

mapConfig = [ height "800px"
            , width "800px"
            ]

-- Display the output of an SVG rendering function on the model it
-- takes as input.
svgShower : (a -> List (Svg msg)) -> a -> Program Never a msg
svgShower svgView model =
    Html.beginnerProgram
        { view = (\m -> svg mapConfig (svgView m))
        , model = model
        , update = (\msg model -> model)
        }      
