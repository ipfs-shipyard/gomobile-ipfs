FROM golang:1.12.5

# replace shell with bash so we can source files
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# install dependencies
RUN apt-get update \
  && apt-get install -y curl \
  && apt-get install -y mingw-w64 \
  && apt-get install -y zip \
  && curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh \
  && bash nodesource_setup.sh \
  && apt-get install nodejs \
  && apt-get -y autoclean

# add global node modules to path
ENV PATH="/usr/lib/node_modules/yarn/bin:${PATH}"

# install yarn
RUN npm install -g yarn
