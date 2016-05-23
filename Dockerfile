# Instructions:
#    Build container:
#    $ docker build --rm --no-cache -t nginx-http2 .
#    Bootstrap the container:
#    $ docker run -d --name nginx-http2 -p 443:443 \
#      -v "$PWD"/public:/var/www/web nginx-http2
#    Run the container:
#    $ docker start nginx-http2
#    Attach into the container:
#    $ docker exec -it nginx-http2 bash
#   Stop container:
#     $ docker stop nginx-http2
#   Remove container:
#     $ docker rm -f nginx-http2
#
FROM alpine:latest

ENV NGINX_VERSION 1.9.15

RUN addgroup -S nginx && adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx

RUN echo "@testing http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories && \
    apk --update add wget \
        supervisor \
        curl \
        git \
        grep \
        gmp-dev \
        libmcrypt-dev \
        freetype-dev \
        libxpm-dev \
        libwebp-dev \
        libjpeg-turbo-dev \
        libjpeg \
        bzip2-dev \
        openssl-dev \
        krb5-dev \
        libxml2-dev \
        pcre-dev \
        zlib-dev \
        build-base \
        php7@testing php7-xml@testing php7-xsl@testing php7-pdo_mysql@testing \
        php7-mcrypt@testing php7-curl@testing php7-json@testing php7-fpm@testing \
        php7-phar@testing php7-openssl@testing \
        php7-mysqlnd@testing php7-ctype@testing \
    && mkdir -p /tmp/src \
    && cd /tmp/src \
    && wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
    && tar -zxvf nginx-${NGINX_VERSION}.tar.gz \
    && cd /tmp/src/nginx-${NGINX_VERSION} \
    && ./configure \
        --sbin-path=/usr/sbin/nginx \
        --with-http_ssl_module \
        --with-http_ssl_module \
        --with-http_v2_module \
        --with-http_realip_module \
        --with-http_stub_status_module \
        --with-threads \
        --with-http_gzip_static_module \
        --http-log-path=/var/log/nginx/access.log \
        --error-log-path=/var/log/nginx/error.log \
    && make \
    && make install \
    && apk del build-base \
    && rm -rf /tmp/src \
    && rm -rf /var/cache/apk/*

RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

RUN \
rm -rf /usr/local/nginx/*.d /usr/local/nginx/*_params && \
mkdir -p /usr/local/nginx/ssl && \
openssl genrsa -out /usr/local/nginx/ssl/dummy.key 2048 && \
openssl req -new -key /usr/local/nginx/ssl/dummy.key -out /usr/local/nginx/ssl/dummy.csr -subj "/C=GB/L=London/O=Company Ltd/CN=docker" && \
openssl x509 -req -days 3650 -in /usr/local/nginx/ssl/dummy.csr -signkey /usr/local/nginx/ssl/dummy.key -out /usr/local/nginx/ssl/dummy.crt

RUN rm -rf /etc/php7/php-fpm.d

COPY php.ini         /etc/php7/php.ini
COPY php-fpm.conf    /etc/php7/php-fpm.conf

COPY nginx.conf /usr/local/nginx/conf/nginx.conf
COPY nginx.vh.default.conf /usr/local/nginx/conf.d/default.conf
COPY supervisord.conf /etc/supervisord.conf

VOLUME [ "/var/www/web" ]

EXPOSE 443

ENTRYPOINT [ "supervisord" ]
CMD [ "-c", "/etc/supervisord.conf" ]
