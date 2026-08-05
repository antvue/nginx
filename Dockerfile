FROM openresty/openresty:alpine-fat AS openresty-stream-realip-builder

ARG RESTY_J="1"
ARG RESTY_CONFIG_OPTIONS="\
  --with-compat \
  --without-http_rds_json_module \
  --without-http_rds_csv_module \
  --without-lua_rds_parser \
  --without-mail_pop3_module \
  --without-mail_imap_module \
  --without-mail_smtp_module \
  --with-http_addition_module \
  --with-http_auth_request_module \
  --with-http_dav_module \
  --with-http_flv_module \
  --with-http_geoip_module=dynamic \
  --with-http_gunzip_module \
  --with-http_gzip_static_module \
  --with-http_image_filter_module=dynamic \
  --with-http_mp4_module \
  --with-http_random_index_module \
  --with-http_realip_module \
  --with-http_secure_link_module \
  --with-http_slice_module \
  --with-http_ssl_module \
  --with-http_stub_status_module \
  --with-http_sub_module \
  --with-http_v2_module \
  --with-http_v3_module \
  --with-http_xslt_module=dynamic \
  --with-ipv6 \
  --with-mail \
  --with-mail_ssl_module \
  --with-md5-asm \
  --with-sha1-asm \
  --with-stream \
  --with-stream_ssl_module \
  --with-stream_ssl_preread_module \
  --with-threads \
  "
ARG RESTY_CONFIG_OPTIONS_MORE="--with-stream_realip_module"
ARG RESTY_CONFIG_DEPS="--with-pcre \
  --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre2/include -I/usr/local/openresty/openssl3/include' \
  --with-ld-opt='-L/usr/local/openresty/pcre2/lib -L/usr/local/openresty/openssl3/lib -Wl,-rpath,/usr/local/openresty/pcre2/lib:/usr/local/openresty/openssl3/lib' \
  "
ARG RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"
ARG RESTY_PCRE_OPTIONS="--with-pcre-jit"

RUN apk add --no-cache --virtual .openresty-build-deps \
    build-base \
    binutils \
    coreutils \
    curl \
    gd-dev \
    geoip-dev \
    libxslt-dev \
    linux-headers \
    make \
    perl-dev \
    readline-dev \
    zlib-dev && \
  resty_version="$(openresty -v 2>&1 | sed -n 's/^nginx version: openresty\///p')" && \
  test -n "$resty_version" && \
  cd /tmp && \
  curl -fSL "https://openresty.org/download/openresty-${resty_version}.tar.gz" \
    -o "openresty-${resty_version}.tar.gz" && \
  tar xzf "openresty-${resty_version}.tar.gz" && \
  cd "openresty-${resty_version}" && \
  eval ./configure -j"${RESTY_J}" \
    ${RESTY_CONFIG_DEPS} \
    ${RESTY_CONFIG_OPTIONS} \
    ${RESTY_CONFIG_OPTIONS_MORE} \
    ${RESTY_LUAJIT_OPTIONS} \
    ${RESTY_PCRE_OPTIONS} && \
  make -j"${RESTY_J}" && \
  make -j"${RESTY_J}" install && \
  openresty -V 2>&1 | grep -q -- '--with-stream_realip_module'

FROM openresty/openresty:alpine-fat

COPY --from=openresty-stream-realip-builder \
  /usr/local/openresty/nginx/sbin/nginx \
  /usr/local/openresty/nginx/sbin/nginx

LABEL maintainer="hupeng.net@hotmail.com"

EXPOSE 80 443

VOLUME ["/usr/local/openresty/nginx/conf/conf.d", "/usr/local/openresty/nginx/logs"]

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

ADD fs/ /

RUN ln -sf /dev/stdout /usr/local/openresty/nginx/logs/access.log && \
  ln -sf /dev/stderr /usr/local/openresty/nginx/logs/error.log

RUN apk update && \
  apk add --no-cache vim bind-tools zip curl wget && \
  ln -s  /usr/bin/cutlog.sh /etc/periodic/monthly/cutlog

CMD ["openresty", "-g", "daemon off;"]
