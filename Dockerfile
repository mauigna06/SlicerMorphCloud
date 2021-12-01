FROM nvidia/opengl:1.0-glvnd-runtime-ubuntu20.04

ENV NVIDIA_DRIVER_CAPABILITIES ${NVIDIA_DRIVER_CAPABILITIES},graphics,compat32

RUN groupadd -g 1000 docker \
 && useradd -u 1000 -g 1000 -m docker -s /bin/bash \
 && usermod -a -G docker docker

COPY etc/tint2 /etc/tint2
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

RUN apt -y update \
 && apt -y upgrade \
 && ln -fs /usr/share/zoneinfo/America/Los_Angeles /etc/localtime \
 && apt -y install \
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
    xvfb \
 && wget -O turbovnc.deb https://s3.amazonaws.com/turbovnc-pr/dev/linux/turbovnc_2.2.80_amd64.deb \
 && wget -O virtualgl.deb https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl_3.0_amd64.deb/download \
 && wget -O virtualgl32.deb https://sourceforge.net/projects/virtualgl/files/3.0/virtualgl32_3.0_amd64.deb/download \
 && dpkg -i turbovnc*.deb virtualgl*.deb \
 && rm *.deb \
 && apt install -f \
 && sed -i 's/^# \$wm =.*/\$wm = \"openbox-session\";/g' /etc/turbovncserver.conf \
 && sed -i 's/^# \$noVNC =.*/\$noVNC = \"\/home\/docker\/noVNC\";/g' /etc/turbovncserver.conf \
 && git clone https://github.com/novnc/noVNC.git \
 && mv noVNC /home/docker/ \
 && chown -R 1000:1000 /home/docker/noVNC \
 && mkdir /home/docker/.vnc \
 && touch /home/docker/.vnc/passwd \
 && chmod 600 /home/docker/.vnc/passwd \
 && chown -R 1000:1000 /home/docker/.vnc \
 && echo 'tint2 &' >>/etc/xdg/openbox/autostart \
 && wget https://download.slicer.org/bitstream/6191eb9d342a877cb3dec547 -O slicer.tar.gz \
 && tar xzf slicer.tar.gz -C /home/docker/ \
 && mv /home/docker/Sli* /home/docker/slicer \
 && rm slicer.tar.gz \
 && chown -R 1000:1000 /home/docker/slicer \
 && git clone --branch httpWebServer https://github.com/mauigna06/SlicerWeb \
 && mv SlicerWeb /home/docker/slicer/ \
 && chown -R 1000:1000 /home/docker/slicer/SlicerWeb \
 && apt clean \
 && rm -rf /etc/ld.so.cache \
 && rm -rf /var/cache/ldconfig/* \
 && rm -rf /var/lib/apt/lists/* \
 && rm -rf /tmp/* \
 && rm -rf /var/tmp/*

RUN LNUM=$(sed -n '/launcher_item_app/=' /etc/tint2/panel.tint2rc | head -1) && \
  sed -i "${LNUM}ilauncher_item_app = /home/docker/slicer/slicer.desktop" /etc/tint2/panel.tint2rc
COPY etc/tint2/tint2rc.slicermorph /home/docker/.config/tint2/tintrc
COPY slicer/* /home/docker/slicer/

COPY addExtensionsModules.py /home/docker/slicer/

COPY .slicerrc.py /home/docker/slicer/
RUN chown -R 1000:1000 /home/docker/slicer/.slicerrc.py

RUN xvfb-run --auto-servernum /home/docker/slicer/Slicer --python-script "/home/docker/slicer/addExtensionsModules.py" --no-splash --no-main-window

WORKDIR /home/docker
USER docker
