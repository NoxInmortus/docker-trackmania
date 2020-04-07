#################################
## Dockerfile Trackmania       ##
## Imperium                    ##
#################################
FROM alpine:3.11
LABEL maintainer='NoxInmortus (IMPERIUM)'

ENV DEDICATED_URL="http://files.v04.maniaplanet.com/server/ManiaplanetServer_Latest.zip" \
    PROJECT_DIR="/home/container" \
    TEMPLATE_DIR="/home/container-config" \
    LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/lib/:/lib/" \
    GLIBC_VERSION="2.31-r0"
WORKDIR ${PROJECT_DIR}

COPY entrypoint.sh files/ /

RUN apk update \
    && apk add --no-cache unzip wget ca-certificates dos2unix \
    && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
    && wget -q https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk \
    && apk add --no-cache glibc-${GLIBC_VERSION}.apk libstdc++ musl libuuid \
    && wget ${DEDICATED_URL} -qO /tmp/dedicated.zip \
    && mkdir -pv ${PROJECT_DIR}/GameData ${TEMPLATE_DIR} \
    && unzip -quo /tmp/dedicated.zip -d ${PROJECT_DIR} \
    && mv -v /matchsettings.xml ${TEMPLATE_DIR}/matchsettings.xml \
    && mv -v /stadium_map.Map.gbx ${TEMPLATE_DIR}/stadium_map.Map.gbx \
    && mv -v /entrypoint.sh ${PROJECT_DIR}/entrypoint.sh \
    && dos2unix ${PROJECT_DIR}/entrypoint.sh \
    && chmod +x -v ${PROJECT_DIR}/ManiaPlanetServer ${PROJECT_DIR}/entrypoint.sh \
    && apk del unzip libstdc++ musl dos2unix \
    && rm -rfv glibc-${GLIBC_VERSION}.apk *.bat *.exe *.html RemoteControlExamples \
    && rm -rfv /tmp/* /var/tmp/* /var/cache/apk/* \
    ;

VOLUME ${PROJECT_DIR}
EXPOSE 2350 2350/udp 3450 3450/udp 5000

CMD [ "./entrypoint.sh" ]