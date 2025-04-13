"use strict";

(() => {
  customElements.define("ajd-button", class extends HTMLElement {
    static get observedAttributes() {
      return ["graphic"];
    }

    constructor() {
      super();

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            background-size: contain;
            user-select: none;
            content: var(--default);
          }

          :host(:hover) {
            content: var(--hover);
          }

          :host(:active) {
            content: var(--down);
          }
        </style>
      `;
    }

    attributeChangedCallback(name, oldVal, newVal) {
      if (newVal === oldVal) {
        return;
      }

      switch (name) {
        case "graphic": this.graphic = newVal; break;
      }
    }

    get graphic() {
      this.getAttribute("graphic");
    }

    set graphic(val) {
      this.setAttribute("graphic", val);
      this.style.setProperty("--default", `url(images/frame/buttons/${val}_up.svg)`);
      this.style.setProperty("--hover", `url(images/frame/buttons/${val}_mouse.svg)`);
      this.style.setProperty("--down", `url(images/frame/buttons/${val}_down.svg)`);
      window.dispatchEvent(new CustomEvent("preloadAssets", {detail: {
        urls: ["_up", "_mouse", "_down"].map(state => `images/frame/buttons/${val}${state}.svg`),
      }}));
    }
  });
})();
