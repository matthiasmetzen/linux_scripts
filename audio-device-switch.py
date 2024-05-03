#!/bin/python

import os
import re

enable_notification = False
ignore = [r'Simultaneous', r'HDMI']


def getSinks():
    lines = os.popen("pacmd list-sinks").readlines()
    index_lines = [line for line in lines if re.search(r'\s*\*?\s*index:\s*\d+', line)]
    descriptions = [re.match(r'\s*device.description\s*=\s*"(.*)"', line).group(1) 
        for line in lines 
        if re.match(r'\s*device.description\s*=\s*"(.*)"', line)]
    indexes = [int(re.match(r'\s*\*?\s*index:\s*(\d+)', line).group(1)) for line in index_lines]

    sinks = {id:descriptions[indexes.index(id)] for id in indexes}

    for line in index_lines:
        if t := re.match(r'\s*\*\s*index:\s*(\d+)', line):
            return sinks, int(t.group(1))
    raise Exception("could not find active sink")

def getNextSink(sinks, active):
    keys = list(sinks.keys())
    return keys[(keys.index(active) + 1) % len(keys)]

def getApps():
    lines = os.popen("pacmd list-sink-inputs").readlines()
    return [int(re.match(r'\s*\*?\s*index:\s*(\d+)', line).group(1)) for line in lines if re.match(r'\s*\*?\s*index:\s*(\d+)', line)]

def setSinkForApp(app, sink):
    os.popen(f"pacmd \"move-sink-input {app} {sink}\"")

def switchToSink(sink):
    os.popen(f"pacmd \"set-default-sink {sink}\"")
    for app in getApps():
        setSinkForApp(app, sink)

def notify(sink, sinks):
    os.popen(f"notify-send -i notification-audio-volume-high \"Sound output switched to\" \"{sinks[sink]}\"")

def filterSinks(sinks, active):
    filtered_sinks = sinks.copy()
    for id,name in sinks.items():
        if id == active:
            continue
        for pat in ignore:
            if re.search(pat, name):
                del filtered_sinks[id]
                break
    return filtered_sinks


if __name__ == "__main__":
    sinks, active = getSinks()

    sinks = filterSinks(sinks, active)
    next_sink = getNextSink(sinks,active)
    switchToSink(next_sink)

    if enable_notification:
        notify(next_sink, sinks)
