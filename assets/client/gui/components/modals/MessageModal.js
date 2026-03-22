"use strict";

(() => {
  customElements.define("ajd-message-modal", class extends HTMLElement {
    constructor() {
      super();

      this._userData = null;

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
            z-index: 10;
            justify-content: center;
            align-items: center;
            height: 100vh;
            width: 100vw;
          }

          #modal-body {
            display: flex;
            flex-direction: column;
            width: 600px;
            border-radius: 10px;
            background-color: #F5F2E1;
            border: 1px solid #BDAB84;
            font-family: CCDigitalDelivery, sans-serif;
            color: #6E4B37;
            font-size: 18px;
            text-align: center;
          }

          #header-div {
            font-family: Tiki-Island, sans-serif;
            font-size: 40px;
            position: relative;
            border-bottom: #E8E0C8 1px solid;
            padding: 10px;
            color: #7A4A12;
            text-shadow: 1px 2px 0px rgba(2,2,2,0.2);
          }

          #body-div {
            padding: 20px;
          }

          #submit-div {
            display: flex;
            justify-content: center;
            align-items: center;
            padding-bottom: 18px;
          }
        </style>

        <div id="modal-body">
          <div id="header-div">
            <span id="header-text">Yay!</span>
          </div>
          <div id="body-div">
            <span id="body-text">
              Yer name changed, yo!
            </span>
          </div>
          <div id="submit-div">
            <ajd-bubble-button id="ok-button" text="OK!"></ajd-bubble-button>
          </div>
        </div>
      `;

      this.headerTextElem = this.shadowRoot.getElementById("header-text");

      this.bodyTextElem = this.shadowRoot.getElementById("body-text");

      this.okButtonElem = this.shadowRoot.getElementById("ok-button");
      this.okButtonElem.addEventListener("click", async event => {
        this.dispatchEvent(new CustomEvent("close"));
      });
    }

    set header (text) {
      this._header = text;
      this.headerTextElem.innerText = text;
    }

    get header () {
      return this._header;
    }

    set body (text) {
      this._body = text;
      this.bodyTextElem.innerText = text;
    }

    get body () {
      return this._body;
    }

    set buttonText (text) {
      this._buttonText = text;
      this.okButtonElem.text = text;
    }

    get buttonText () {
      return this._buttonText;
    }

  });
})();
