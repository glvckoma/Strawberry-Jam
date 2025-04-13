"use strict";
(() => {
  customElements.define("ajd-forgot-password-modal", class extends HTMLElement {
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
            <span id="header-text">reset password</span>
            <ajd-sprite-sheet-button graphic="core_close_btn_sprite" id="close-button">
            </ajd-sprite-sheet-button>
          </div>
          <div id="body-div">
            <span id="body-text">
              Change yer name, yo!
            </span>
            <ajd-text-input id="username-input" placeholder="username" type="text"> </ajd-text-input>
            <ajd-text-input id="email-input" placeholder="parent email" type="text"> </ajd-text-input>
          </div>
          <div id="submit-div">
            <ajd-bubble-button id="submit-button" text="submit" disabled="true"></ajd-bubble-button>
          </div>
        </div>
      `;

      this.headerDivElem = this.shadowRoot.getElementById("header-text");

      this.bodyTextElem = this.shadowRoot.getElementById("body-text");

      this.emailInputElem = this.shadowRoot.getElementById("email-input");
      this.emailInputElem.addEventListener("keyup", event => {
        this.submitButtonElem.disabled = !this.usernameInputElem.value || !this.emailInputElem.value;
      });

      this.usernameInputElem = this.shadowRoot.getElementById("username-input");
      this.usernameInputElem.addEventListener("keyup", event => {
        this.submitButtonElem.disabled = !this.usernameInputElem.value || !this.emailInputElem.value;
      });

      this.submitButtonElem = this.shadowRoot.getElementById("submit-button");
      this.submitButtonElem.addEventListener("click", async event => {
        if (this.usernameInputElem.value && this.emailInputElem.value) {
          try {
            const body = `username=${encodeURIComponent(this.usernameInputElem.value)}&parent_email=${encodeURIComponent(this.emailInputElem.value)}`;

            const response = await globals.fetch(`${globals.config.web}/child_request_reset_password`, {
              method: "POST",
              mode: "cors",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded"
              },
              body,
            }, [422]);
            // this.usernameInputElem.value, this.submitButtonElem.value

            if (response.status === 422) {
              const {message} = JSON.parse(await response.text());
              // HACK: web will return an error code so we're not relying on a message like this
              if (message === "I'm sorry, we cannot find an account matching that username.") {
                this.usernameInputElem.error = await globals.translate("userNotFound");
              }
              else if (message === "The email address you entered does not match our records") {
                this.emailInputElem.error = await globals.translate("wrongEmail");
              }
              else if (message === "You must enter both a username and an email address") {
                this.usernameInputElem.error = await globals.translate("usernameEmailRequired");
              }
              else {
                globals.genericError(message);
              }
            }
            else if (response.status === 200) {
              const {message} = JSON.parse(await response.text());
              const modal = document.createElement("ajd-message-modal");
              modal.header = await globals.translate("success");
              // TODO: localize this
              modal.body = message;
              modal.buttonText = await globals.translate("ok");
              modal.addEventListener("close", event => {
                document.getElementById("modal-layer").removeChild(modal);
              });
              document.getElementById("modal-layer").appendChild(modal);
              this.dispatchEvent(new CustomEvent("close"));
            }
            else {
              globals.genericError("UNHANDLED_PASSWORD_RESET_ERROR");
            }
          }
          catch (err) {
            globals.genericError(err);
          }
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
      this.headerDivElem.innerText = await globals.translate("passwordReset");
      this.bodyTextElem.innerText = await globals.translate("forgotPasswordNote");
      this.submitButtonElem.text = await globals.translate("submit");
      this.usernameInputElem.placeholder = await globals.translate("username");
      this.emailInputElem.placeholder = await globals.translate("parentEmail");
    }
  });
})();
