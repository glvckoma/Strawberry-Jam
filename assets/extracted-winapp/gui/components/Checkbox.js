"use strict";

(() => {
  customElements.define("ajd-checkbox", class extends HTMLElement {
    static get observedAttributes() {
      return ["text"];
    }

    constructor() {
      super();

      this._text = "";
      this._value = false;

      this.attachShadow({mode: "open"}).innerHTML = `
        <style>
          :host {
            user-select: none;
            display: flex;
            color: #6E4B37;
            font-family: CCDigitalDelivery;
            font-size: 18px;
            letter-spacing: .4px;
            /* each box is 22 pixels tall, 25 pixels wide */
            --checkbox-width: 22.72px;
          }

          #cb {
            width: var(--checkbox-width);
            background: url(images/core/core_form_checkbox_sprite.svg);
            background-repeat: no-repeat;
            background-size: cover;
          }

          #cb:hover {
            cursor: pointer;
          }

          #cb.checked {
            background-position-x: calc(var(--checkbox-width) * -1);
          }

          #text {
            margin-left: 5px;
            margin-top: 1px;
          }
         </style>
        <div id="cb"></div>
        <div id="text"></div>
      `;

      this.cbElem = this.shadowRoot.getElementById("cb");
      this.addEventListener("click", () => {
        this.value = !this._value;
      });
      this.textElem = this.shadowRoot.getElementById("text");
    }

    attributeChangedCallback(name, oldVal, newVal) {
      switch (name) {
        case "text": this.text = newVal; break;
        case "value": this.value = newVal; break;
      }
    }

    get text() {
      return this._text;
    }

    set text(val) {
      if (val === this._text) {
        return;
      }

      this._text = val;
      this.textElem.innerHTML = this._text;
    }

    get value() {
      return this._value;
    }

    set value(val) {
      if (this._value === globals.parseBool(val)) {
        return;
      }

      this._value = globals.parseBool(val);
      this.cbElem.classList.toggle("checked", this._value);
      this.setAttribute("value", this._value);
    }
  });
})();
