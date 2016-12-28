let delegate = require('dom-delegate');

class ConfirmDialog {
  constructor(options = {}) {
    const defaults = {
      content: 'Are you sure you want to continue?',
      buttons: [
                { action: 'cancel', label: 'Cancel', klass: 'btn-cancel' },
                { action: 'confirm', label: 'OK', klass: 'btn-confirm' }
      ],
      onOpen: function(){},
      onCancel: function(){},
      onConfirm: function(){}
    };

    this.bodyDelegated = delegate(document.body);
    this.options = Object.assign({}, defaults, options);

    this.build();
    this.open();

    this.bindEvents();
  }

  build(){
    let dialog = document.createElement('div');
    dialog.className = 'confirm-dialog';
    dialog.setAttribute('role','dialog');
    dialog.setAttribute('aria-describedby', 'confirm-dialog-content');
    dialog.setAttribute('tabindex', '-1');

    dialog.innerHTML = `
            <div class="confirm-dialog-overlay"></div>
            <div class="confirm-dialog-container">
                <div class="confirm-dialog-content" id="confirm-dialog-content">${this.options.content}</div>
                <div class="confirm-dialog-actions"></div>
            </div>`;

    this.dialog = dialog;
    this.dialog.querySelector('.confirm-dialog-actions').appendChild(this.createButtons());
    document.body.appendChild(this.dialog);
  }

  createButtons(){
    let frag = document.createDocumentFragment();
    this.options.buttons.forEach((button) =>{
      let el = document.createElement('button');
      el.setAttribute('data-action', button.action);
      el.innerHTML = button.label;
      el.classList.add('btn', button.klass);
      frag.appendChild(el);
    });
    return frag;
  }

  bindEvents(){
    delegate(this.dialog).on('click', '[data-action="cancel"]', (e)=>{
      e.preventDefault();
      this.cancel();
    });

        /* Click on modal button trigger */
    delegate(this.dialog).on('click', '[data-action="confirm"]', (e) => {
      e.preventDefault();
      this.confirm();
    });
  }

  open() {
    this.focusElement = document.activeElement;
    this.dialog.focus();

    this.bindEscapeKey();

    this.options.onOpen(); // callback
  }

  hide(){
    this.dialog.parentNode.removeNode(this.dialog);
    this.bodyDelegated.off('keydown');
    this.focusElement.focus();
  }

  cancel(){
    this.options.onCancel(); // callback
    this.hide();
  }

  confirm(){
    this.options.onConfirm(); // callback
    this.hide();
  }

  bindEscapeKey(){
    this.bodyDelegated.on('keydown', (e)=>{
      if (e.which === 27) {
        this.hide();
      }
    });
  }
}

module.exports = ConfirmDialog;
