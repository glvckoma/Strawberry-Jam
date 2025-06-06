"use strict";
const http = require("http");

const config = require("./config.js");
const tean = require("tean");
tean.addBaseTypes();

const headers = {
  "Content-Type": "text/plain",
  "Access-Control-Allow-Origin": config.origin,
  "Access-Control-Allow-Methods": "POST",
  "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
  "Cache-Control": "private, no-cache",
};
let serverPromise = null;
let server = null;

Object.assign(module.exports, {
  listenForAutoLogin: () => {
    if (!serverPromise) {
      serverPromise =  new Promise((resolve, reject) => {
        server = http.createServer((request, response) => {
          const path = request.url.toLowerCase();
          if (path === "/autologin") {
            if (request.method === "OPTIONS") {
              response.writeHead(200, headers);
              response.end("ok");
            }
            else if (request.method === "POST") {
              const rawBody = [];
              request.on("data", chunk => {
                rawBody.push(chunk);
              }).on("end", async () => {
                try {
                  const body = JSON.parse(Buffer.concat(rawBody).toString());
                  const params = await tean.normalize({
                    "affiliateCode": "string(255)!null",
                    "authToken": "string(2000)",
                  }, body);
                  resolve(params);
                }
                catch (err) {
                  reject(err);
                }
                response.writeHead(200, headers);
                response.end();
                if (server) {
                  server.close();
                }
                server = null;
                serverPromise = null;
              });
              request.on("err", err => {
                server = null;
                serverPromise = null;
                reject(err);
              });
            }
            else {
              response.end();
            }
          }
          else {
            response.end();
          }
        });
        server.listen(config.serverPort);

        setTimeout(() => {
          if (server) {
            server.close();
          }
          resolve();
        }, 30000);
      });
    }
    return serverPromise;
  },

  stop: () => {
    if (server && serverPromise) {
      Promise.resolve(serverPromise);
      server.close();
      server = null;
      serverPromise = null;
    }
  },
});
