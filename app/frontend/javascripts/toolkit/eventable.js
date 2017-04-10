// @flow

type EventableEventType = {
  func: (...params: Array<*>) => void,
  ctx?: any
};

// Based on the minivents library
class Eventable {
  _events: { [type: string]: Array<EventableEventType> };

  constructor() {
    this._events = {};
  }

  on(type: string, func: (...params: Array<*>) => void, ctx?: any) {
    this._events[type] = this._events[type] || [];
    this._events[type].push({ func: func, ctx: ctx });
  }

  off(type?: string, func?: (...params: Array<*>) => void) {
    if (!type) {
      this._events = {};
      return;
    }

    let list = this._events[type] || [];
    let i = list.length = func ? list.length : 0;
    while(i--) {
      func === list[i].func && list.splice(i,1);
    }
  }

  emit(type: string, ...params: Array<*>) {
    let events = this._events[type] || [];

    events.forEach((e: EventableEventType) => {
      e.func.call(e.ctx || this, ...params);
    });
  }
}

module.exports = Eventable;
