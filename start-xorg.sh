#!/bin/sh

# Tell the script to exit as soon as any line in the script fails (with some exceptions listed in the manual)
set -e
# Turn off debugging
set +x

# If a command is terminated by the control operator &, the shell executes the command in the background in a subshell. The shell does not wait for the command to finish, and the return status is 0.
# execute Xorg server
Xorg -noreset +extension GLX +extension RANDR +extension RENDER -logfile ./10.log -config $HOME/xorg.conf $DISPLAY &

# grab the process id in order to control it later
export XORG_PID=$!

# give bg X time to start
sleep 2
