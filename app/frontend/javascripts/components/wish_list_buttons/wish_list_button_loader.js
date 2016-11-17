const WishListButton = require('wish_list_button');

class WishListButtonLoader {
  constructor() {
    this._buttons = {};
  }

  load(context = document){
    let elements = context.querySelectorAll('[data-add-favorite-button]');
    elements = Array.prototype.filter.call(elements, function(el){
      return !el.getAttribute('data-favorite-toggler-loaded');
    });

    if (elements.length === 0) {
      return;
    }

    let url = elements[0].getAttribute('data-path-load');

    Array.prototype.forEach.call(elements, (el)=>{
      const button = new WishListButton(el);
      this._buttons[button.id] = button;
    });

    this._enableFavoritedButtons(url, (id)=>{
      if (this._buttons.hasOwnProperty(id)) {
        let button = this._buttons[id];
        button.setActive();
        button.setLoaded();
      }
    });
  }

  _enableFavoritedButtons(url, callback){

    let request = new XMLHttpRequest();
    request.open('GET', url, true);
    request.setRequestHeader('X-CSRF-Token', document.querySelector('meta[name="csrf-token"]').content);
    request.responseType = 'json';

    request.onload = function() {
      if (request.status >= 200 && request.status < 400) {
        let res = request.response;

        if (!res.wish_list_items) {
          throw new Error('Invalid response from wish list buttons fetch');
        }

        res.wish_list_items.map( (item) => item.wishlistable_id ).forEach(callback);
      } else {
        throw new Error('Unable to parse wish list buttons response');
      }
    };

    request.onerror = function(){
      throw new Error('Unable to reach server to fetch wish list status');
    };

    request.send();
  }
}

module.exports = new WishListButtonLoader();
