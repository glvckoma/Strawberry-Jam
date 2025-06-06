"use strict";
(() => {
  customElements.define("otp-modal", class extends HTMLElement {
    constructor() {
      super();

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
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
            border-bottom: #E8E0C8 2px solid;
            padding: 20px;
            display: flex;
            flex-direction: column;
            align-items: center;
          }

          #body-text {
            margin: 10px 10px 24px 10px;
          }

          #body-div ajd-text-input {
            width: 300px;
            background-color: #FDFCF9;
            margin-bottom: 8px;
          }

          #submit-div {
            display: flex;
            justify-content: center;
            align-items: center;
            padding-top: 18px;
            padding-bottom: 28px;
          }

          #close-button {
            position: absolute;
            z-index: 1;
            right: 10px;
            top: 10px;
          }
        </style>

        <div id="modal-body">
          <div id="header-div">
            <span id="header-text">2-STEP VERIFICATION</span>
            <ajd-sprite-sheet-button graphic="core_close_btn_sprite" id="close-button">
            </ajd-sprite-sheet-button>
          </div>
          <div id="body-div">
            <span id="body-text">
              Enter the Verification Code sent to your parent's email:
            </span>
            <ajd-text-input id="otp-input" placeholder="Code" type="text"> </ajd-text-input>
          </div>
          <div id="submit-div">
            <ajd-bubble-button id="submit-button" text="Verify" disabled="true"></ajd-bubble-button>
          </div>
        </div>
      `;

      this.headerDivElem = this.shadowRoot.getElementById("header-text");

      this.bodyTextElem = this.shadowRoot.getElementById("body-text");

      this.otpInputElem = this.shadowRoot.getElementById("otp-input");
      this.otpInputElem.addEventListener("keyup", event => {
        this.submitButtonElem.disabled = !this.otpInputElem.value;
      });

      this.submitButtonElem = this.shadowRoot.getElementById("submit-button");
      this.submitButtonElem.addEventListener("click", async event => {
        if (this.otpInputElem.value) {
          this.dispatchEvent(new CustomEvent("submit", {detail:{otp: this.otpInputElem.value}}));
        }
      });

      this.closeButtonElem = this.shadowRoot.getElementById("close-button");
      this.closeButtonElem.addEventListener("click", async event => {
        this.dispatchEvent(new CustomEvent("close"));
      });
    }

    connectedCallback() {
      this.localize();
    }

    async localize() {
      this.headerDivElem.innerText = await globals.translate("otpTitle");
      this.bodyTextElem.innerText = await globals.translate("otpMessage");
      this.submitButtonElem.text = await globals.translate("otpButton");
      this.otpInputElem.placeholder = await globals.translate("otpLabel");
    }
  });
})();
