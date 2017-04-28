FROM nginx:stable-alpine
MAINTAINER Verdigris Technologies "infrastructure@verdigris.co"

###############################################################################
# Following section builds Ruby 2.4 and references the official Ruby
# Dockerfile.
#
# See https://github.com/docker-library/ruby/blob/master/2.4/alpine/Dockerfile
# for more information.
###############################################################################

# Skip installing Gem documentation
RUN mkdir -p /usr/local/etc && \
  { \
    echo 'install: --no-document'; \
    echo 'update: --no-document'; \
  } >> /usr/local/etc/gemrc

ENV RUBY_MAJOR 2.4
ENV RUBY_VERSION 2.4.1
ENV RUBY_DOWNLOAD_SHA256 a330e10d5cb5e53b3a0078326c5731888bb55e32c4abfeb27d9e7f8e5d000250
ENV RUBYGEMS_VERSION 2.6.11
ENV GEM_HOME /usr/local/bundle
ENV BUNDLER_VERSION 1.14.6
ENV BUNDLE_PATH="$GEM_HOME"
ENV BUNDLE_BIN="$GEM_HOME/bin"
ENV BUNDLE_SILENCE_ROOT_WARNING=1
ENV BUNDLE_APP_CONFIG="$GEM_HOME"
ENV NPM_CONFIG_LOGLEVEL info
ENV NODE_VERSION 6.10.2
ENV NODE_DOWNLOAD_SHA256 9b897dd6604d50ae5fff25fd14b1c4035462d0598735799e0cfb4f17cb6e0d19
ENV PATH $BUNDLE_BIN:$PATH

RUN set -ex && \
  apk add --no-cache --virtual .builddeps \
    autoconf \
    binutils-gold \
    bison \
    bzip2 \
    bzip2-dev \
    ca-certificates \
    coreutils \
    g++ \
    gcc \
    gdbm-dev \
    glib-dev \
    gnupg \
    libc-dev \
    libffi-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    make \
    ncurses-dev \
    openssl \
    openssl-dev \
    procps \
    readline-dev \
    ruby \
    tar \
    yaml-dev \
    zlib-dev \
    xz && \
  wget -O ruby.tar.gz "https://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.gz" && \
  echo "$RUBY_DOWNLOAD_SHA256 *ruby.tar.gz" | sha256sum -c - && \
  mkdir -p /usr/src/ruby && \
  tar -xzf ruby.tar.gz -C /usr/src/ruby --strip-components=1 && \
  rm ruby.tar.gz && \
  cd /usr/src/ruby && \
  mkdir -p /usr/lib/ruby && \
  cp -R include /usr/lib/ruby && \
  { \
    echo '#define ENABLE_PATH_CHECK 0'; \
    echo; \
    cat file.c; \
  } > file.c.new && \
  mv file.c.new file.c && \
  \
  autoconf && \
  ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
  ./configure --disable-install-doc --enable-shared && \
  make -j"$(getconf _NPROCESSORS_ONLN)" && \
  make install && \
  runDeps="$( \
    scanelf --needed --nobanner --recursive /usr/local | \
    awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' | \
    sort -u | \
    xargs -r apk info --installed | \
    sort -u \
  )" && \
  apk add --virtual .ruby-rundeps $runDeps \
    bzip2 \
    ca-certificates \
    libffi-dev \
    openssl-dev \
    yaml-dev \
    procps \
    zlib-dev && \
  gem update --system "$RUBYGEMS_VERSION" && \
  gem install bundler --version "$BUNDLER_VERSION" && \
  mkdir -p "$GEM_HOME" "$BUNDLE_BIN" && \
  chmod 777 "$GEM_HOME" "$BUNDLE_BIN" && \
  \
###############################################################################
# Following section builds Node 6.10 and references official Node.js
# Dockerfile.
#
# See https://github.com/nodejs/docker-node/blob/master/6.10/alpine/Dockerfile
# for more information.
###############################################################################
  addgroup -g 1000 node && \
  adduser -u 1000 -G node -s /bin/sh -D node && \
  apk add --no-cache libstdc++ && \
  \
  cd / && \
  wget -O node.tar.gz "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION.tar.gz" && \
  echo "$NODE_DOWNLOAD_SHA256 *node.tar.gz" | sha256sum -c - && \
  mkdir -p /usr/src/node && \
  tar -xzf node.tar.gz -C /usr/src/node --strip-components=1 && \
  rm node.tar.gz && \
  cd /usr/src/node && \
  \
  ./configure && \
  make -j"$(getconf _NPROCESSORS_ONLN)" && \
  make install && \
  \
###############################################################################
# Install Middleman
###############################################################################
  gem install middleman therubyracer --no-rdoc --no-ri && \
  \
###############################################################################
# Clean up installation files
###############################################################################
  apk del .builddeps && \
  cd / && \
  rm -r /usr/src/ruby && \
  rm -r /usr/src/node

ADD nginx.conf /etc/nginx/nginx.conf
RUN mkdir /srv/www
