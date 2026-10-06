FROM lscr.io/linuxserver/webtop:ubuntu-xfce
USER root
RUN apt-get update && apt-get install -y socat && rm -rf /var/lib/apt/lists/*
ENV CUSTOM_PORT=3000
EXPOSE 3000
CMD bash -c "socat TCP-LISTEN:${PORT:-10000},reuseaddr,fork TCP:localhost:3000 & /init"
