FROM node:12.13.1-alpine

ENV APP_UID=9999
ENV APP_GID=9999

RUN apk --no-cache add shadow \
   && groupmod -g $APP_GID node \
   && usermod -u $APP_UID -g $APP_GID node \
   && rm -rf /var/cache/apk/*

COPY nginx.conf.template /etc/nginx/nginx.conf.template

USER node

CMD envsubst '$PORT,$WF_MANAGEMENT_HOST,$WF_SEARCH_HOST,$WF_UI_HOST,$WF_DOCS_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'
