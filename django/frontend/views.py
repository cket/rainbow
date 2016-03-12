import geoip2.database
import socket
import requests
from subprocess import check_output
import time
import os
from urllib.request import urlopen
from django.shortcuts import render
from django.http import HttpResponse

def index(request):
    #call script here
    reader = geoip2.database.Reader('./frontend/GeoLite2-City.mmdb')

    ip = urlopen('http://ip.42.pl/raw').read().decode("utf-8") 

    response = reader.city(ip) #ip
    lat = response.location.latitude
    lon = response.location.longitude 
    city = response.city.name

    current_weather = requests.get('http://api.openweathermap.org/data/2.5/weather?q={},us&APPID=ddbf6e1389436b869677797efc0b2907'.format(city))
    current_weather = current_weather.json()
    weather_desc = current_weather['weather'][0]['description']

    try:
        if 0 < float(current_weather['rain']['3h']):  # free tier api includes only last 3 hours of weather data
            good_weather = True
    except KeyError:
        good_weather = False # API sometimes leaves out the rain field if it isn't raining. but not always. cool.

    def rainbowFile(string):
        return os.path.isfile("../backend/"+string) and (string.startswith('rainbow') or string.startswith('Rainbow'))

    runnable= next(filter(rainbowFile, os.listdir('../backend')))  # should be only one rainbow file here

    if runnable.endswith(".py"):
        to_execute="python3"
    elif runnable.endswith(".class"):
        to_execute="java"
    else:
        to_execute=""
    
    if to_execute=="java":
        command = "cd ../backend && java Rainbow {} {} {}".format(int(time.time()), lat, lon)
    else:
        command = "{} ../backend/{} {} {} {}".format(to_execute, runnable, int(time.time()), lat, lon)

    solar_vector = check_output(command, shell=True)
    solar_vector = solar_vector.decode('utf-8').split(" ", 1)  # our vector is read in as a byte string
    zenith_distance = list(map(float, solar_vector))[0]
    solar_height = 90 - zenith_distance

    rainbow = ""
    if 0 < solar_height < 42 and good_weather:
        rainbow = "There could be a rainbow!"
    else:
        rainbow = "There is probably not a rainbow :("
    context = {'response':"You are in {} at coordinates ({}, {}) with ip {} and your weather is {}. The solar height is {}. \
        {}".format(city, lat, lon, ip, weather_desc, solar_height, rainbow)}
    
    return render(request, 'rainbow.html', context)
