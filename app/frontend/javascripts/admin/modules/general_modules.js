function initGeneralModules(context = document) {
  (function(context) {
    let collapsibleSwitches = context.querySelectorAll('input[type=checkbox][aria-controls]');

    if (collapsibleSwitches.length === 0) {
      return;
    }

    require.ensure('collapsible', require => {
      let Collapsible = require('collapsible');

      Array.prototype.forEach.call(collapsibleSwitches, el => new Collapsible(el));
    });
  })(context);

  (function(context) {
    let forms = context.querySelectorAll('form[data-confirm]');
    if (forms.length === 0) {
      return;
    }

    require.ensure('form_confirm', require => {
      let FormConfirm = require('form_confirm');
      Array.prototype.forEach.call(forms, form => {
        return new FormConfirm(form);
      });
    });
  })(context);

  /* Password strength input */
  (function(context) {
    let togglers = context.querySelectorAll('button[data-toggle-password]');
    if (togglers.length === 0) {
      return;
    }

    require.ensure('forms/custom_inputs/password_strength', require => {
      let PasswordStrengthInput = require('forms/custom_inputs/password_strength');
      Array.prototype.forEach.call(togglers, input => {
        return new PasswordStrengthInput(input);
      });
    });
  })(context);

  /* Combo boxes */
  (function(context) {
    let inputs = context.querySelectorAll('select.combobox');
    if (inputs.length === 0) {
      return;
    }

    require.ensure('forms/custom_inputs/combobox', require => {
      let Combobox = require('forms/custom_inputs/combobox');
      Array.prototype.forEach.call(inputs, input => {
        return new Combobox(input);
      });
    });
  })(context);

  /* Code Editor */
  (function(context) {
    let inputs = context.querySelectorAll('textarea.code_editor');
    if (inputs.length === 0) {
      return;
    }
    require.ensure('forms/custom_inputs/code_editor', require => {
      let CodeEditor = require('forms/custom_inputs/code_editor');
      Array.prototype.forEach.call(inputs, input => {
        return new CodeEditor(input, input.getAttribute('data-syntax'));
      });
    });
  })(context);

  /* Image input */
  (function(context) {
    let inputs = context.querySelectorAll('input[data-image-input]');
    if (inputs.length === 0) {
      return;
    }
    require.ensure('forms/custom_inputs/image_input', require => {
      let ImageInput = require('forms/custom_inputs/image_input');
      Array.prototype.forEach.call(inputs, input => {
        return new ImageInput(input);
      });
    });
  })(context);

  let NotificationsController = require('notifications_controller');
  NotificationsController.createNotificationsFromDOM();

  (function(context) {
    let forms = context.querySelectorAll('form.nm-form');
    if (forms.length === 0) {
      return;
    }

    require.ensure('forms/nm_form', require => {
      let NMForm = require('forms/nm_form');
      Array.prototype.forEach.call(forms, form => {
        return new NMForm(form);
      });
    });
  })(context);
}

module.exports = initGeneralModules;
