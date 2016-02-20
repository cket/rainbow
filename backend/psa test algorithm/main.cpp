//main.cpp
#include <iostream>
#include "sunpos.h"

using namespace std;

int main() {
   cout << "hello world" << endl;
   cSunCoordinates coords = {0.0, 0.0};

   //test time
   cTime time = {
      2016, //year
      2, //month
      18, //day
      12.0, //hour
      0.0, //minute
      0.0 //second
   };

   //test location
   cLocation place = {
      36.9733, //lat
      -122.036 //long
   };

   sunpos(time, place, &coords);

   cout << coords.dZenithAngle << "," << coords.dAzimuth << endl;
   return 0;
}
