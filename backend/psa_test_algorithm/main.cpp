//main.cpp
#include <iostream>
#include "sunpos.h"
#include <ctime>

using namespace std;

int main(int argc, char *argv[]) {
   cSunCoordinates coords = {0.0, 0.0};

   long int unix_time = stoi(argv[1]);

   time_t t = static_cast<time_t>(unix_time);
   struct tm* datetime = localtime(&t);

   double lat = stod(argv[2]);
   double lon = stod(argv[3]);

   //cout << lat << lon << endl;

   //test time
   cTime time = {
      datetime->tm_year + 1900, //year
      datetime->tm_mon, //month
      datetime->tm_mday, //day
      datetime->tm_hour, //hour
      datetime->tm_min, //minute
      datetime->tm_sec //second
   };

   cout << "year " << datetime->tm_year << " month " << datetime->tm_mon << " day " << datetime->tm_mday << " hour " << datetime->tm_hour << " min " << datetime->tm_min << " sec " << datetime->tm_sec << endl;

   //test location
   cLocation place = {
      lon, //long
      lat //lat
   };

   sunpos(time, place, &coords);

   cout << coords.dZenithAngle << " " << coords.dAzimuth << endl;
   return 0;
}
