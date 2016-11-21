class WishListButton {
  constructor(el) {

    if (el._data && el._data.wishListButton) {
      return el._data.wishListButton;
    }

    this.el = el;
    this.id = el.getAttribute('data-object-id');
    this.type = el.getAttribute('data-wishlistable-type');
    this.state = el.getAttribute('data-state') == 'true';

    this.createUrl = el.getAttribute('data-path-create');
    this.deleteUrl = el.getAttribute('data-path-delete');

    this.ui = {};
    this.ui.icon = el.querySelector('[data-favorite-icon]');
    this.ui.label = el.querySelector('[data-text]');
    this.ui.link = el.querySelector('[data-action-link]');

    this.labels = {};
    this.labels.inactive = this.ui.label.getAttribute('data-inactive-state');
    this.labels.active = this.ui.label.getAttribute('data-active-state');

    this._bindEvents();

    this.el._data = {};
    this.el._data.wishListButton = this;
  }

  getElement() {
    return this.el;
  }

  setLoaded() {
    this.el.setAttribute('data-favorite-toggler-loaded', true);
  }

  setActive() {
    this.state = true;
    this.ui.icon.classList.add('selected');
    this.ui.label.innerHTML = this.labels.active;
  }

  setInactive() {
    this.state = false;
    this.ui.icon.classList.remove('selected');
    this.ui.label.innerHTML = this.labels.inactive;
  }

  _setState(state) {
    if (state) {
      this.setActive();
    }
    else {
      this.setInactive();
    }
  }

  _bindEvents() {
    this.ui.link.addEventListener('click', (e)=>{
      e.preventDefault();
      e.stopPropagation();
      this._rollbackState = this.state;
      this._setState(!this.state);
      this._updateServerState();
    });
  }

  _rollback() {
    this._setState(this._rollbackState);
  }

  _updateServerState() {
    let data = new FormData();
    data.append('id', this.id);
    data.append('wishlistable_type', this.type);

    const url = this.state ? this.createUrl : this.deleteUrl;

    if (!this.state) {
      data.append('_method', 'DELETE');
    }

    let request = new XMLHttpRequest();
    request.open('POST', url, true);
    request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="csrf-token"]').content);
    request.setRequestHeader('Accept', 'application/json');
    request.responseType = 'json';

    request.onload = ()=> {
      if (request.status < 200 || request.status >= 400) {
        this._rollback();
        throw new Error('Unable to change wish list item state');
      }
    };

    request.onerror = ()=>{
      this._rollback();
      throw new Error('Unable to reach server to change wish list item state');
    };

    request.send(data);
  }
}


module.exports = WishListButton;
