const Events = require('minivents/dist/minivents.commonjs');

class ActionableEntryEditAction {
  constructor(trigger, container) {
    new Events(this);

    this.trigger = trigger;

    this.target = container.querySelector('.entry-content-a');
    this.container = container;

    if (!this.target) {
      return;
    }

    this.bindEvents();
  }

  bindEvents(){
    this.trigger.addEventListener('click', (e)=>{
      e.preventDefault();
      this.toggleEditor();
    });

    this.target.addEventListener('submit', this.handleFormSubmit.bind(this), true);
  }

  toggleEditor(){
    this.emit('toggle');
    if (this.target.classList.contains('is-active')) {
      return this.hideEditor();
    }
    this.showEditor();
  }

  hideEditor(){
    this.target.classList.remove('is-active');
  }

  showEditor(){
    this.target.classList.add('is-active');
    this.target.querySelector('textarea').focus();
  }

  handleFormSubmit(event){
    if (event.defaultPrevented) {
      return;
    }
    event.preventDefault();

    let form = event.target;
    let target = this.target;

    $.ajax({
      url: form.action,
      method: form.method,
      data: $(form).serialize(),
      dataType: 'html'
    }).done((html)=>{
      target.classList.remove('is-active');
      target.innerHTML = html;
    }).fail(()=>{
      alert('We couldn’t update content of this entry. Please try again');
      throw new Error(`Unable to edit comment at ${form.action}`);
    });
  }
}

module.exports = ActionableEntryEditAction;
