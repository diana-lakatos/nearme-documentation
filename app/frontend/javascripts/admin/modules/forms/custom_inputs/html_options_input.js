class HTMLOptionsInput {
  constructor(input) {
    this.input = input;

    this.data = {};

    this.build();
    this.bindEvents();
    this.parse();
  }

  build() {
    this.infoHolder = document.createElement('div');
    this.infoHolder.className = 'hint';
    this.input.parentNode.appendChild(this.infoHolder);
  }

  bindEvents() {
    this.input.addEventListener('keyup', this.parse.bind(this));
  }

  parse() {
    this.data = {};

    let kv = this.input.value.split(',').filter(o => !!o);
    let items = '';

    try {
      kv.forEach(s => {
        let [ key, value ] = s.trim().split('=>');
        this.data[key] = value;
        if (!key || !value) {
          throw new Error('Invalid format');
        }
        items += `<li><code>${key}</code> : <code>${value}</code></li>`;
      });

      this.infoHolder.innerHTML = `<span>Current options:</span> <ul class="html-options-items">${items}</ul></code>`;
    } catch (e) {
      this.infoHolder.innerHTML = '<span class="error">Invalid format</span>';
    }
  }
}

module.exports = HTMLOptionsInput;
