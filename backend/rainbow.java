import java.util.*;

class Rainbow {
	public int get_hour_decimal(Calendar calendar){ // whoops, its just an int for now
		// Date date = new Date();   // given date
		// Calendar calendar = GregorianCalendar.getInstance(); // creates a new calendar instance
		// calendar.setTime(date);   // assigns calendar to given date 
		return calendar.get(Calendar.HOUR_OF_DAY);
	}
	public double get_julian_day(Calendar calendar){
		int day = calendar.get(Calendar.DAY_OF_MONTH);//utc_datetime.date.day
    	int month = calendar.get(Calendar.MONTH);
    	int year =  calendar.get(Calendar.YEAR);
    	int hour = get_hour_decimal(calendar);
    	return (1461 * (year + 4800 + (month - 14)/12))/4 + (367 * (month - 2 - 12 * ((month - 14)/12)))/12 - (3 * ((year + 4900 + (month - 14)/12)/100))/4 + day - 32075 - .5 + hour/24.0;
	}
	public double[] jd_to_ecliptic(double jd){
		double n = jd - 2451545.0;
    	double omega = 2.1429 - 0.0010394594 * n;
    	double mean_longitude = 4.8950630 + 0.017202791698 * n;
    	double mean_anomaly = 6.2400600 + 0.0172019699 * n;
    	double ecliptic_longitude = mean_longitude + 0.03341607 * Math.sin(mean_anomaly) + 0.00034894 * Math.sin(2 * mean_anomaly) - 0.0001134 - 0.0000203 * Math.sin(omega);
    	double obliquity_of_ecliptic = 0.4090928 - 6.2140e-9 * n + 0.0000396 * Math.cos(omega);
    	double[] ecliptics = new double[] {ecliptic_longitude, obliquity_of_ecliptic};
    	return ecliptics;
	}
	public double[] ecliptic_to_celestial(double[] ecliptic){
		double el = ecliptic[0];
		double oe = ecliptic[1];
    	double right_ascension = Math.atan2(Math.cos(oe) * Math.sin(el), Math.cos(el));
    	// ensure right_ascension is in range 0 to 2 * pi
    	if (right_ascension < 0.0) right_ascension += 2 * Math.PI;
    	double declination = Math.asin(Math.sin(oe) * Math.sin(el));
    	return new double[] {right_ascension, declination};
	}
	public double[] get_horizontal(Calendar calendar, double latitude, double longitude){
	double earth_mean_radius = 6371.01;  // km
    double astronomical_unit = 149597890; // km

    double jd = get_julian_day(calendar);
    double[] ecliptic = jd_to_ecliptic(jd);
    double[] celestials= ecliptic_to_celestial(ecliptic);
    double right_ascension = celestials[0];
    double declination = celestials[1];

    double n = jd - 2451545.0;
    int hour = get_hour_decimal(calendar); //should be double
    // greenwich mean sidereal time
    double gmst = 6.6974243242 + 0.0657098283 * n + hour;
    // local mean sidereal time
    double lmst = (gmst * 15 + longitude) * (Math.PI/180.0);
    double hour_angle = lmst - right_ascension;

    double zenith_distance = Math.acos(Math.cos(latitude) * Math.cos(hour_angle) * Math.cos(declination) + Math.sin(declination) * Math.sin(latitude));
    double parallax = earth_mean_radius/astronomical_unit * Math.sin(zenith_distance);
    // correct zenith_distance with parallax:
    zenith_distance += parallax;

    double azimuth = Math.atan2(-Math.sin(hour_angle), Math.tan(declination) * Math.cos(latitude) - Math.sin(latitude) * Math.cos(hour_angle));

    return new double[]{zenith_distance, azimuth};
	}
	public static void main(String[] args) {
	        System.out.println("Hello Rainblows!");
	}
}
