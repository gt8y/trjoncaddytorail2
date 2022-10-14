FROM alpine:edge
#  this uuid doesnot work any more date 0403
ARG AUUID="cace7df7-7b05-47b6-8b3a-e8faf62322e5"
ARG CADDYIndexPage="https://github.com/PavelDoGreat/WebGL-Fluid-Simulation/archive/master.zip"
ARG ParameterSSENCYPT="chacha20-ietf-poly1305"
ARG PORT=80  #原 80 ，221009 改部署mogniss,,

ADD etc/Caddyfile /tmp/Caddyfile
ADD etc/app.json /tmp/app.json
ADD start.sh /start.sh

RUN apk update && \
    apk add --no-cache ca-certificates caddy tor wget && \
    wget -O /tmp/trojan-go/trojan-go.zip https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64.zip
    unzip /tmp/trojan-go/trojan-go.zip -d /tmp/trojan-go
    install -m 0755 /tmp/trojan-go/trojan-go /usr/local/bin/trojan-go
    chmod +x /trojan-go && \
    rm -rf /var/cache/apk/* && \

    mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt && \
    wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/ && \
    cat /tmp/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile && \
    cat /tmp/app.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/app.json

ADD Trojan.sh /Trojan.sh

RUN chmod 0755 /Trojan.sh

CMD /Trojan.sh
RUN chmod +x /start.sh
CMD /start.sh
