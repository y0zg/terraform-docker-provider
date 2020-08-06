FROM node:8.4-alpine

LABEL maintainer "Test <test@gmail.com>"

# Install redis
RUN apk add --no-cache redis supervisor

# Create app directory
WORKDIR /usr/src/app

# Adding supervisor configuration file to container
COPY start-script.conf /src/supervisor/

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
COPY package*.json ./

RUN npm install

COPY . .

EXPOSE 3000

CMD ["supervisord","-c","/src/supervisor/start-script.conf"]
