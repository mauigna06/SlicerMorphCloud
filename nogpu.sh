#!/bin/bash

set -u
set -e

# Run this with a command like:
#
#  for user in $(cat users); do ./nogpu.run $user ; done > instance-table.csv
#

# convenience function to send feedback to stderr so stdout can go to csv
errcho(){ >&2 echo $@; }

if [ "$1" == "" ]; then
        echo "Usage: ./nogpu.run <User>"
        exit
fi
USERNAME=$1

script_dir=$(cd $(dirname $0) || exit 1; pwd)
errcho $script_dir

CONTAINER_NAME=${USERNAME}
CONTAINER_ID=$(docker run -it \
        --name ${CONTAINER_NAME} \
        -d \
        --expose 5801 \
        --expose 5901 \
        --expose 2016 \
        -P \
        -v $script_dir/dockerLogs/:/var/log/docker/ \
        --rm \
        -m 100g \
        --cpus=4 \
        cloud)

# CONTAINER_NAME=$(docker ps --filter "id=$CONTAINER_ID" --format "{{.Names}}")
errcho
errcho Execute:
errcho docker stop $CONTAINER_NAME
errcho "to stop container (or log out of the window manager in the TurboVNC session.)"
errcho
PORT=$(docker port $CONTAINER_NAME 5901 | cut -f2 -d:)
NOVNC_PORT=$(docker port $CONTAINER_NAME 5801 | cut -f2 -d:)
REST_API_PORT=$(docker port $CONTAINER_NAME 2016 | cut -f2 -d:)
VNC_DISPLAY=`hostname`::$PORT
errcho "VNC DISPLAY is ${VNC_DISPLAY}"
NOVNC_URL="http://`hostname`:${NOVNC_PORT}/vnc.html?host=`hostname`&port=$PORT&resize=remote"
errcho "NOVNC URL is ${NOVNC_URL}"

#Remember that only process with PID==1 writes on the docker log so other processes don't
# write to it
OTP=
while [ "$OTP" = "" ]; do
        sleep 1
        OTP=$(cat $script_dir/dockerLogs/TurboVNCerror.log | grep "Full control one-time password" | sed 's/.*: //g')
done
errcho SESSION PASSWORD is $OTP
docker exec $CONTAINER_NAME sh -c "echo $OTP| /opt/TurboVNC/bin/vncpasswd -f >/home/docker/.vnc/passwd 2>/dev/null"

docker exec -d ${CONTAINER_NAME} /home/docker/slicer/Slicer

#errcho USERNAME, PORT, NOVNC_PORT, REST_API_PORT, VNC_DISPLAY, NOVNC_URL, OTP
#errcho $USERNAME, $PORT, $NOVNC_PORT, $REST_API_PORT, $VNC_DISPLAY, $NOVNC_URL, $OTP

errcho
errcho Open the NoVNC url, click connect, input the password, press right click on the black screen and go to Applications-Utilities-Slicer, the GUI will be unresponsive while a demo CT download is complete, the API server will start. Try this link:
REST_API_URL=http://`hostname`:${REST_API_PORT}
errcho "${REST_API_URL}"
POST_URL=`hostname`:${REST_API_PORT}/slicer/repl
errcho
errcho Execute Slicer code like this:
errcho curl -X POST "${POST_URL}" --data \"slicer.app.layoutManager\(\).setLayout\(slicer.vtkMRMLLayoutNode.SlicerLayoutOneUpRedSliceView\)\"

