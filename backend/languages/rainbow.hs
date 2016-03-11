import Data.Dates
import Data.Time.Clock.POSIX
import Data.Time.Clock
import System.Environment

data DTime = DTime {hour :: Double, minute :: Double, second :: Double}

data Date = Date {year :: Double, month :: Double, day :: Double}

get_hour_dec :: DTime -> Double
get_hour_dec  (DTime hour minute second) = (hour + minute/60.0 + second/360)

get_julian_date :: Date -> DTime -> Double
get_julian_date (Date year month day) (DTime hour minute second) = (1461 * (year + 4800 + (month - 14)/12))/4 + (367 * (month - 2 - 12 * ((month - 14)/12)))/12 
                                           - (3 * ((year + 4900 + (month - 14)/12)/100))/4 + day - 32075 - 0.5 + hour/24.0

jd_to_ecliptic :: Date -> DTime -> (Double, Double)
jd_to_ecliptic date time = (mean_longitute + (0.03341607 * (sin(mean_anomaly)))
                        + (0.00034894 * (sin (2 * mean_anomaly))) - 0.0001134 - (0.0000203 * (sin omega)),
                         0.4090928 - 6.2140e-9 * (n(get_julian_date date time)) + 0.0000396 * cos omega) 
                        where mean_anomaly = 6.2400600 + 0.0172019699 * (n (get_julian_date date time))
                              omega = 2.1429 - 0.0010394594 * (n (get_julian_date date time))
                              mean_longitute = 4.8950630 + 0.017202791698 * (n (get_julian_date date time))

ecliptic_to_celestial :: (Double, Double) -> (Double, Double)
ecliptic_to_celestial (l, ep) = (correct right_ascension, (asin((sin ep) * (sin l)))) --need to adjust right ascension
                              where right_ascension = (atan2 ((cos ep) * (sin l)) (cos l))
                                    correct x
                                        | x<0 = x + 2 * pi
                                        | otherwise = x

get_solar_vector :: Date -> DTime -> Double -> Double -> (Double, Double)
get_solar_vector date time latitude longitude = (correct_zenith_distance zen1, correct_azimuth azi1)
        where zen1 = zenith1 (toRadians latitude) (hour_angle date time longitude) (declination date time)
              azi1 = azimuth (hour_angle date time longitude) (declination date time) (toRadians latitude)

n :: Double -> Double
n jd = jd - 2451545.0

hour_angle :: Date -> DTime -> Double -> Double
hour_angle date time longitude = (gmst * 15 + longitude) * radians - right_ascension
             where radians = pi/180
                   gmst = (6.6974243242 + 0.0657098283 * (n (get_julian_date date time)) + get_hour_dec time)
                   right_ascension = fst (ecliptic_to_celestial(jd_to_ecliptic date time))

declination :: Date -> DTime -> Double
declination date time = snd (ecliptic_to_celestial(jd_to_ecliptic date time))

zenith1 :: Double -> Double -> Double -> Double
zenith1 latitude hour_angle declination = acos(cos latitude * cos hour_angle * cos declination
                                          + sin declination * sin latitude) 

correct_zenith_distance :: Double -> Double
correct_zenith_distance zenith_distance = toDegrees (zenith_distance + parallax)
                          where parallax = 6371.01/149597890 * sin zenith_distance

azimuth :: Double -> Double -> Double -> Double
azimuth hour_angle declination latitude = atan2 (-sin(hour_angle)) (tan(declination) * cos(latitude) - sin(latitude) * cos(hour_angle))
--correct azimuth for radians
correct_azimuth :: Double -> Double
correct_azimuth azimuth
    | azimuth < 0 = toDegrees (azimuth + 2 * pi)
    | otherwise = toDegrees azimuth

toDegrees x = x/(pi/180)
toRadians x = x*(pi/180)

main :: IO()
main = do args <- getArgs
          let utc = posixSecondsToUTCTime (fromRational ( toRational (secondsToDiffTime (read (args!!0)))))
          let dateTime = utcToDateTime utc
          let tuple = splitDateTime (fst dateTime) (snd dateTime)
          let results = get_solar_vector (fst tuple) (snd tuple) (read (args!!1)) (read (args!!2))
          putStrLn ((show (fst results))++" "++(show (snd results)))

utcToDateTime :: UTCTime -> (DateTime, DiffTime)
utcToDateTime (UTCTime day difftime) = ((dayToDateTime day), difftime)

d_round :: Double -> Double
d_round x = fromIntegral (round x)

splitDateTime :: DateTime -> DiffTime -> (Date, DTime)
splitDateTime (DateTime year month day hour minute second) diffTime = 
  (Date (fromIntegral year) (fromIntegral month) (fromIntegral day),
   DTime (hour) (minute) (d_round ((c_t-(hour*60*60)-(minute*60))/60)))
   where c_t = fromRational (toRational diffTime)
         hour = d_round(c_t/(60*60))
         minute = d_round((c_t-(hour*60*60))/60)
