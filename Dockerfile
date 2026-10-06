FROM lscr.io/linuxserver/webtop:ubuntu-xfce
ENV TITLE="Wanda Trading PC"
USER root
RUN apt-get update && apt-get install -y wine64 wget && rm -rf /var/lib/apt/lists/*
CMD bash -c "export CUSTOM_PORT=${PORT:-3000} && /init"
