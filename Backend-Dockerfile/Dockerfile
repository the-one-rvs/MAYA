FROM node:23-slim

WORKDIR /app

COPY package.json ./
COPY package*.json ./

RUN npm install

COPY . .

CMD ["npm", "start"]