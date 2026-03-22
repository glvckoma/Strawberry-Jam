"use strict";

(() => {
  customElements.define("ajd-progress-ring", class extends HTMLElement {
    static get observedAttributes() {
      return ['progress'];
    }
  
    constructor() {
      super();
      const strokeColor = this.getAttribute('stroke-color', 'white');
      const strokeWidth = this.getAttribute('stroke-width') || 4;
      const radius = this.getAttribute('radius') || 20;
      const normalizedRadius = radius - strokeWidth * 2;
      this._circumference = normalizedRadius * 2 * Math.PI;

      this._root = this.attachShadow({mode: 'open'});
      this._root.innerHTML = `
        <svg
          height="${radius * 2}"
          width="${radius * 2}"
        >
          <circle
            stroke="${strokeColor}"
            stroke-dasharray="${this._circumference} ${this._circumference}"
            style="stroke-dashoffset:${this._circumference}"
            stroke-width="${strokeWidth}"
            fill="transparent"
            r="${normalizedRadius}"
            cx="${radius}"
            cy="${radius}"
          />
        </svg>

        <style>
          circle {
            transition: stroke-dashoffset 0.35s;
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
          }
        </style>
      `;
    }

    setProgress(percent) {
      const offset = this._circumference - (percent / 100 * this._circumference);
      const circle = this._root.querySelector('circle');
      circle.style.strokeDashoffset = offset; 
    }
  
    attributeChangedCallback(name, oldValue, newValue) {
      if (name === 'progress') {
        this.setProgress(newValue);
      }
    }
  });
})();
