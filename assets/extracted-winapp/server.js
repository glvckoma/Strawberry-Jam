"use strict";
const http = require("http");

const config = require("./config.js");
const tean = require("tean");
tean.addBaseTypes();

// Unadressed security concerns
// HTTPS would be much more secure, but then we have to look into a cert to sign for 127.0.0.1
// It is ASSUMED that the auto login feature would ONLY BE USED FOR LOW VALUE ACCOUNTS.  IF THIS FEATURE IS USED WITH AN ESTABLISHED HIGH VALUE
// ACCOUNT, IT IS A BIG TARGET FOR HACKERS
// It might be worth adding another handshake endpoint so the browser can verify that it is actually talking to AJ Desktop,
// but these tokens are for low value accounts and not likely targets
// The tokens we log in with are multi-use and live for 4 hours, again these tokens represent a login for a low-value account

const headers = {
  "Content-Type": "text/plain",
  "Access-Control-Allow-Origin": config.origin,
  "Access-Control-Allow-Methods": "POST",
  "Access-Control-Allow-Headers": "Origin, X-Requested-With, Content-Type, Accept",
  "Cache-Control": "private, no-cache",
};
let serverPromise = null;
let server = null;

// Example on how to call this endpoint
// window.fetch("http://127.0.0.1:8088/autoLogin", {
//   method: "POST",
//   mode: "CORS",
//   headers: {},
//   body: JSON.stringify({
//     affiliateCode: 3,
//     authToken: "IAMATESTTOKEN",
//   }),
// }).then(() => console.log("success")).catch(err => {
//   console.log(err);
// });
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
