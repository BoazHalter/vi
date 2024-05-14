FROM node:lts
COPY . /src
RUN cd /src && npm install
EXPOSE 3001
CMD ["node", "/src/index.js"]
