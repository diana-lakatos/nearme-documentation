function formSubmitter() {
  Array.prototype.forEach.call(document.querySelectorAll('[data-submit-form]'), (trigger) => {
    trigger.addEventListener('click', (event)=>{
      if (event.defaultPrevented) {
        return;
      }

      event.preventDefault();
      document.querySelector(trigger.dataset.submitForm).submit();
    });
  });
}

module.exports = formSubmitter;
