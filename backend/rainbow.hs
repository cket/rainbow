--haskell
--hella broken.. even getting the current hour sucks
import Data.Time.Clock
import Data.Time.LocalTime

getHourDec :: TimeOfDay
getHourDec  = do let time = getCurrentTime
				 let TimeOfDay hours minutes seconds = timeToTimeOfDay (utctDayTime time)
				 return TimeOfDay time

				 --time <- getCurrentTime
				 --timeToTimeOfDay (utctDayTime time)

