# <version>-glvnd-runtime: uses libglvnd for properly dispatching OpenGL API calls to the NVIDIA libraries. 
# Use this image if you have a pre-built application.
FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu20.04

# https://vsupalov.com/docker-arg-vs-env/
# add to enviroment variable NVIDIA_DRIVER_CAPABILITIES (container seen): graphics and compat32
ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},graphics,compat32

# Create a group called 'docker' with GID=1000
# Create user with userid=1000 and GID=1000, without home directory named 'docker' 
# with the default shell /bin/sh
# https://dhananjay4058.medium.com/what-does-sudo-usermod-a-g-group-user-do-on-linux-b1ab7ffbba9c
RUN groupadd -g 1000 docker \
 && useradd -u 1000 -g 1000 -m docker -s /bin/bash \
 && usermod -a -G docker docker

# Copy the contents of source (etc/tint2) to destination (etc/tint2)
COPY etc/tint2 /etc/tint2
#Chmod 755 sets permissions so that, (U)ser/owner can read, 
# can write and can execute. (G)roup can read, can't write and can execute. 
# (O)thers can read, can't write and can execute.
# Chmod 644 sets permissions so that, (U)ser / owner can read, 
# can write and can't execute. (G)roup can read, can't write and can't execute. 
# (O)thers can read, can't write and can't execute.
RUN chmod 755 /etc/tint2 \
 && chmod 644 /etc/tint2/*

COPY usr/local /usr/local
RUN chmod 755 /usr/local \
 && chmod 755 /usr/local/shared \
 && chmod 755 /usr/local/shared/backgrounds \
 && chmod 644 /usr/local/shared/backgrounds/*
COPY usr/share/applications /usr/share/applications
RUN chmod 755 /usr/share/applications \
 && chmod 644 /usr/share/applications/*

# “apt-get update” updates the package sources list to get the latest list of 
# available packages in the repositories and “apt-get upgrade” updates all the 
# packages presently installed in our Linux system to their latest versions.
RUN apt -y update \
 && apt -y upgrade

# change local time to New York time
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

# install system softwares, firefox, git, 
# libegl1: Vendor neutral GL dispatch library -- EGL support 
# libglu1-mesa: Mesa OpenGL utility library (GLU) 
# libnss3: This is a set of libraries designed to support cross-platform
#   development of security-enabled client and server applications.
# libpulse-mainloop-glib0: PulseAudio, previously known as Polypaudio, is a 
#    sound server for POSIX and WIN32 systems. It is a drop in replacement for the ESD 
#    sound server with much better latency, mixing/re-sampling quality and overall architecture. 
# libxcb: The X protocol C-language Binding (XCB) is a replacement for Xlib featuring a small 
#    footprint, latency hiding, direct access to the protocol, improved threading support, 
#    and extensibility.
# libxkbcommon-x11-0: This package provides an add-on library called xkbcommon-x11, 
#    to support creating keymaps with the XKB X11 protocol, by querying the X server directly. 
# libxt6: X11 toolkit intrinsics library. libXt provides the X Toolkit Intrinsics, an abstract
#    widget library upon which other toolkits are based.
# libxtst6: X11 Testing -- Record extension library. libXtst provides an X Window System client 
#    interface to the Record extension to the X protocol. 
# libxv1:  libXv provides an X Window System client interface to the XVideo extension to the X 
#   protocol. The XVideo extension allows for accelerated drawing of videos. Hardware adaptors 
#   are exposed to clients, which may draw in a number of colourspaces, including YUV.
# mate-terminal: MATE Terminal is a terminal emulation application that you can use to access a 
#   UNIX shell in the MATE environment. With it, you can run any application that is designed 
#   to run on VT102, VT220, and xterm terminals. MATE Terminal also has the ability to use 
#   multiple terminals in a single window (tabs) and supports management of different 
#   configurations (profiles). MATE Terminal is a fork of GNOME Terminal.
# openbox-menu: is a pipemenu for the openbox window manager. It provides a dynamic menu 
#   listing of installed applications. Most of the work is done by the LXDE library menu-cache. 
# python: latest version
# tint2: is a free and open source standalone panel / dock application available for Linux. 
#   It is a desktop environment and distribution agnostic panel, so you can install it on any 
#   Linux based OS. It can be used as a replacement for existing panels / docks in your desktop 
#   environment as it supports system tray applets and indicator applets. You can also use it as
#   an extra panel to accompany panels already available in your desktop environment. Tint2 is 
#   especially useful for desktop environments that don’t ship any panel by default (OpenBox 
#   for example).
# vim-common: Vim is an almost compatible version of the UNIX editor Vi. 
# wget: Wget is a free software package for retrieving files using HTTP, HTTPS, FTP and FTPS, 
#   the most widely used Internet protocols. It is a non-interactive commandline tool, so it may 
#   easily be called from scripts, cron jobs, terminals without X-Windows support, etc. 
# x11-utils: X11 utilities
#   An X client is a program that interfaces with an X server (almost always via
#   the X libraries), and thus with some input and output hardware like a
#   graphics card, monitor, keyboard, and pointing device (such as a mouse).
#   This package provides a miscellaneous assortment of X utilities
#   that ship with the X Window System
# x11-xkb-utils: X11 XKB utilities
#   xkbutils contains a number of client-side utilities for XKB, the X11 keyboard extension. 
# x11-xserver-utils: X server utilities
#   This package provides a miscellaneous assortment of X Server utilities that ship with the X 
#   Window System
# xauth: The xauth program is used to edit and display the authorization information used in 
#   connecting to the X server. This program is usually used to extract authorization records 
#   from one machine and merge them in on another (as is the case when using remote logins or 
#   granting access to other users).
# pcmanfm: PCManFM is a free file manager application and the standard file manager of LXDE.
# xarchiver: Xarchiver is a GTK+2 only frontend to 7z,zip,rar,tar,bzip2, gzip,arj, lha, rpm 
#   and deb (open and extract only). Xarchiver allows you to create,add, extract and delete 
#   files in the above formats.
# libgomp1: The GNU compiler collection OpenMP runtime library
#   This is the OpenMP runtime library needed by OpenMP enabled programs that were built with 
#   the -fopenmp compiler option and by programs that were auto-parallelized via the 
#   -ftree-parallelize-loops compiler option.
# xvfb: Xvfb is an X server that can run on machines with no display hardware and no physical 
#   input devices. It emulates a dumb framebuffer using virtual memory.
#   Xvfb can be for doing batch processing with Xvfb as a background rendering engine, 
#   as an aid to porting the X server to a new platform, and providing an unobtrusive way to
#   run applications that don’t really need an X server but insist on having one anyway.
RUN apt -y install \
    dbus-x11 \
    emacs-nox \
    firefox \
    git \
    libegl1-mesa \
    libegl1-mesa:i386 \
    libglu1-mesa \
    libglu1-mesa:i386 \
    libnss3 \
    libpulse-mainloop-glib0 \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-randr0 \
    libxcb-render0 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libxt6 \
    libxt6:i386 \
    libxtst6 \
    libxtst6:i386 \
    libxv1 \
    libxv1:i386 \
    mate-terminal \
    openbox-menu \
    python \
    tint2 \
    vim-common \
    wget \
    x11-utils \
    x11-xkb-utils \
    x11-xserver-utils \
    xauth \
    pcmanfm \
    xarchiver \
    libgomp1 \
    xvfb

# install turbovnc and virtualgl
RUN wget -O turbovnc.deb "https://sourceforge.net/projects/turbovnc/files/2.2.90%20(3.0%20beta1)/turbovnc_2.2.90_amd64.deb/download" \
 && wget -O virtualgl.deb https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl_3.0_amd64.deb/download \
 && wget -O virtualgl32.deb https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl32_3.0_amd64.deb/download \
 && dpkg -i turbovnc*.deb virtualgl*.deb \
 && rm *.deb \
 && apt install -f

# On all strings that match the regex between the first and second / replace it by the regex
#   between the second and third /
# Configure window manager as openbox-session
# Set up noVNC path
RUN sed -i 's/^# \$wm =.*/\$wm = \"openbox-session\";/g' /etc/turbovncserver.conf \
 && sed -i 's/^# \$noVNC =.*/\$noVNC = \"\/home\/docker\/noVNC\";/g' /etc/turbovncserver.conf
 
 # Clone noVNC repository
 # Move to its final location 
 # Setup ownership of all noVNC directory files (including it) to user='docker', group='docker'
