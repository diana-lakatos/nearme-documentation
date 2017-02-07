const Events = require('minivents/dist/minivents.commonjs');

class ActionableEntryCreateAction {
  constructor(container) {
    this.container = container;

    new Events(this);

    this.formContainer = container.querySelector('[data-creatable-form]');
    this.target = container.querySelector('form');
    this.trigger = container.dataset.triggerEvent;

    this.bindEvents();
  }

  bindEvents(){
    this.target.addEventListener('submit', this.handleFormSubmit.bind(this), true);
  }

  handleFormSubmit(event){
    if (event.defaultPrevented) {
      return;
    }
    event.preventDefault();

    let form = event.target;
    let target = this.target;
    let trigger = this.trigger;

    $.ajax({
      url: form.action,
      method: 'POST',
      data: new FormData(form),
      dataType: 'html',
      contentType: false,
      cache: false,
      processData: false
    }).done((html)=>{
      this.formContainer.classList.remove('is-active');
      this.container.innerHTML = this.container.innerHTML + html;
      if(trigger){
        $(document).trigger(trigger);
      }
    }).fail(()=>{
      alert(`We couldn’t create this content. Please try again`);
      throw new Error(`Unable to create content ${form.action}`);
    });
  }
}

module.exports = ActionableEntryCreateAction;
