"use strict";

(() => {
  customElements.define("ajd-error-tip", class extends HTMLElement {
    static get observedAttributes() {
      return ["text"];
    }

    constructor() {
      super();

      this._text = "";

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
            align-items: center
          }

          #text {
            padding: 12px;
            font-family: CCDigitalDelivery;
            font-size: 13px;
            color: #FFFFFF;
            background: linear-gradient(0deg, #FF4A26 60%, #FF6C47 92%, #FFA38C 100%);
            border: #FF4A26 1px solid;
            border-radius: 20px;
            letter-spacing: .7px;
            text-align: center;
            line-height: 17px;
            text-shadow: 1px 1px 0px rgba(2, 2, 2, 0.25);
            box-shadow: 0px 2px 1px rgba(2, 2, 2, 0.3);
          }

          #tip {
            /*position: absolute;*/
            border-top: 10px solid transparent;
            border-bottom: 10px solid transparent;
            border-left: 14px solid #FF4A26;
            /*margin-top: auto;
            margin-bottom: auto;*/
            /*margin-left: 190px;*/
            /*display: none;*/
          }
        </style>
        <div id="text"></div>
        <div id="tip"></div>
      `;

      this.textElem = this.shadowRoot.getElementById("text");
    }

    attributeChangedCallback(name, oldVal, newVal) {
      if (newVal === oldVal) {
        return;
      }

      switch (name) {
        case "text": this.text = newVal; break;
      }
    }

    get text() {
      return this._text;
    }

    set text(val) {
      this._text = val;
      this.setAttribute("text", this._text);
      this.textElem.innerHTML = this._text;
    }
  });
})();
