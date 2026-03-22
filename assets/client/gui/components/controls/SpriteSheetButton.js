"use strict";
(() => {
  customElements.define("ajd-sprite-sheet-button", class extends HTMLElement {
    static get observedAttributes() {
      return ["graphic"];
    }

    constructor() {
      super();

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
            width: 54px;
            height: 54px;
            align-items: center;
            background-repeat: no-repeat;
            user-select: none;
            background-image: var(--image);
          }
          :host(:hover) {
            background-position-y: -54px;
          }

          :host(:active) {
            background-position-y: -108px;
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
      return this.getAttribute("graphic");
    }

    set graphic(val) {
      this.setAttribute("graphic", val);
      this.style.setProperty("--image", `url(images/frame/buttons/${val}.svg)`);
    }
  });
})();
