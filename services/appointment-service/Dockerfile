FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

COPY . .

EXPOSE 3001

CMD ["node", "server.js"]