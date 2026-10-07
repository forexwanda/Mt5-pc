FROM lscr.io/linuxserver/webtop:ubuntu-xfce

ENV TITLE="Wanda Trading PC" \
    WINEARCH=win64 \
    WINEPREFIX=/config/.wine \
    WINEDLLOVERRIDES="mscoree,mshtml=" \
    WINEDEBUG=-all

USER root

# WineHQ stable (much better MT5 compatibility than Ubuntu's wine64 package)
RUN dpkg --add-architecture i386 \
 && apt-get update \
 && apt-get install -y --no-install-recommends wget gnupg2 ca-certificates cabextract winbind xdotool \
 && mkdir -pm755 /etc/apt/keyrings \
 && wget -qO /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key \
 && . /etc/os-release \
 && wget -qNP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/${VERSION_CODENAME}/winehq-${VERSION_CODENAME}.sources \
 && apt-get update \
 && apt-get install -y --install-recommends winehq-stable \
 && rm -rf /var/lib/apt/lists/*

# First-run installer + launcher (runs in /config, which is your persistent volume)
RUN cat > /usr/local/bin/mt5-launch.sh <<'EOF'
#!/bin/bash
export WINEARCH=win64 WINEPREFIX=/config/.wine WINEDLLOVERRIDES="mscoree,mshtml=" WINEDEBUG=-all
MT5_EXE="$WINEPREFIX/drive_c/Program Files/MetaTrader 5/terminal64.exe"

if [ ! -f "$MT5_EXE" ]; then
  wineboot -u
  wget -O /tmp/mt5setup.exe "https://download.mql5.com/cdn/web/metaquotes.software.corp/mt5/mt5setup.exe"
  wine /tmp/mt5setup.exe /auto
  rm -f /tmp/mt5setup.exe
  sleep 10
fi

# Keep MT5 alive; restart if it closes or crashes
while true; do
  wine "$MT5_EXE" /portable
  sleep 5
done
EOF
RUN chmod +x /usr/local/bin/mt5-launch.sh

# Autostart MT5 when the desktop loads
RUN mkdir -p /etc/xdg/autostart \
 && printf '[Desktop Entry]\nType=Application\nName=MetaTrader 5\nExec=/usr/local/bin/mt5-launch.sh\n' > /etc/xdg/autostart/mt5.desktop

VOLUME /config

CMD bash -c "export CUSTOM_PORT=${PORT:-3000} && /init"
