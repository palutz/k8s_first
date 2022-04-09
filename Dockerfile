FROM nginx
LABEL maintainer="palutz<acme@acme.org>"

COPY ./website /website
COPY ./website.conf /etc/nginx/nginx.conf

