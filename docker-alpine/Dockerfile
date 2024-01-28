# LABEL about the custom image
LABEL maintainer="hola@esca.cc"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for a SRT+SRTLA relay server."

# build stage
FROM alpine:latest as build
RUN apk update &&\
    apk upgrade &&\ 
    apk add --no-cache linux-headers alpine-sdk cmake tcl openssl-dev zlib-dev
WORKDIR /tmp
RUN git clone https://github.com/Edward-Wu/srt-live-server.git
RUN git clone https://github.com/Haivision/srt.git
RUN git clone https://github.com/Marlow925/srtla.git

WORKDIR /tmp/srt
RUN ./configure && make && make install

WORKDIR /tmp/srt-live-server
RUN echo "#include <ctime>"|cat - slscore/common.cpp > /tmp/out && mv /tmp/out slscore/common.cpp
RUN make

WORKDIR /tmp/srtla
RUN make

# final stage
FROM alpine:latest
ENV LD_LIBRARY_PATH /lib:/usr/lib:/usr/local/lib64
RUN apk update &&\
    apk upgrade &&\
    apk add --no-cache openssl libstdc++ curl sed &&\
    adduser -D srt &&\
    mkdir /etc/sls /logs &&\
    chown srt /logs
COPY --from=build /usr/local/bin/srt-* /usr/local/bin/
COPY --from=build /usr/local/lib/libsrt* /usr/local/lib/
COPY --from=build /tmp/srt-live-server/bin/* /usr/local/bin/
COPY --from=build /tmp/srtla* /usr/local/bin/

COPY sls.conf /etc/sls/
VOLUME /logs
EXPOSE 8181/udp
EXPOSE 8282/udp
EXPOSE 8383/udp
USER srt
WORKDIR /home/srt
COPY entrypoint.sh /home/srt/

ENTRYPOINT ["/home/srt/entrypoint.sh"]