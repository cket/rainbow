import geoip2.database
import socket
import requests
from subprocess import check_output
import time
from urllib.request import urlopen
from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    #call script here
    reader = geoip2.database.Reader('./frontend/GeoLite2-City.mmdb')
    ip = urlopen('http://ip.42.pl/raw').read().decode("utf-8") 
    response = reader.city(ip) #ip
    city = response.city.name
    current_weather = requests.get('http://api.openweathermap.org/data/2.5/weather?q={}'.format(city))
    lat = response.location.latitude
    lon = response.location.longitude

    good_weather = False
    if 'rain' in current_weather.json():
        good_weather = True

    solar_vector = check_output("python3 ../backend/rainbow.py {} {} {}".format(int(time.time()), lat, lon), shell=True)
    solar_vector = solar_vector.decode('utf-8').split(" ", 1)
    zenith_distance = list(map(float, solar_vector))[0]
    solar_height = 90 - zenith_distance

    rainbow = ""
    if 0 < solar_height < 42 and good_weather:
        rainbow = "There could be a rainbow!"
    else:
        rainbow = "There is definitely probably not a rainbow :("
#     rainbow+="""
#                       ___----~~~~~~----___\n
#                  _-~~~____-----~~-----____~~~-_\n
#               ..~.-~~--   ___------___   --~~-_~..\n
#             .'_.~.~~---~~~  __----__  ~~~---~` ~`.`.\n
#           .'.~ .'.~~__---~~~        ~~~---__~`.`. `_`.\n
#          ' .'.' /'/~                        ~-.\.`. `.~.\n
#        /'/'/'/'/'/                             `.`.`. ~.\\\n
#      .~.~.~.~.~.~                                `..`. .`.\\\n
#     .'.'.'.'.'.'                                   \`.`.`.``.\n
#    | | | | | |                                      : .\ \ \ \\\n
#  _|_|_|_|_|_|_                                       : \.`.`. .\n
# |  G          |                                       : : : : :.\n
#  |  O  L     |     H A P P Y   S T .                   :: : : :|.\n
#  |   O  U    |                                         || | | | |.\n
# /     D  C    \           P A T R I C K ' S   D A Y ! .| | | | | |.\n
# |         K   |                                       ||| || | || |\n
#  \___________/________________________________________________________\n
#  """

    return HttpResponse("You are in {} at coordinates ({}, {}) with ip {}. {}: \
        the solar height is {}".format(city, lat, lon, ip, rainbow, solar_height))
