ARG NODE_VERSION
ARG DEBIAN_VERSION
FROM node:${NODE_VERSION}-${DEBIAN_VERSION} AS typescript-stack-image

ENV USER user
ENV WORKDIR /usr/user/workdir
ENV HOME /usr/user
ENV BIN_PATH /usr/bin
ENV USER_NPM ${HOME}/.npm
ENV PATH ${USER_NPM}/bin:$PATH

RUN useradd -d ${HOME} -m -s /bin/bash -r ${USER}

USER ${USER}

RUN mkdir ${WORKDIR}
RUN mkdir ${USER_NPM}

ARG NPM_VERSION
RUN npm config set prefix ${USER_NPM}
RUN npm install -g npm@${NPM_VERSION}

WORKDIR ${WORKDIR}