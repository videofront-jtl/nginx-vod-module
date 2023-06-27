# https://github.com/kaltura/nginx-vod-module#compilation
FROM ubuntu:latest

RUN apt-get update
RUN apt-get install -y \
wget \
git \
build-essential \
libpcre3-dev \
zlib1g-dev \
libssl-dev \
ffmpeg \
libxml2-dev

RUN mkdir /nginx /nginx-vod-module

ARG NGINX_VERSION=1.24.0
ARG VOD_MODULE_VERSION=1.31

RUN wget -c https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz -O - | tar -xz -C /nginx --strip-components 1
RUN wget -c https://github.com/kaltura/nginx-vod-module/archive/refs/tags/${VOD_MODULE_VERSION}.tar.gz -O - | tar -xz -C /nginx-vod-module --strip-components 1

WORKDIR /nginx

RUN ./configure \
	--prefix=/usr/local/nginx \
	--add-module=../nginx-vod-module \
	--with-http_ssl_module \
	--with-http_v2_module \
	--with-file-aio \
	--with-threads \
	--with-stream \
	--with-http_sub_module \
	--with-cc-opt="-O3 -mpopcnt"

RUN make
RUN make install

# RUN rm -rf /usr/local/nginx/html /usr/local/nginx/conf/*.default

COPY ./conf/ /usr/local/nginx/conf/
COPY ./favicon.ico /usr/local/nginx/html/

ENTRYPOINT ["/usr/local/nginx/sbin/nginx"]
CMD ["-g", "daemon off;"]