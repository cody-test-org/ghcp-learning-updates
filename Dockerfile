FROM nginx:alpine

LABEL maintainer="cody-test-org" \
      description="GHCP Learning & Reference Hub slide deck"

# Copy static site files
COPY site/hackathon.html /usr/share/nginx/html/index.html
COPY site/hackathon.html /usr/share/nginx/html/hackathon.html
COPY site/agenda.json /usr/share/nginx/html/agenda.json

# Copy custom nginx config for SPA-friendly serving
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
