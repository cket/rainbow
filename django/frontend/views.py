import geoip2.database
import socket
import requests
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
    if 'rain' in current_weather.json():
    	rain = "It has been raining"
    else:
    	rain = "It has not been raining"
    return HttpResponse("You are in {} at coordinates ({}, {}) with ip {}. {}.".format(city, lon, lat, ip, rain))
