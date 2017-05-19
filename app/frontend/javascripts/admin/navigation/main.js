import closest from '../toolkit/closest';

class MainNavigation {
  constructor() {
    this.container = document.querySelector('.page-header');
    if (!this.container) {
      return;
    }

    this.createToggler();
    this.bound = {};
    this.bindEvents();
  }
  createToggler() {
    this.toggler = document.createElement('button');
    this.toggler.setAttribute('type', 'button');
    this.toggler.classList.add('nav-primary-toggler');
    this.toggler.innerHTML = 'Toggle navigation';
    this.container.appendChild(this.toggler);
  }
  bindEvents() {
    this.toggler.addEventListener('click', e => {
      e.preventDefault();
      e.stopPropagation();

      if (this.container.classList.contains('navigation-active')) {
        this.close();
      } else {
        this.open();
      }
    });
  }
  open() {
    this.container.classList.add('navigation-active');
    this.bound.bodyClick = this.bodyClick.bind(this);
    this.bound.bodyKeydown = this.bodyKeydown.bind(this);
    document.body.addEventListener('click', this.bound.bodyClick);
    document.body.addEventListener('keydown', this.bound.bodyKeydown);
  }
  close() {
    this.container.classList.remove('navigation-active');
    document.body.removeEventListener('click', this.bound.bodyClick);
    document.body.removeEventListener('keydown', this.bound.bodyKeydown);
  }
  bodyClick(e) {
    if (!closest(e.target, '.page-header')) {
      this.close();
    }
  }
  bodyKeydown(e) {
    if (e.which === 27) {
      this.close();
    }
  }
}

module.exports = MainNavigation;
