//main.cpp
#include <iostream>
#include "sunpos.h"
#include <ctime>

using namespace std;

int main(int argc, char *argv[]) {
   cSunCoordinates coords = {0.0, 0.0};

   long int unix_time = stoi(argv[1]);

   time_t t = static_cast<time_t>(unix_time);
   struct tm* datetime = gmtime(&t);

   double lat = stod(argv[2]);
   double lon = stod(argv[3]);

   //test time
   cTime time = {
      (datetime->tm_year + 1900), //year
      datetime->tm_mon + 1, //month
      datetime->tm_mday, //day
      datetime->tm_hour, //hour
      datetime->tm_min, //minute
      datetime->tm_sec //second
   };


   //test location
   cLocation place = {
      lon, //long
      lat //lat
   };

   sunpos(time, place, &coords);

   cout << coords.dZenithAngle << " " << coords.dAzimuth << endl;
   return 0;
}
