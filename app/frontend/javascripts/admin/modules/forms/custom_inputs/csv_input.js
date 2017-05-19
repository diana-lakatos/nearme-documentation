class CSVInput {
  constructor(input) {
    this.input = input;

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
    let data = this.input.value.split(',').filter(item => item !== '');
    let items = data.reduce(
      (memo, value) => {
        if (memo) {
          memo = `${memo}, `;
        }
        return `${memo}<code>${value.trim()}</code>`;
      },
      ''
    );

    this.infoHolder.innerHTML = `<span>Current options:</span> ${items}`;
  }
}

module.exports = CSVInput;
