FROM node:lts
COPY . /src
RUN cd /src && npm install
EXPOSE 3000
CMD ["node", "/src/index.js"]

