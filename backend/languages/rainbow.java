import java.util.*;
import java.time.*;

// storage classes for coordinate values
class Ecliptic_coords {
   double longitude;
   double obliquity;
   public Ecliptic_coords(double longitude, double obliquity) {
      this.longitude = longitude;
      this.obliquity = obliquity;
   }
}

class Celestial_coords {
   double right_ascension;
   double declination;
   public Celestial_coords(double right_ascension, double declination) {
      this.right_ascension = right_ascension;
      this.declination = declination;
   }
}

class Solar_vec {
   double zenith_distance;
   double azimuth;
   public Solar_vec(double zenith_distance, double azimuth) {
      this.zenith_distance = zenith_distance;
      this.azimuth = azimuth;
   }
   public String toString() {
      return zenith_distance + " " + azimuth;
   }
}


// main, etc.
class Rainbow {

   public static double get_hour_decimal(LocalDateTime datetime) {
      double second = datetime.getSecond() + datetime.getNano()/10e9;
      double minute = datetime.getMinute() + second/60;
      return datetime.getHour() + minute/60;
   }


   public static double get_julian_day(LocalDateTime datetime) {
      //utc_datetime.date.day
      int day = datetime.getDayOfMonth();
      int month = datetime.getMonthValue();
      int year = datetime.getYear();
      double hour = get_hour_decimal(datetime);
      return (1461 * (year + 4800 + (month - 14)/12))/4 +
         (367 * (month - 2 - 12 * ((month - 14)/12)))/12 -
         (3 * ((year + 4900 + (month - 14)/12)/100))/4 +
         day - 32075 - .5 + hour/24.0;
   }


   public static Ecliptic_coords jd_to_ecliptic(double jd) {
      double n = jd - 2451545.0;
      double omega = 2.1429 - 0.0010394594 * n;
      double mean_longitude = 4.8950630 + 0.017202791698 * n;
      double mean_anomaly = 6.2400600 + 0.0172019699 * n;
      double ecliptic_longitude = mean_longitude + 0.03341607 * Math.sin(mean_anomaly)
         + 0.00034894 * Math.sin(2 * mean_anomaly) - 0.0001134 - 0.0000203 * Math.sin(omega);
      double obliquity_of_ecliptic = 0.4090928 - 6.2140e-9 * n
         + 0.0000396 * Math.cos(omega);
      return new Ecliptic_coords(ecliptic_longitude, obliquity_of_ecliptic);
   }


   public static Celestial_coords ecliptic_to_celestial(Ecliptic_coords ecliptic) {
      double el = ecliptic.longitude;
      double oe = ecliptic.obliquity;
      double right_ascension = Math.atan2(Math.cos(oe) * Math.sin(el), Math.cos(el));
      // ensure right_ascension is in range 0 to 2 * pi
      if (right_ascension < 0.0) right_ascension += 2 * Math.PI;
      double declination = Math.asin(Math.sin(oe) * Math.sin(el));
      return new Celestial_coords(right_ascension, declination);
   }


   public static Solar_vec get_solar_vector(LocalDateTime datetime, double latitude, double longitude) {
      // some constants
      double earth_mean_radius = 6371.01;  // km
      double astronomical_unit = 149597890; // km
      double radians = (Math.PI/180.0);

      double jd = get_julian_day(datetime);
      Ecliptic_coords ecliptic = jd_to_ecliptic(jd);
      Celestial_coords celestials = ecliptic_to_celestial(ecliptic);
      double right_ascension = celestials.right_ascension;
      double declination = celestials.declination;

      double n = jd - 2451545.0;
      double hour = get_hour_decimal(datetime);
      // greenwich mean sidereal time
      double gmst = 6.6974243242 + 0.0657098283 * n + hour;
      // local mean sidereal time
      double lmst = (gmst * 15 + longitude) * radians;
      double hour_angle = lmst - right_ascension;
      // convert latitude to radians
      latitude *= radians;

      // calculate zenith distance
      double zenith_distance = Math.acos(Math.cos(latitude) * Math.cos(hour_angle)
            * Math.cos(declination) + Math.sin(declination) * Math.sin(latitude));
      double parallax = earth_mean_radius/astronomical_unit * Math.sin(zenith_distance);
      // correct zenith_distance with parallax and convert to degrees
      zenith_distance = (zenith_distance + parallax)/radians;

      // calculate azimuth
      double azimuth = Math.atan2(-Math.sin(hour_angle), Math.tan(declination)
            * Math.cos(latitude) - Math.sin(latitude) * Math.cos(hour_angle));
      // ensure azimuth is in range 0 - 2pi and convert to degrees
      if (azimuth < 0.0) azimuth += 2 * Math.PI;
      azimuth /= radians;

      return new Solar_vec(zenith_distance, azimuth);
   }


   public static void main(String[] args) {
      /**
       * Calculates solar vector in degrees given the following args:
       *    unix timestamp    (int)
       *    latitude          (double)
       *    longitude         (double)
       * in that order. Assumes input is correct (does not check or
       * give warnings. Output is zenith deistance followed by azimuth.
       *
       * Example usage:
       *    $ java Rainbow 1456605767 33.9733 -122.036
       *    42.623741274448605 187.72391518184588
       */
      // extract arguments
      long unix_timestamp = Long.parseLong(args[0]);
      LocalDateTime in_datetime = LocalDateTime.ofEpochSecond(unix_timestamp, 0, ZoneOffset.UTC);
      double latitude = Double.parseDouble(args[1]);
      double longitude = Double.parseDouble(args[2]);

      // calculate solar vector
      Solar_vec sol = get_solar_vector(in_datetime, latitude, longitude);
      System.out.println(sol);
   }
}
