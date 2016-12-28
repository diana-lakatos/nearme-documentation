class SideNavigation {
  constructor(){
    this.navs = document.querySelectorAll('.select-navigation > ul');
    if (this.navs.length === 0) {
      return;
    }

    this.createSelects();
    this.bound = {};
    this.bindEvents();
  }
  createSelects(){
    let selects = [];
    Array.prototype.forEach.call(this.navs, (el)=>{
      let select = document.createElement('select');
      Array.prototype.forEach.call(el.querySelectorAll('li a'), (item)=>{
        let option = document.createElement('option');
        option.value = item.getAttribute('href');
        option.innerHTML = item.innerHTML;
        if (item.classList.contains('selected')) {
          option.setAttribute('selected','selected');
        }
        select.appendChild(option);
      });

      selects.push(select);
      el.parentNode.insertBefore(select, el);
    });

    this.selects = selects;
  }
  bindEvents(){
    this.selects.forEach((select)=>{
      select.addEventListener('change', (e)=>{
        window.location = e.target.value;
      });
    });
  }
}

module.exports = SideNavigation;
