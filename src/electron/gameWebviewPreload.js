"use strict";

const { ipcRenderer } = require("electron");

const sendWhitelist = new Set()
  .add("initialized")
  .add("printImage")
  .add("reloadGame")
  .add("reportError")
  .add("signupCompleted");

const receiveWhitelist = new Set()
  .add("flashVarsReady")
  .add("removed");

window.ipc = {
  sendToHost: (channel, ...args) => {
    if (sendWhitelist.has(channel)) {
      ipcRenderer.sendToHost(channel, ...args);
    }
  },
  on: (channel, listener) => {
    if (receiveWhitelist.has(channel)) {
      ipcRenderer.on(channel, listener);
    }
  }
};
