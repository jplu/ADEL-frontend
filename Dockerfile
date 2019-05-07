# build stage
FROM node:10.15.3-alpine as build-stage
WORKDIR /app
COPY . ./
RUN npm install
RUN npm run build

# production stage
FROM nginx:1.15.12-alpine as production-stage
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]