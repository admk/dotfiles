#!/usr/bin/env python3
# -*- encoding: utf-8 -*-


import urllib.request
import json


location = 'London'
celcius = True
prec = 1


def fetch(location, celcius=True):
    unit = 'metric' if celcius else 'imperial'
    weather_url = \
        'http://api.openweathermap.org/data/2.5/weather?q=%s&units=%s' % \
        (location, unit)
    response = urllib.request.urlopen(weather_url).read()
    return json.loads(response.decode('utf-8'))


def pictograph(json_str):
    def is_daytime():
        from datetime import datetime
        return 6 <= datetime.now().hour < 18
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
        return '?'
    if len(pict) == 1:
        return pict
    return pict[is_daytime()]


def temperature(json_str):
    return json_str['main']['temp']


def format_weather(location, celcius=True, prec=0):
    json_str = fetch(location, celcius)
    if celcius:
        unit = '℃'
    else:
        unit = '℉'
    return '{pictograph}{temperature:.{prec}f}{unit}'.format(
        pictograph=pictograph(json_str), prec=prec,
        temperature=temperature(json_str), unit=unit)


if __name__ == '__main__':
    import sys
    sys.stdout.write(format_weather(location, celcius, prec))
    sys.stdout.flush()
