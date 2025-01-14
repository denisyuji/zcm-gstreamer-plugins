FROM ubuntu:20.04

ENV DEBIAN_FRONTEND "noninteractive"

RUN echo "Set disable_coredump false" > /etc/sudo.conf && \
    apt-get update && \
    apt-get install --no-install-recommends -yq \
        sudo ca-certificates apt-utils make build-essential rsync mlocate git && \
    ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime

RUN apt-get install -yq \
        libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        gstreamer1.0-plugins-base gstreamer1.0-tools \
        gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly

RUN git clone https://github.com/ZeroCM/zcm.git
RUN cd zcm && ./scripts/install-deps.sh && \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 1
RUN cd zcm && \
    ./waf configure --hash-typename=true --hash-member-names=true --use-zmq --use-elf --use-ipc && \
    ./waf build && \
    sudo ./waf install

ENV LD_LIBRARY_PATH /usr/local/lib

COPY ./ zcm-gstreamer-plugins
RUN cd zcm-gstreamer-plugins && make

ENV GST_PLUGIN_PATH /zcm-gstreamer-plugins
ENV LD_LIBRARY_PATH /usr/local/lib:/zcm-gstreamer-plugins/build/zcmtypes
ENV ZCM_DEFAULT_URL ipc

WORKDIR /root

CMD (zcm-logplayer /log/zcmlog.log &) && \
    (sleep 1 && \
     echo "Launched pipeline press enter to launch zcm-spy-lite" && \
     echo "Press ctrl+C when ready to exit" && \
     read -p "" IGNORE) && \
     gst-launch-1.0 zcmimagesrc blocksize=44728320 url=ipc channel=IMAGE ! \
     bayer2rgb ! videoconvert ! jpegenc ! multifilesink location="./output/frame%d.jpg"
