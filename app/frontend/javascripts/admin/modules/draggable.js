const Events = require('minivents/dist/minivents.commonjs');

class Draggable {
  constructor(el, options = {}) {
    new Events(this);

    const defaults = {
      handle: null
    };

    this.options = Object.assign({}, defaults, options);

    this._el = el;
    this._active = false;
    this._elemX = 0;
    this._elemY = 0;

    this._startDragBound = this._startDrag.bind(this);
    this._dragBound = this._drag.bind(this);
    this._endDragBound = this._endDrag.bind(this);
    this._bindEvents();

  }

  _bindEvents() {
    this._dragHandle = this.options.handle || this._el;
    this._dragHandle.addEventListener('mousedown', this._startDragBound);
  }

  _setInitialPosition() {
    this._initOffsetX = parseFloat(this._el.getAttribute('data-offset-x')) || 0;
    this._initOffsetY = parseFloat(this._el.getAttribute('data-offset-y')) || 0;
    this._setPosition(this._initOffsetX, this._initOffsetY);
  }

  _startDrag(event) {
    this._setInitialPosition();
    this._initPageX = event.pageX;
    this._initPageY = event.pageY;

    document.addEventListener('mousemove', this._dragBound);
    document.addEventListener('mouseup', this._endDragBound);

    this.emit('dragstart');
        /* Stop propagation */
    return false;
  }

  _endDrag(event) {
    let [x, y] = this._getCurrentOffset(event);
    this._el.setAttribute('data-offset-x', x);
    this._el.setAttribute('data-offset-y', y);
    document.removeEventListener('mousemove', this._dragBound);
    document.removeEventListener('mouseup', this._endDragBound);

    this.emit('dragend', [x, y]);
  }

  _drag(event) {
    let [x, y] = this._getCurrentOffset(event);
    this._setPosition(x, y);
    this.emit('drag', [x, y]);
  }

  _setPosition(x, y) {
    this._el.style.transform = `translate(${x}px, ${y}px)`;
  }

  _getCurrentOffset(event) {
    let x = event.pageX - this._initPageX + this._initOffsetX;
    let y = event.pageY - this._initPageY + this._initOffsetY;

    return [x, y];
  }

  destroy() {
    this._dragHandle.removeEventListener('mousedown', this._startDragBound);
    this.off('dragend');
    this.off('drag');
    this.off('dragstart');
  }

  resetPosition() {
    this._el.style.transform = 'translate(0, 0)';
  }
}

module.exports = Draggable;
