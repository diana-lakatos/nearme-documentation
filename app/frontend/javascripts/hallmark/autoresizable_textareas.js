class AutoresizableTextarea {
  constructor() {
    this.adjustAll();
    this.bindEvents();
  }

  bindEvents(){

    function onChange(event) {
      let t = event.target;
      if (t.nodeName.toLowerCase() === 'textarea' && t.hasAttribute('data-auto-resize')) {
        this.adjustHeight(t);
      }
    }

    document.body.addEventListener('input', onChange.bind(this), true);
    document.body.addEventListener('change', onChange.bind(this), true);
    document.body.addEventListener('focus', onChange.bind(this), true);

    $(document).on('new-comment activity-feed-next-page', ()=> {
      this.adjustAll();
    });
  }

  adjustHeight(textarea) {
    if (textarea.clientHeight < textarea.scrollHeight) {
      textarea.style.height = `${textarea.scrollHeight + 50}px`;
    }
  }

  adjustAll() {
    Array.prototype.forEach.call(document.querySelectorAll('textarea[data-auto-resize]'), this.adjustHeight);
  }
}

module.exports = AutoresizableTextarea;
