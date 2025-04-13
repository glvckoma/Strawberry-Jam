"use strict";

(() => {
  customElements.define("ajd-button-with-text", class extends HTMLElement {
    static get observedAttributes() {
      return ["graphic", "label"];
    }

    constructor() {
      super();

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
            align-items: center;
            width: 100%;
            height: 100%;
            background-size: contain;
            background-repeat: no-repeat;
            user-select: none;
            background-image: var(--default);
          }

          :host(:hover) {
            background-image: var(--hover);
          }

          :host(:active) {
            background-image: var(--down);
          }

          #label {
            display: flex;
            justify-content: center;
            align-items: center;
            /*background-color: rgba(0, 0, 255, 0.6);*/
            color: rgba(255, 255, 255, 0.6);
            font-family: Tiki-Island, sans-serif;
            font-size: 5vh;
            position: relative;
            width: 58%;
            left: 5%;
            height: 70%;
            top: 1.5%;
            border-top-left-radius: 25% 50%;
            border-bottom-left-radius: 25% 50%;
          }

        </style>
        <div id="label"></div>
      `;
      this.labelElem = this.shadowRoot.getElementById("label");
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

    get label() {
      this.getAttribute("label");
    }

    set label(val) {
      this.setAttribute("label", val);
      this.labelElem.innerText = val;
      this.labelElem.style.fontSize = `calc(${Math.min(16 / val.length, 3.5)} * var(--game-height) * 0.01 )`;
    }
  });
})();
