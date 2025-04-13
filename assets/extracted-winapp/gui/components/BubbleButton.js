"use strict";

(() => {
  customElements.define("ajd-bubble-button", class extends HTMLElement {
    static get observedAttributes() {
      return ["text", "disabled"];
    }

    constructor() {
      super();

      this._text = "";
      this._disabled = false;

      this.attachShadow({mode: "open"}).innerHTML = `
      <style>
      :host {
        background-color: #d0004a;
        border-color: #272727 !important;
        color: #b7b7b7 !important;
        user-select: none;
        font-family: 'Tiki-Island';
        font-size: 29px;
        border-radius: 5px;
        padding: 8px 28px;
        white-space: nowrap;
      }

      :host(:hover) {
        background-color: #5d5e6b;
        cursor: pointer;
      }

      :host(:active) {
        background-color: #55C749;
        background: linear-gradient(0deg, #59ed5e 0%, #30b020 53.4%, #51bd45 53.5%, #c8f7c5 98%);
        border: #30D830 1px solid;
        box-shadow: 0px 0px 0px 1px #3d7c1f, 2px 3px 0 rgba(0, 0, 0, 0.25);
        transform: translateY(1px);
      }

      :host([disabled]) {
        color: #5E5E5E;
        background-color: #969696;
        background: linear-gradient(0deg, #A2A2A2 0%, #868686 53.4%, #939393 53.5%, #B3B3B3 98.8%);
        border: #B0B7BA 1px solid;
        box-shadow: 0px 0px 1px #808080, 2px 3px 0 rgba(0, 0, 0, 0.25);
        cursor: default;
      }
    </style>
    <div id="button"></div>
      `;

      this.buttonElem = this.shadowRoot.getElementById("button");
    }

    attributeChangedCallback(name, oldVal, newVal) {
      switch (name) {
        case "text": this.text = newVal; break;
        case "disabled": this.disabled = newVal; break;
      }
    }

    get text() {
      this.getAttribute("text");
    }

    set text(val) {
      if (val === this._text) {
        return;
      }

      this._text = val;
      this.setAttribute("text", this._text);
      this.buttonElem.innerHTML = this._text;
    }

    get disabled() {
      return this._disabled;
    }

    set disabled(val) {
      if (this._disabled && val === "" || globals.parseBool(val) === this._disabled) {
        return;
      }

      this._disabled = globals.parseBool(val);
      if (this._disabled) {
        this.setAttribute("disabled", "");
      }
      else {
        this.removeAttribute("disabled");
      }
    }
  });
})();