RUN git clone https://github.com/novnc/noVNC.git \
 && mv noVNC /home/docker/ \
 && chown -R 1000:1000 /home/docker/noVNC

# Set up novnc password
RUN mkdir /home/docker/.vnc \
 && touch /home/docker/.vnc/passwd \
 && chmod 600 /home/docker/.vnc/passwd \
 && chown -R 1000:1000 /home/docker/.vnc

# Create a file named "autostart" with "tint2 &" as text
# These things are run when an Openbox X Session is started.
RUN echo 'tint2 &' >>/etc/xdg/openbox/autostart

# Download, decompress, move slicer to its final locations and setup the correct ownership
RUN wget https://download.slicer.org/bitstream/61a70469342a877cb3e5fe33 -O slicer.tar.gz \
 && tar xzf slicer.tar.gz -C /home/docker/ \
 && mv /home/docker/Sli* /home/docker/slicer \
 && rm slicer.tar.gz \
 && chown -R 1000:1000 /home/docker/slicer

# clone httpWebServer branch from SlicerWeb repository
# Move it to its final location and set up its ownership
# httpWebServer allows POST request with code execution requirements
RUN git clone --branch httpWebServer https://github.com/mauigna06/SlicerWeb \
 && mv SlicerWeb /home/docker/slicer/ \
 && chown -R 1000:1000 /home/docker/slicer/SlicerWeb

# Clean cache and temps
RUN apt clean \
 && rm -rf /etc/ld.so.cache \
 && rm -rf /var/cache/ldconfig/* \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && rm -rf /var/tmp/*


# save line where "launcher_item_app" is found for the first time
RUN LNUM=$(sed -n '/launcher_item_app/=' /etc/tint2/panel.tint2rc | head -1)
# replace line LNUM with the given string on the given file
RUN sed -i "${LNUM}ilauncher_item_app = /home/docker/slicer/slicer.desktop" /etc/tint2/panel.tint2rc

COPY etc/tint2/tint2rc.slicermorph /home/docker/.config/tint2/tintrc
COPY slicer/* /home/docker/slicer/

COPY addExtensionsModules.py /home/docker/slicer/

COPY .slicerrc.py /home/docker/slicer/
RUN chown -R 1000:1000 /home/docker/slicer/.slicerrc.py

RUN xvfb-run --auto-servernum /home/docker/slicer/Slicer --python-script "/home/docker/slicer/addExtensionsModules.py" --no-splash --no-main-window

RUN rm -rf /home/docker/.vnc && \
    mkdir /home/docker/.vnc && \
    echo 12345678 | /opt/TurboVNC/bin/vncpasswd -f > /home/docker/.vnc/passwd && \
    chmod ugo=rw /home/docker/.vnc/passwd

COPY run.sh /home/docker
RUN chmod +rwx /home/docker/run.sh
ENTRYPOINT ["/home/docker/run.sh"]

WORKDIR /home/docker
USER docker
