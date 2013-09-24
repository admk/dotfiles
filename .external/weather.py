#!/usr/bin/env python3
# -*- encoding: utf-8 -*-


import os
import sys
import urllib.request
import json


location = 'London'
celcius = True
precision = 1
emoji = True


def fetch(location, celcius=True):
    unit = 'metric' if celcius else 'imperial'
    weather_url = \
        'http://api.openweathermap.org/data/2.5/weather?q=%s&units=%s' % \
        (location, unit)
    response = urllib.request.urlopen(weather_url).read()
    return json.loads(response.decode('utf-8'))


def pictograph(json_str, use_emoji):
    def is_daytime():
        from datetime import datetime
        return 6 <= datetime.now().hour < 18
    if use_emoji:
        _pictograph_dict = {
            2: '⚡',    # thunderstorm
            3: '🌂',    # drizzle
            4: '☔',    # rain
            6: '⛄',    # snow
            7: '🌁',    # mist/smoke/haze/sand/fog
            8: '⛅',    # clouds
            9: '🌀',    # extreme
            # specials
            800: '🌜🌞'  # clear sky
        }
    else:
        _pictograph_dict = {
            2: '☈',    # thunderstorm
            3: '☂',    # drizzle
            4: '☔',    # rain
            6: '❄',    # snow
            7: '〰',   # mist/smoke/haze/sand/fog
            8: '☁',    # clouds
            9: '颶',   # extreme
            # specials
            800: '☽☼'  # clear sky
        }
    code = json_str['weather'][0]['id']
    try:
        pict = _pictograph_dict[code]
    except KeyError:
        code = int(code / 100)
    try:
        pict = _pictograph_dict[code]
    except KeyError:
        return ' '
    if len(pict) != 1:
        pict = pict[is_daytime()]
    if use_emoji:
        pict += ' '
    return pict


def temperature(json_str):
    return json_str['main']['temp']


def format_weather(location, celcius=True, precision=0):
    location = os.environ.get('WEATHER_LOCATION') or location
    celcius = os.environ.get('WEATHER_CELCIUS') or celcius
    precision = os.environ.get('WEATHER_PRECISION') or precision
    json_str = fetch(location, celcius)
    unit = '℃' if celcius else '℉'
    use_emoji = emoji and sys.platform == 'darwin'
    return '{pictograph}{temperature:.{precision}f}{unit}'.format(
        pictograph=pictograph(json_str, use_emoji), precision=precision,
        temperature=temperature(json_str), unit=unit)


if __name__ == '__main__':
    sys.stdout.write(format_weather(location, celcius, precision))
    sys.stdout.flush()
