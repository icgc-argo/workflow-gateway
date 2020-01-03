FROM nginx
COPY nginx.conf.template /etc/nginx/nginx.conf.template
CMD envsubst '$PORT,$WF_MANAGEMENT_HOST,$WF_SEARCH_HOST,$WF_UI_HOST,$WF_DOCS_HOST' < /etc/nginx/nginx.conf.template > /etc/nginx/nginx.conf && exec nginx -g 'daemon off;'