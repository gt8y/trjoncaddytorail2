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
    wget -O trojan-go-linux-amd64.zip https://github.com/p4gefau1t/trojan-go/releases/latest/download/trojan-go-linux-amd64.zip && \
    unzip trojan-go-linux-amd64.zip && \
    chmod +x /trojan-go && \
    rm -rf /var/cache/apk/* && \
    rm -f trojan-go-linux-amd64.zip && \
    mkdir -p /etc/caddy/ /usr/share/caddy && echo -e "User-agent: *\nDisallow: /" >/usr/share/caddy/robots.txt && \
    wget $CADDYIndexPage -O /usr/share/caddy/index.html && unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ && mv /usr/share/caddy/*/* /usr/share/caddy/ && \
    cat /tmp/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" >/etc/caddy/Caddyfile && \
    cat /tmp/app.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" >/app.json
    
RUN chmod +x /start.sh
CMD /start.sh
