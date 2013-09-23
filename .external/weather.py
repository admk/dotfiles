#!/usr/bin/env python3
# -*- encoding: utf-8 -*-


import urllib.request
import json

location = 'London'
celcius = True
prec = 0

unit = 'metric' if celcius else 'imperial'
weather_url = \
    'http://api.openweathermap.org/data/2.5/weather?q=%s&units=%s' % \
    (location, unit)

f = json.loads(urllib.request.urlopen(weather_url).read().decode('utf-8'))

condition_code = int(f['weather'][0]['id'] / 100)
temperature = f['main']['temp']

if condition_code == 2:  # thunderstorm
    symbol = '☈'
elif condition_code == 3:  # drizzle
    symbol = 'Drizzle'
elif condition_code == 5:  # rain
    symbol = '☔'
elif condition_code == 6:  # snow
    symbol = '❄'
elif condition_code == 7:  # mist/smoke/haze/sand/fog
    symbol = '〰'
elif condition_code == 8:  # clouds
    symbol = '☁'
elif condition_code == 9:  # extreme
    symbol = '颶'
else:
    symbol = '?'

if celcius:
    unit = '℃'
else:
    unit = '℉'

try:
    print(('%s %1.' + str(prec) + 'f%s') % (symbol, temperature, unit))
except Exception as e:
    print(e)
