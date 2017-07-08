module Model exposing (Model)

import Array
import Set

import Data

---------------------------------------------------------------------

type alias  Model = { activeBureaugraphId: Data.BureaugraphId
                    , availableBureaugraphIds: Set.Set Data.BureaugraphId
                    , bureaugraphs: Array.Array Data.Bureaugraph
                    , activeDistrictId: Data.DistrictId
                    , drawing: Bool
                    }
