"use strict";

(() => {
  customElements.define("ajd-text-input", class extends HTMLElement {
    static get observedAttributes() {
      return ["placeholder", "type", "error"];
    }

    constructor() {
      super();

      this._error = "";

      this.attachShadow({mode: "open"}).innerHTML = `
      <style>
        :host {
          --height: 46px;

          height: var(--height);
          border-radius: 6px;
          background-color: #FCF9E8;
          display: grid;
          grid-template: 1fr / 1fr;
          grid-template-areas: "main";
        }

        input {
          margin-left: 10px;
          font-size: 16px;
          outline: 0;
          font-family: CCDigitalDelivery;
          color: #b7b7b7;
          border: none;
          grid-area: main;
          background-color: rgba(0, 0, 0, 0);
          transition: margin-top 0.2s ease-out;
        }

        input:not(:placeholder-shown) {
          margin-top: 15px;
        }

        ::placeholder {
          font-style: italic;
          color: #868686;
        }

        label {
          font-family: CCDigitalDelivery;
          grid-area: main;
          color: #b7b7b7;
          pointer-events: none;
          transition: opacity 0.2s;
          opacity: 0;
          font-size: 12px;
          margin-top: 7px;
          text-rendering: geometricPrecision;
          text-align: left;
          margin-left: 10px;
        }

        input:not(:placeholder-shown) + label {
          opacity: 1;
        }

        #error {
          position: absolute;
          margin-left: -207px;
          width: 215px;
          transform: translateY(-50%);
          margin-top: calc(var(--height) / 2);
          opacity: 0;
          transition: opacity 1s;
        }

        #error.show {
          opacity: 1;
        }
      </style>

      <input id="input" autocomplete="off" aria-required="true" type="text"></input>
      <label id="label"></label>
      <ajd-error-tip id="error" text="Enter text here!"></ajd-error-tip>
    `;

      this.inputElem = this.shadowRoot.getElementById("input");
      this.labelElem = this.shadowRoot.getElementById("label");
      this.errorElem = this.shadowRoot.getElementById("error");

      // clear errors on input change
      this.inputElem.addEventListener("input", () => {
        if (this._error) {
          this.error = "";
        }
      });
      // clear error on blur (input loses focus)
      this.inputElem.addEventListener("blur", () => {
        if (this._error) {
          this.error = "";
        }
      });
      // HACK: it looks like there is a bug with chrome where we sometimes lose our text/cursor
      this.inputElem.addEventListener("focus", () => {
        this.placeholder = this.placeholder;
      });
    }

    attributeChangedCallback(name, oldVal, newVal) {
      if (newVal === oldVal) {
        return;
      }

      switch (name) {
        case "placeholder": this.placeholder = newVal; break;
        case "type": this.type = newVal; break;
      }
    }

    get value() {
      return this.inputElem.value;
    }

    set value(val) {
      this.inputElem.value = val;
    }

    get placeholder() {
      return this._placeholder;
    }

    set placeholder(val) {
      this._placeholder = val;
      this.setAttribute("placeholder", this._placeholder);
      this.inputElem.placeholder = this._placeholder;
      this.labelElem.innerHTML = this._placeholder;
    }

    get type() {
      return this.inputElem.type;
    }

    set type(val) {
      this.inputElem.type = val;
    }

    get error() {
      return this._error;
    }

    set error(val) {
      this._error = val;
      this.errorElem.classList.toggle("show", !!this._error);
      if (val) {
        this.errorElem.text = val;
      }
    }
  });
})();
