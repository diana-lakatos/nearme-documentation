class Combobox {
  constructor(input, options = {}) {
    this.input = input;
    this.inputOptions = this.input.querySelectorAll('option');

    this.wrapper = this.input.parentNode;

    this.data = Array.prototype.map.call(this.inputOptions, option => {
      return {
        value: option.value || option.innerText,
        label: option.innerText,
        selected: !!option.selected
      };
    });

    /* Do not store prompt values */
    this.data = this.data.filter(item => item.value);

    let defaultOptions = {
      labelUseAll: 'Use all',
      labelUseOne: 'Use',
      labelRemoveOne: 'Remove',
      labelRemoveAll: 'Remove all'
    };

    this.options = Object.assign({}, defaultOptions, options);

    this.build();
    this.bindEvents();
  }

  build() {
    this.ui = {};

    function populateSelect(select, item, isUsed) {
      let option = document.createElement('option');
      option.value = item.value;
      option.innerText = item.label;
      this.setOptionState(option, item.selected === isUsed);
      select.appendChild(option);
    }

    /* unused options box */
    let unusedSelect = document.createElement('select');
    unusedSelect.classList.add('combobox-select', 'combobox-select-unused');
    unusedSelect.multiple = true;

    let unusedWrapper = document.createElement('div');
    unusedWrapper.classList.add('combobox-select-wrapper', 'combobox-select-wrapper-unused');
    unusedWrapper.appendChild(unusedSelect);

    /* used options box */
    let usedSelect = document.createElement('select');
    usedSelect.classList.add('combobox-select', 'combobox-select-used');
    usedSelect.multiple = true;

    let usedWrapper = document.createElement('div');
    usedWrapper.classList.add('combobox-select-wrapper', 'combobox-select-wrapper-used');
    usedWrapper.appendChild(usedSelect);

    this.data.forEach(item => {
      populateSelect.call(this, unusedSelect, item, false);
      populateSelect.call(this, usedSelect, item, true);
    });

    this.wrapper.appendChild(unusedWrapper);
    this.ui.unusedSelect = unusedSelect;

    this.wrapper.appendChild(usedWrapper);
    this.ui.usedSelect = usedSelect;

    /* navigation */
    let nav = document.createElement('div');
    nav.classList.add('combobox-nav');

    let useAllButton = document.createElement('button');
    useAllButton.classList.add('combobox-action', 'combobox-action-use-all');
    useAllButton.type = 'button';
    useAllButton.innerText = this.options.labelUseAll;
    nav.appendChild(useAllButton);
    this.ui.useAllButton = useAllButton;

    let useOneButton = document.createElement('button');
    useOneButton.classList.add('combobox-action', 'combobox-action-use-one');
    useOneButton.type = 'button';
    useOneButton.innerText = this.options.labelUseOne;
    nav.appendChild(useOneButton);
    this.ui.useOneButton = useOneButton;

    let removeOneButton = document.createElement('button');
    removeOneButton.classList.add('combobox-action', 'combobox-action-remove-one');
    removeOneButton.innerText = this.options.labelRemoveOne;
    removeOneButton.type = 'button';
    nav.appendChild(removeOneButton);
    this.ui.removeOneButton = removeOneButton;

    let removeAllButton = document.createElement('button');
    removeAllButton.classList.add('combobox-action', 'combobox-action-remove-all');
    removeAllButton.innerText = this.options.labelRemoveAll;
    removeAllButton.type = 'button';
    nav.appendChild(removeAllButton);
    this.ui.removeAllButton = removeAllButton;

    this.wrapper.appendChild(nav);
  }

  setOptionState(option, state) {
    if (state) {
      return option.classList.add('combobox-selected');
    }
    return option.classList.remove('combobox-selected');
  }

  selectAllOptions(select) {
    Array.prototype.forEach.call(
      select.querySelectorAll('option'),
      option => option.selected = true
    );
  }

  bindEvents() {
    this.ui.useAllButton.addEventListener('click', () => {
      this.selectAllOptions(this.ui.unusedSelect);
      this.moveSelected(this.ui.unusedSelect, this.ui.usedSelect);
    });

    this.ui.useOneButton.addEventListener('click', () => {
      this.moveSelected(this.ui.unusedSelect, this.ui.usedSelect);
    });

    this.ui.removeOneButton.addEventListener('click', () => {
      this.moveSelected(this.ui.usedSelect, this.ui.unusedSelect);
    });

    this.ui.removeAllButton.addEventListener('click', () => {
      this.selectAllOptions(this.ui.usedSelect);
      this.moveSelected(this.ui.usedSelect, this.ui.unusedSelect);
    });

    this.ui.usedSelect.addEventListener('keydown', e => {
      if (e.which === 13) {
        e.preventDefault();
        this.moveSelected(this.ui.usedSelect, this.ui.unusedSelect);
      }
    });

    this.ui.unusedSelect.addEventListener('keydown', e => {
      if (e.which === 13) {
        e.preventDefault();
        this.moveSelected(this.ui.unusedSelect, this.ui.usedSelect);
      }
    });
  }

  moveSelected(fromSelect, toSelect) {
    let toOptions = toSelect.querySelectorAll('option');

    Array.prototype.forEach.call(fromSelect.querySelectorAll('option'), (option, index) => {
      if (option.selected) {
        this.setOptionState(toOptions[index], true);
        this.setOptionState(option, false);
        toOptions[index].selected = true;
        option.selected = false;
      }
    });

    this.syncInput();
  }

  syncInput() {
    /* clear current selection */
    this.input.value = null;

    Array.prototype.forEach.call(this.ui.usedSelect.querySelectorAll('option'), (option, index) => {
      this.inputOptions[index].selected = option.selected;
    });
  }
}

module.exports = Combobox;
