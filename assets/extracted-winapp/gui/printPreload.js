"use strict";

const { ipcRenderer, contextBridge } = require("electron");

const sendWhitelist = new Set()
  .add("closePrintWindow")
  .add("readyForImage");

const receiveWhitelist = new Set()
  .add("setImage");

  // allow renderer process to safely communicate with main process
contextBridge.exposeInMainWorld(
  "ipc", {
    send: (channel, ...args) => {
      if (sendWhitelist.has(channel)) {
        ipcRenderer.send(channel, ...args);
      }
    },
    on: (channel, listener) => {
      if (receiveWhitelist.has(channel)) {
        ipcRenderer.on(channel, listener);
      }
    }
  }
);

ipcRenderer.on("redirect-url", (event, url) => {
  console.log("REDIRECT");
});
