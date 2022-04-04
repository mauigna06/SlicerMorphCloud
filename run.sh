#!/bin/bash

/opt/TurboVNC/bin/vncserver :1 -fg -autokill -otp > /var/log/docker/TurboVNC.log 2> /var/log/docker/TurboVNCerror.log &

sleep 15

DISPLAY=:1 /home/docker/slicer/Slicer

