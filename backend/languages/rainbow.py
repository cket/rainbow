# backend for rainbow calculator
# implementation of PSA algorithm


# information we need:
# latitude, longitude, time


import datetime, argparse
from math import sin, cos, tan, asin, acos, atan2, pi


def get_hour_decimal(time):
    """
    converts time into an hour with minutes, seconds, etc. incorporated
    as a decimal
    :param time: a python datetime.time object
    :return: hour as a decimal
    """
    second = time.second + time.microsecond/10e6
    minute = time.minute + time.second/60.0
    return time.hour + time.minute/60.0


def get_julian_day(utc_datetime):
    """
    calculated the Julian Day for a particular date time
    Assumes time is in UTC
    :param utc_datetime: a python datetime object corresponding to UTC
    :return: the Julian Day
    """
    day = utc_datetime.day
    month = utc_datetime.month
    year = utc_datetime.year
    hour = get_hour_decimal(utc_datetime.time())
    return (1461 * (year + 4800 + (month - 14)/12))/4 \
            + (367 * (month - 2 - 12 * ((month - 14)/12)))/12 \
            - (3 * ((year + 4900 + (month - 14)/12)/100))/4 \
            + day - 32075 - .5 + hour/24.0


def jd_to_ecliptic(jd):
    """
    calculates the ecliptic coordinates of the Sun from the Julian Day
    in radians
    :param jd: the Julian Day
    :return: (ecliptic_longitude, obliquity_of_ecliptic)
    """
    n = jd - 2451545.0
    omega = 2.1429 - 0.0010394594 * n
    mean_longitude = 4.8950630 + 0.017202791698 * n
    mean_anomaly = 6.2400600 + 0.0172019699 * n
    ecliptic_longitude = mean_longitude + 0.03341607 * sin(mean_anomaly) \
                        + 0.00034894 * sin(2 * mean_anomaly) \
                        - 0.0001134 \
                        - 0.0000203 * sin(omega)
    obliquity_of_ecliptic = 0.4090928 \
                        - 6.2140e-9 * n \
                        + 0.0000396 * cos(omega)
    return ecliptic_longitude, obliquity_of_ecliptic


def ecliptic_to_celestial(ecliptic_coords):
    """
    calculates the celestial coordinates from ecliptic coordinates in
    radians
    :param ecliptic_coords: (ecliptic_longitude, obliquity_of_ecliptic)
    :return: (right_ascension, declination)
    """
    l, ep = ecliptic_coords
    right_ascension = atan2(cos(ep) * sin(l), cos(l))
    # ensure right_ascension is in range 0 to 2 * pi
    if right_ascension < 0.0: right_ascension += 2 * pi
    declination = asin(sin(ep) * sin(l))
    return right_ascension, declination


def get_solar_vector(utc_datetime, latitude, longitude):
    """
    calculates the solar vector in terms of the zenith distance and the
    solar azimuth
    :param utc_datetime: a datetime object in UTC
    :param latitude: latitude of observer's position
    :param longitude: longitude of observer's position
    :return: (zenith distance, azimuth)
    """
    # some constants
    earth_mean_radius = 6371.01  # km
    astronomical_unit = 149597890  # km
    radians = pi/180

    jd = get_julian_day(utc_datetime)
    ecliptic = jd_to_ecliptic(jd)
    right_ascension, declination = ecliptic_to_celestial(ecliptic)

    n = jd - 2451545.0
    hour = get_hour_decimal(utc_datetime.time())
    # greenwich mean sidereal time
    gmst = 6.6974243242 + 0.0657098283 * n + hour
    # local mean sidereal time
    lmst = (gmst * 15 + longitude) * radians
    hour_angle = lmst - right_ascension
    # convert latitude to radians
    latitude *= radians

    # calculate zenith distance
    zenith_distance = acos(cos(latitude) * cos(hour_angle) * cos(declination)
                           + sin(declination) * sin(latitude))

    parallax = earth_mean_radius/astronomical_unit * sin(zenith_distance)

    # correct zenith_distance with parallax and convert to degrees:
    zenith_distance = (zenith_distance + parallax)/radians

    # calculate azimuth
    azimuth = atan2(-sin(hour_angle), tan(declination) * cos(latitude)
                    - sin(latitude) * cos(hour_angle))

    # ensure azimuth is in range 0 - 2pi and convert to degrees
    if azimuth < 0.0: azimuth += 2 * pi
    azimuth /= radians

    return zenith_distance, azimuth


if __name__ == "__main__":
    """
    takes in three commandline arguments:
        unix timestamp      (int)
        latitude            (float)
        longitude           (float)
    in that order. Assumes timestamp is valid.
    Output is solar vector.

    example usage:

     $ python3 rainbow.py 1456605767 33.9733 -122.036
     42.623741274448605 187.72391518184588

    """
    # extract command line arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('unix_timestamp', type=int)
    parser.add_argument('latitude', type=float)
    parser.add_argument('longitude', type=float)
    args = parser.parse_args()

    in_datetime = datetime.datetime.utcfromtimestamp(args.unix_timestamp)
    solar_vec = get_solar_vector(in_datetime, args.latitude, args.longitude)
    print(*solar_vec)

    """
    test_datetime = datetime.datetime(2016, 2, 18, 12)  #date and hour
    test_lat = 36.9733
    test_lng = -122.036
    print(*get_solar_vector(test_datetime, test_lat, test_lng))
    """
