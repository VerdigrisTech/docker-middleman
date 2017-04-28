# docker-middleman

[![Build Status](https://img.shields.io/circleci/token/f41a8ea8d8fe8a47d6d409f60f53230c8c21ff67/project/VerdigrisTech/docker-middleman.svg)](https://circleci.com/gh/VerdigrisTech/docker-middleman)
[![Docker Stars](https://img.shields.io/docker/stars/verdigristech/middleman.svg)](https://hub.docker.com/r/verdigristech/middleman/)
[![Docker Pulls](https://img.shields.io/docker/pulls/verdigristech/middleman.svg)](https://hub.docker.com/r/verdigristech/middleman/)
[![license](https://img.shields.io/github/license/VerdigrisTech/docker-middleman.svg)](https://github.com/VerdigrisTech/docker-middleman/blob/master/LICENSE)

Docker image for running Middleman static sites behind Nginx.

## Usage

```Dockerfile
FROM verdigristech/middleman

ADD . /srv/www
RUN middleman build

CMD nginx
```
