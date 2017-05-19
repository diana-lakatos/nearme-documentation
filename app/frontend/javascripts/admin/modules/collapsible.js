class Collapsible {
  constructor(toggler) {
    if (typeof toggler === 'string') {
      this.toggler = document.querySelector('.page-header');
    } else {
      this.toggler = toggler;
    }

    this.targets = this.toggler.getAttribute('aria-controls');

    if (!this.targets) {
      return;
    }

    // create array with dom elements referenced by ID in aria-controls attribute
    this.targets = this.targets
      .split(' ')
      .map(id => document.getElementById(id))
      .filter(el => el !== null);

    if (this.targets.length === 0) {
      return;
    }

    this.bindEvents();
    this.updateState();
  }
  updateState() {
    this.targets.forEach(el => {
      if (this.toggler.checked) {
        return el.classList.add('active');
      }
      el.classList.remove('active');
    });
  }
  bindEvents() {
    this.toggler.addEventListener('change', this.updateState.bind(this));
  }
}

module.exports = Collapsible;
