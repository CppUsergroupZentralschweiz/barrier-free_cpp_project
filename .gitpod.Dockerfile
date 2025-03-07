FROM bbvch/qt:5.14.2 as qt_builder

FROM gitpod/workspace-full-vnc:commit-0d86f18fcb06832838d2cb77636d2c1a6a7dbe6c

# More information: https://www.gitpod.io/docs/config-docker/

LABEL maintainer="Michel Estermann <estermann.michel@gmail.com>"

USER root

#install qt
COPY --from=qt_builder /usr/local/Qt /usr/local/Qt/5.14.2
ENV Qt5_DIR=/usr/local/Qt/5.14.2
# Install some fonts
RUN wget https://altushost-swe.dl.sourceforge.net/project/dejavu/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2 \
&& tar -xf dejavu-fonts-ttf-2.37.tar.bz2 && rm dejavu-fonts-ttf-2.37.tar.bz2 \
 && mv dejavu-fonts-ttf-2.37/ttf /usr/local/Qt/5.14.2/lib/fonts

#install qt dependencies
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
 && apt-get update
RUN apt-get -qq build-dep -y qt5-default
RUN apt-get -qq install -y --no-install-recommends libxcb-xinerama0-dev \
 && apt-get -qq install -y --no-install-recommends '^libxcb.*-dev' libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev libxkbcommon-dev libxkbcommon-x11-dev \
 && apt-get -qq install -y --no-install-recommends perl

# lcov and doxygen
RUN apt-get -qq install -y --no-install-recommends lcov doxygen graphviz

RUN apt-get -qq install -y --no-install-recommends ninja-build

RUN apt-get clean \
 && rm -rf /var/lib/apt/lists/*

USER gitpod

# conan
RUN pip3 install conan==1.34.0
RUN conan profile new default --detect

# TODO 
# 1. install conan
# 2. install clang-11. because gitpod/workspace-full-vnc has clang-13 installes which is not supported by conan yet.
# 3. install cmake-format
# 4. install newest cmake release (3.20.1)
# 5. install pre-commit
