"use strict";

(() => {
  let usernameKeyEntryTimeout = null;

  customElements.define("ajd-rename-user-modal", class extends HTMLElement {
    constructor() {
      super();

      this._userData = null;

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            width: 100vw;
          }

          @keyframes spin {
            from {
              transform: rotate(0deg);
            }
            to {
              transform: rotate(-360deg);
            }
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
            position: relative;
            display: flex;
            flex-direction: column;
            align-items: center;
          }

          #body-text {
            margin: 0px 10px 0px 10px;
          }

          #submit-div {
            display: flex;
            justify-content: center;
            align-items: center;
            padding-top: 18px;
            padding-bottom: 28px;
          }

          #status-icon {
            background: url(images/core/core_form_input_status_icn_sprite.svg);
            background-repeat: no-repeat;
            width: 40px;
            height: 40px;
            position: absolute;
            z-index: 1;
            bottom: 24px;
            right: 28px;
            opacity: 0.0;
            transition-property: transform, opacity;
            transition-duration: 1.5s, 0.1s;
          }
          #status-icon.working {
            background-position: -40px 0px;
            animation: spin 1500ms linear infinite;
            opacity: 1.0;
          }
          #status-icon.valid {
            background-position: -80px 0px;
            opacity: 1.0;
          }
          #status-icon.invalid {
            background-position: -120px 0px;
            opacity: 1.0;
          }

          #username-input {
            width: 550px;
              margin-top: 24px;
              background-color: #FDFCF9;
          }

          #username-input.valid {
            background-color: #e4ffd8;
          }

          #username-input.invalid {
            background-color: #FFF7B8;
          }

          #close-button {
            position: absolute;
            z-index: 1;
            right: 20px;
            top: 20px;
          }
        </style>

        <div id="modal-body">
          <div id="header-div">
            <span id="header-text">Oops!</span>
            <ajd-sprite-sheet-button graphic="core_close_btn_sprite" id="close-button">
            </ajd-sprite-sheet-button>
          </div>
          <div id="body-div">
            <span id="body-text">
              Change yer name, yo!
            </span>
            <ajd-text-input id="username-input" placeholder="username" type="text"> </ajd-text-input>
            <div id="status-icon"></div>
          </div>
          <div id="submit-div">
            <ajd-bubble-button id="submit-button" text="Rename Account" disabled="true"></ajd-bubble-button>
          </div>
        </div>
      `;

      this.headerDivElem = this.shadowRoot.getElementById("header-text");

      this.bodyTextElem = this.shadowRoot.getElementById("body-text");

      this.statusIconElem = this.shadowRoot.getElementById("status-icon");

      this.usernameInputElem = this.shadowRoot.getElementById("username-input");
      // TODO: double check this function, saving off copies of the name smells
      this.usernameInputElem.addEventListener("keyup", async () => {
        if (this.usernameInputElem.value.length > 3) {
          this.updateUIStates("working");
          this.usernameInputElem.placeholder = await globals.translate("username");

          if (usernameKeyEntryTimeout) {
            clearTimeout(usernameKeyEntryTimeout);
          }
          const newName = `${this.usernameInputElem.value}`;
          usernameKeyEntryTimeout = setTimeout(async () => {
            const queryName = `${this.usernameInputElem.value}`;
            if (newName === this.usernameInputElem.value) {
              const response = await globals.fetch(`${globals.config.webApi}/screen_name/${encodeURIComponent(queryName)}/${encodeURIComponent(this.userData.renameToken)}/validate`, {
                method: "POST",
              }, [403, 500]);
              if (queryName === this.usernameInputElem.value) {
                if (response.status === 200) {
                  this.updateUIStates("valid");
                }
                else {
                  this.updateUIStates("invalid");
                  const parsedText = JSON.parse(await response.text());
                  let textLookup = "restartApp";
                  switch (parsedText.error) {
                    // These fall-throughs are intentional
                    case "UN_TOO_LONG":
                    case "UN_FAILED_MODERATION":
                    case "UN_FAILED_REGEX":
                    case "SIFT_REJECTED_NAME": textLookup = "invalidUsername"; break;
                    case "UN_TAKEN": textLookup = "nameTaken"; break;
                    case "INVALID_TOKEN": textLookup = "restartApp"; break;
                  }
                  this.usernameInputElem.error = await globals.translate(textLookup);
                }
              }
            }
          }, 100);
        }
        else {
          this.updateUIStates();
          this.usernameInputElem.placeholder = await globals.translate("usernameTooShort");
          usernameKeyEntryTimeout = null;
        }
      });

      this.submitButtonElem = this.shadowRoot.getElementById("submit-button");
      this.submitButtonElem.addEventListener("click", async event => {
        if (this.userData) {
          this.updateUIStates("working");
          try {
            const newName = this.usernameInputElem.value;
            const body = `token=${encodeURIComponent(this.userData.renameToken)}`;
            const response = await globals.fetch(`${globals.config.webApi}/screen_name/${encodeURIComponent(this.userData.username)}/${encodeURIComponent(newName)}/rename`, {
              method: "POST",
              mode: "cors",
              headers: {
                "Content-Type": "application/x-www-form-urlencoded"
              },
              body,
            }, [403, 422, 500]);
              this.updateUIStates();
            if (response.status === 200) {
              this.usernameInputElem.error = "";
              const modal = document.createElement("ajd-message-modal");
              modal.header = await globals.translate("success");
              modal.body = await globals.translate("nameChanged").replace("%s", newName);
              modal.buttonText = await globals.translate("ok");
              modal.addEventListener("close", event => {
                document.getElementById("modal-layer").removeChild(modal);
              });
              document.getElementById("modal-layer").appendChild(modal);
              this.dispatchEvent(new CustomEvent("accountCreated", {detail: {username: newName}}));
            }
            else {
              this.updateUIStates("invalid");
              const parsedText = JSON.parse(await response.text());
              let textLookup = "restartApp";
              switch (parsedText.error) {
                // These fall-throughs are intentional
                case "UN_TOO_LONG":
                case "UN_FAILED_MODERATION":
                case "UN_FAILED_REGEX":
                case "SIFT_REJECTED_NAME": textLookup = "invalidUsername"; break;
                case "UN_TAKEN": textLookup = "nameTaken"; break;
                case "INVALID_TOKEN": textLookup = "restartApp"; break;
              }
              this.usernameInputElem.error = await globals.translate(textLookup);
            }
          }
          catch (err) {
            this.updateUIStates();
          }
        }
      });


      this.closeButtonElem = this.shadowRoot.getElementById("close-button");
      this.closeButtonElem.addEventListener("click", async event => {
        this.dispatchEvent(new CustomEvent("close"));
      });
    }

    async localize() {
      this.headerDivElem.innerText = await globals.translate("changeUsernameHeader");
      this.bodyTextElem.innerText = `${await globals.translate("changeUsernameNoteText")} ${await globals.translate("changeUsername")}`;
      this.usernameInputElem.placeholder = await globals.translate("username");
      this.submitButtonElem.text = await globals.translate("changeUsernameSubmit");
    }

    set userData (data) {
      this._userData = data;
      this.localize();
      this.bodyTextElem.innerText = this.bodyTextElem.innerText.replace("%s", data.username);
    }

    get userData () {
      return this._userData;
    }

    updateUIStates (newState) {
      const states = ["working", "valid", "invalid"];
      for (const element of [this.usernameInputElem, this.statusIconElem]) {
        for (const state of states) {
          element.classList.remove(state);
        }
        if (newState) {
          element.classList.add(newState);
        }
      }
      if (newState === "valid") {
        this.submitButtonElem.disabled = false;
      }
      else {
        this.submitButtonElem.disabled = true;
      }
    }
  });
})();
