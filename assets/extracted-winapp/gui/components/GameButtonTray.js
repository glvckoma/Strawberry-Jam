"use strict";

(() => {
  customElements.define("ajd-game-button-tray", class extends HTMLElement {
    constructor() {
      super();

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          .removed {
            display: none !important;
          }

          .spaced-column {
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            box-sizing: border-box;
          }

          :host {
            display: flex;
          }

          #buttons-tray-container {
            width: 100%;
            padding: 13% 11% 11% 11%;
            background: url("images/frame/UI_button_frame_2.svg") no-repeat;
            background-size: contain;
            position: relative;
          }
          #buttons-tray-container ajd-button-with-text {
            background-position: center;
            height: 44%;
          }

          #expand-tray {
            justify-content: center;
            position: absolute;
            height: 100%;
            width: 30%;
            left: -21%;
            padding: 1% 9% 0% 2%;
            background: url("images/frame/UI_button_frame_rollout.svg") no-repeat;
            background-size: contain;
            background-position: center;
            transition-property: left;
            transition-duration: 0.2s;
          }
          #expand-tray.hidden {
            left: 0%;
          }
          #expand-tray ajd-button {
            width: 100%;
          }

        </style>
        <div id="expand-tray" class="spaced-column">
          <ajd-button graphic="UI_arrow" id="expand-tray-button">
          </ajd-button>
          <ajd-button graphic="UI_arrowBack" id="retract-tray-button" class="removed">
          </ajd-button>
        </div>
        <div id="buttons-tray-container" class="spaced-column">
          <ajd-button-with-text graphic="UI_expand" id="full-Screen-toggle-button">
          </ajd-button-with-text>
          <ajd-button-with-text graphic="UI_logOut" id="log-out-button">
          </ajd-button-with-text>
        </div>
      `;

      this.expandTrayElem = this.shadowRoot.getElementById("expand-tray");
      this.expandTrayElem.addEventListener("click", event => {
        this.expanded = this.classList.contains("expanded");
      });

      this.expandTrayButtonElem = this.shadowRoot.getElementById("expand-tray-button");
      this.retractTrayButtonElem = this.shadowRoot.getElementById("retract-tray-button");

      this.fullScreenToggleButtonElement = this.shadowRoot.getElementById("full-Screen-toggle-button");
      this.fullScreenToggleButtonElement.addEventListener("click", event => {
        window.ipc.send("systemCommand", {command: "toggleFullScreen"});
      });

      this.logOutButtonElement = this.shadowRoot.getElementById("log-out-button");
      this.logOutButtonElement.addEventListener("click", event => {
        this.dispatchEvent(new CustomEvent("logoutClicked"));
      });
    }

    connectedCallback () {
      this.localize();
    }

    set expanded (state) {
      if (state) {
        this.classList.remove("expanded");
         this.expandTrayButtonElem.classList.remove("removed");
        this.retractTrayButtonElem.classList.add("removed");
      }
      else {
        this.expandTrayButtonElem.classList.add("removed");
        this.retractTrayButtonElem.classList.remove("removed");
        this.classList.add("expanded");
      }
    }

    set expandable (state) {
      if (state) {
        this.expandTrayElem.classList.remove("hidden");
      }
      else {
        this.expandTrayElem.classList.add("hidden");
      }
    }

    async localize() {
      this.logOutButtonElement.label = await globals.translate("logoutText");
      this.fullScreenToggleButtonElement.label = await globals.translate("fullScreenButtonText");
    }
  });
})();
