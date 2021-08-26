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

COPY --chown=user ./configs/npm/.npmrc ${HOME}/.npmrc

ARG NPM_VERSION
RUN npm install -g npm@${NPM_VERSION}

WORKDIR ${WORKDIR}