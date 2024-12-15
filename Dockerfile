# Multi-stage build docker file

# app build stage
FROM node:12-alpine as build
WORKDIR /app
ENV PATH /app/node_modules/.bin:$PATH
COPY ./package.json /app/
COPY ./yarn.lock /app/
RUN yarn
COPY . /app
RUN yarn build

# image build stage
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
COPY --from=build /app/env.sh /docker-entrypoint.d
RUN chmod +x /docker-entrypoint.d/env.sh
RUN rm /etc/nginx/conf.d/default.conf
COPY conf.d/default.conf /etc/nginx/conf.d
# Inform Docker that the container publishes TCP port 8080
EXPOSE 8080

# Start nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]