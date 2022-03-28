#!/bin/bash

opt/TurboVNC/bin/vncserver :1 -fg -autokill &

xvfb-run --auto-servernum /home/docker/slicer/Slicer