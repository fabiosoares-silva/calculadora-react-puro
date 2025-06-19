FROM node:18-alpine AS react_build

WORKDIR /app

COPY package.json package-lock.json ./

RUN npm install

COPY . .

RUN npm run build

FROM httpd:2.4-alpine

RUN mkdir -p /usr/local/apache2/conf/custom/

COPY httpd.conf /usr/local/apache2/conf/custom/react-app.conf

RUN sed -i -e '/^#Include conf\/extra\/httpd-mpm.conf/iLoadModule rewrite_module modules/mod_rewrite.so' \
         -e '/^#Include conf\/extra\/httpd-mpm.conf/iInclude conf/custom/react-app.conf' \
         -e '/^#Include conf\/extra\/httpd-mpm.conf/iServerName localhost:80' \
         /usr/local/apache2/conf/httpd.conf

COPY --from=react_build /app/dist /usr/local/apache2/htdocs/

EXPOSE 80

CMD ["httpd-foreground"]