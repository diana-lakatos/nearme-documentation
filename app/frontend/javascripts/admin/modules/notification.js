'use strict';

import NM from 'nm';

const defaults = {
  message: '',
  type: 'notice',
  autoclose: 6000,
  showOnInit: true,
  labelClose: 'Close'
};

function getNotificationArea(){
  let area = document.getElementById('notification-area');
  if (area) {
    return area;
  }

  area = document.createElement('div');
  area.id = 'notification-area';
  area.classList.add('notification-area');
  document.body.appendChild(area);
  return area;
}


class Notification {
  constructor(options = {}){
    options = Object.assign({}, defaults, options);

    this.element = options.element;
    if (!this.element) {
      this.element = document.createElement('div');
      this.element.classList.add('notification', `is-${options.type}`);
      this.element.innerHTML = `<div class="notification-body">${options.message}</div>
            <button type="button" class="notification-close">${options.labelClose}</button>`;
    }
    this.element.setAttribute('data-initialised', true);

    this.element.querySelector('button.notification-close').addEventListener('click', this.hide.bind(this));

    if (options.showOnInit) {
      NM.emit('beforeShow:notification', this);
      this.show();
      NM.emit('afterShow:notification', this);
    }

    if (options.autoclose) {
      this.timeout = window.setTimeout(this.hide.bind(this), options.autoclose);
    }

    this.getOptions = function(){
      return options;
    };
  }
  show(){
    let area = getNotificationArea();
    area.appendChild(this.element);
  }

  hide(){
    NM.emit('beforeHide:notification', this);
    clearTimeout(this.timeout);
    this.element.parentNode.removeChild(this.element);
    NM.emit('afterHide:notification', this);
  }
}

module.exports = Notification;
