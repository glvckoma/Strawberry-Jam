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
        background-color: var(--ajd-bubble-button-background-color, #d0004a);
        border: 1px solid var(--ajd-bubble-button-border-color, #272727); /* Ensure border is used and respects variable */
        color: var(--ajd-bubble-button-text-color, #b7b7b7);
        user-select: none;
        font-family: 'Tiki-Island';
        font-size: 29px;
        border-radius: 5px;
        padding: 8px 28px;
        white-space: nowrap;
      }

      :host(:hover) {
        background-color: var(--ajd-bubble-button-background-color-hover, #5d5e6b);
        /* Optionally, allow border color to change on hover too if defined by theme */
        border-color: var(--ajd-bubble-button-border-color-hover, var(--ajd-bubble-button-border-color, #272727));
        cursor: pointer;
      }

      :host(:active) {
        background-color: var(--ajd-bubble-button-background-color-active, #55C749);
        /* The linear-gradient might be overridden by a solid background-color. Consider if this is desired. */
        /* For simplicity, we'll prioritize the CSS variable for background color. */
        /* background: linear-gradient(0deg, #59ed5e 0%, #30b020 53.4%, #51bd45 53.5%, #c8f7c5 98%); */
        border: 1px solid var(--ajd-bubble-button-border-color-active, var(--ajd-bubble-button-border-color, #30D830));
        box-shadow: 0px 0px 0px 1px #3d7c1f, 2px 3px 0 rgba(0, 0, 0, 0.25); /* Keep existing shadow or make themeable */
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
