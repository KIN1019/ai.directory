FROM node:24-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --force
COPY . .
RUN npm run build
EXPOSE 8080
CMD ["npm", "run", "start", "--", "--port", "8080"]