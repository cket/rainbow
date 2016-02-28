--haskell

data Time = Time {hour :: Double
                  , minute :: Double
                  , second :: Double
                  }

data Date = Date {year :: Double
                  , month :: Double
                  , day :: Double
                 }

get_hour_dec :: Time -> Double
get_hour_dec  (Time hour minute second) = hour
                                        + minute/60.0 
                                        + second/360 

get_julian_date :: Date -> Time -> Double
get_julian_date (Date year month day) (Time hour minute second) = (1461 * (year + 4800 + (month - 14)/12))/4 
                                        + (367 * (month - 2 - 12 * ((month - 14)/12)))/12 
                                           - (3 * ((year + 4900 + (month - 14)/12)/100))/4 
                                        + day - 32075 - 0.5 + hour/24.0

jd_to_ecliptic :: Date -> Time -> (Double, Double)
jd_to_ecliptic date time = (mean_longitute + (0.03341607 * (sin(mean_anomaly)))
                        + (0.00034894 * (sin (2 * mean_anomaly))) - 0.0001134 - (0.0000203 * (sin(omega))),
                         0.4090928 - 6.2140e-9 * (n(get_julian_date date time)) + 0.0000396 * cos(omega)) 
                        where mean_anomaly = 6.2400600 + 0.0172019699 * (n (get_julian_date date time))
                              omega = 2.1429 - 0.0010394594 * (n (get_julian_date date time))
                              mean_longitute = 4.8950630 + 0.017202791698 * (n (get_julian_date date time))

ecliptic_to_celestial :: (Double, Double) -> (Double, Double)
ecliptic_to_celestial (l, ep) = ((atan2 ((cos ep) * (sin l)) (cos l)), (asin((sin ep) * (sin l)))) --need to adjust right ascension

get_solar_vector :: Date -> Time -> Double -> Double -> (Double, Double)
get_solar_vector date time latitude longitude = (correct_zenith_distance (parallax zen1) zen1, correct_azimuth (azimuth (hour_angle date time longitude) (declination date time) latitude))
        where zen1 = zenith1 latitude (hour_angle date time longitude) (declination date time)

n :: Double -> Double
n jd = jd - 2451545.0

omega :: Double -> Double
omega n = 2.1429 - 0.0010394594 * n

mean_longitude :: Double -> Double
mean_longitude n = 4.8950630 + 0.017202791698 * n

mean_anomaly :: Double -> Double
mean_anomaly n = 6.2400600 + 0.0172019699 * n

hour_angle :: Date -> Time -> Double -> Double
hour_angle date time longitude = (gmst * 15 + longitude) * radians - right_ascension
             where radians = pi/180
                   gmst = 6.6974243242 + 0.0657098283 * (n (get_julian_date date time)) + get_hour_dec time
                   right_ascension = fst (ecliptic_to_celestial(jd_to_ecliptic date time))

declination :: Date -> Time -> Double
declination date time = snd (ecliptic_to_celestial(jd_to_ecliptic date time))

zenith1 :: Double -> Double -> Double -> Double
zenith1 latitude hour_angle declination = acos(cos(latitude) * cos(hour_angle) * cos(declination)
                                           + sin(declination) * sin(latitude))

parallax :: Double -> Double
parallax zenith_distance = earth_mean_radius/astronomical_unit * sin(zenith_distance)
                           where earth_mean_radius = 6371.01 
                                 astronomical_unit = 149597890  

correct_zenith_distance :: Double -> Double -> Double
correct_zenith_distance parallax zenith_distance = (zenith_distance + parallax)/radians
                                                   where radians = pi/180

azimuth :: Double -> Double -> Double -> Double
azimuth hour_angle declination latitude = atan2 (-sin(hour_angle)) (tan(declination) * cos(latitude) - sin(latitude) * cos(hour_angle))
--correct azimuth for radians
correct_azimuth :: Double -> Double
correct_azimuth azimuth
    | azimuth < 0 = (azimuth + 2 * pi)/(pi/180)
    | otherwise = azimuth/(pi/180)

