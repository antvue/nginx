FROM openresty/openresty:alpine-fat

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

