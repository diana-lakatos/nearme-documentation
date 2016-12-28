import NM from 'nm';
import UISettings from '../modules/ui_settings';
import Draggable from '../modules/draggable';

class Help {
  constructor(el){
    this._ui = {};
    this._ui.el = el;
    this._ui.wrapper = document.querySelector('.config-section');
    this._ui.fields = document.querySelector('.config-section-fields');

    this._build();
    this._bindEvents();
    this._initDraggable();
    this._initEditor();
  }
  _build(){
        /* Toggler */
    this._ui.toggler = document.createElement('button');
    this._ui.toggler.setAttribute('type', 'button');
    this._ui.toggler.innerHTML = 'Help';
    this._ui.toggler.className = 'btn help-option-button help-toggler';
    this._ui.fields.appendChild(this._ui.toggler);

    let optionsWrapper = this._ui.el.querySelector('div.help-options');
    if (!optionsWrapper) {
      optionsWrapper = document.createElement('div');
      optionsWrapper.className = 'help-options';
      this._ui.el.appendChild(optionsWrapper);
    }

    this._ui.dragHandle = document.createElement('span');
    this._ui.dragHandle.innerHTML = 'Move';
    this._ui.dragHandle.className = 'btn help-option-button help-drag-handle';
    optionsWrapper.insertBefore(this._ui.dragHandle, optionsWrapper.firstChild);

        /* Detacher */
    this._ui.detachToggler = document.createElement('button');
    this._ui.detachToggler.setAttribute('type', 'button');
    this._ui.detachToggler.innerHTML = this.getDetachTogglerLabel();
    this._ui.detachToggler.className = 'btn help-option-button help-detach-toggler';
    optionsWrapper.appendChild(this._ui.detachToggler);

        /* Close help button */
    this._ui.closeHelpButton = document.createElement('button');
    this._ui.closeHelpButton.setAttribute('type', 'button');
    this._ui.closeHelpButton.innerHTML = 'Close Help';
    this._ui.closeHelpButton.className = 'btn help-option-button help-close';
    optionsWrapper.appendChild(this._ui.closeHelpButton);
  }

  _bindEvents(){
    this._ui.toggler.addEventListener('click', (e)=>{
      e.preventDefault();
      this.toggle();
    });

    this._ui.closeHelpButton.addEventListener('click', (e)=>{
      e.preventDefault();
      this.close();
    });

    this._ui.detachToggler.addEventListener('click', (e)=>{
      e.preventDefault();
      this.detachToggle();
    });
  }

  _initDraggable() {
    if (this._ui.wrapper.classList.contains('has-detached-help')) {
      this._draggable = new Draggable(this._ui.el, {
        handle: this._ui.dragHandle
      });
      this._draggable.on('dragend', (position)=>{
        UISettings.set('help-position', JSON.stringify(position));
      });
    }
    else if (this._draggable) {
      this._draggable.destroy();
    }
  }

  _initEditor() {
    const editButton = this._ui.el.querySelector('a.help-edit');
    if (!editButton) {
      return;
    }

    const helpContentId = editButton.getAttribute('data-help-content');
    const helpContentContainer = this._ui.el.querySelector('[data-help-container]');

    editButton.addEventListener('click', (e)=>{
      e.preventDefault();
      require.ensure('help_editor', (require)=>{
        const HelpEditor = require('help_editor');
        return new HelpEditor(helpContentId, helpContentContainer);
      });
    });
  }

  open(){
    this._ui.wrapper.classList.add('has-visible-help');
    UISettings.set('help-is-visible', true);
    NM.emit('toggled:help', true);
  }

  close() {
    this._ui.wrapper.classList.remove('has-visible-help');
    UISettings.set('help-is-visible', false);
    NM.emit('toggled:help', false);
  }

  toggle(){
    this._ui.wrapper.classList.toggle('has-visible-help');

    const state = this._ui.wrapper.classList.contains('has-visible-help');
    UISettings.set('help-is-visible', state);
    NM.emit('toggled:help', state);
  }

  detachToggle(){
    this._ui.wrapper.classList.toggle('has-detached-help');

    const state = this._ui.wrapper.classList.contains('has-detached-help');
    this._ui.detachToggler.innerHTML = this.getDetachTogglerLabel();

    this._initDraggable();

    UISettings.set('help-is-detached', state);
    NM.emit('toggled-attachment:help', state);
  }

  getDetachTogglerLabel() {
    const state = this._ui.wrapper.classList.contains('has-detached-help');
    return state ? 'Attach' : 'Detach';
  }
}

module.exports = Help;
