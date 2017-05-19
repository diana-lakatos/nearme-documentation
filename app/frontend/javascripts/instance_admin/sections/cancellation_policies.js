'use strict';

const PRICE_LIST = {
  'Total Price': 'order.total_amount_money.cents',
  'Items Price': 'order.subtotal_amount_money.cents',
  'Guest Service Gee': 'order.service_fee_amount_guest_money.cents',
  'Host Service Fee': 'order.service_fee_amount_guest_money.cents',
  'Shipping Fee': 'order.shipping_total_money.cents'
};
const CANCELLATION_CONDITIONS = window.cancellationConditions;

class CancellationPolicy {
  amountQuery: HTMLElement;
  conditionQuery: HTMLElement;

  actionType: HTMLElement;
  unitValue: HTMLElement;
  unit: HTMLElement;
  price: HTMLElement;
  conditions: Array;

  constructor(container: HTMLElement) {
    this.advanced = container.querySelector('.advanced');
    this.actionType = container.querySelector('[data-action-type]');
    this.toggleAdvanced = container.querySelector('[data-toggle-advanced]');
    this.amountQuery = container.querySelector('[data-amount-rule]');
    this.conditionQuery = container.querySelector('[data-condition]');
    this.unitValue = container.querySelector('[data-unit-value]');
    this.price = container.querySelector('[data-price]');
    this.conditions = container.querySelector('[data-conditions]');
    this.unitContainer = container.querySelector('[data-unit-container]');

    this.bindEvents();
  }

  bindEvents() {
    this.buildPriceSelect();
    this.buildConditionsSelect();
    this.disableQueryInputs(this.actionType);

    let matchUnitValue = this.amountQuery.value.match(/[+-]?\d+(\.\d+)?/g);
    this.unitValue.value = parseFloat((matchUnitValue || [ 0 ])[0]) * 100;

    // TODO remove jQuery together with Chosen
    jQuery(this.price).chosen().change(() => this.buildAmountQuery());
    jQuery(this.conditions).chosen().change(() => this.buildConditionQuery());
    this.unitValue.addEventListener('change', this.buildAmountQuery.bind(this), true);
    this.toggleAdvanced.addEventListener('click', event => {
      event.preventDefault();
      this.advanced.classList.toggle('hidden');
    });

    $(this.actionType).chosen().change(event => this.disableQueryInputs(event.target));
  }

  disableQueryInputs(target) {
    let queryInputs = [ this.amountQuery, this.unitValue, this.price ];

    if (target.value == 'cancel_allowed') {
      queryInputs.map(v => v.setAttribute('disabled', 'disabled'));
      queryInputs.map(v => v.parentNode.style.display = 'none');
      this.unitContainer.style.display = 'none';
    } else {
      queryInputs.map(v => v.removeAttribute('disabled'));
      queryInputs.map(v => v.parentNode.style.display = 'block');
      this.unitContainer.style.display = 'block';
    }
  }

  buildAmountQuery() {
    let percent = this.unitValue.value / 100;
    let price = $(this.price).chosen().val();

    this.amountQuery.value = `{{ ${price} | times: ${percent} }}`;
  }

  buildConditionQuery() {
    this.conditionQuery.value = `${this.selectedConditionsVariables()}{% if ${this.selectedConditionsQueries()} %}true{% endif %}`;
  }

  selectedConditionsQueries() {
    return this.selectedConditions().map(v => v['query']).join(' and ');
  }

  selectedConditionsVariables() {
    return this.selectedConditions().map(c => this.liquidVariables(c)).join('');
  }

  liquidVariables(condition) {
    return condition.variables.join('');
  }

  selectedConditions() {
    let selectedValues = $(this.conditions).chosen().val();

    if (selectedValues) {
      return selectedValues.map(con => CANCELLATION_CONDITIONS.find(v => v['id'] == con));
    } else {
      return [];
    }
  }

  buildPriceSelect() {
    Object.keys(PRICE_LIST).forEach(prop => {
      let priceOption = document.createElement('option');
      priceOption.text = prop;
      priceOption.value = PRICE_LIST[prop];
      priceOption.selected = this.amountQuery.value.includes(PRICE_LIST[prop]);
      this.price.appendChild(priceOption);
    });

    $(this.price).trigger('chosen:updated');
  }

  buildConditionsSelect() {
    CANCELLATION_CONDITIONS.forEach(prop => {
      let option = document.createElement('option');
      option.text = prop['name'];
      option.value = prop['id'];
      option.selected = this.conditionQuery.value.includes(prop['query']);
      this.conditions.appendChild(option);
    });

    $(this.conditions).trigger('chosen:updated');
  }
}

class InstanceAdminCancellationPoliciesController {
  cacnellationPolcicies: Array<CancellationPolicy>;
  form: HTMLFormElement;

  constructor(form: HTMLFormElement) {
    this.form = form;

    this.buildCancellationPolicies().then(policies => {
      this.cacnellationPolcicies = policies;
    });

    this.bindEvents();
  }

  bindEvents() {
    $(this.form).on('cocoon:after-insert', '.nested-fields-set', (e, fields) => {
      new CancellationPolicy(fields.get(0));
    });
  }

  buildCancellationPolicies(): Promise<Array<CancellationPolicy>> {
    let containers = this.form.getElementsByClassName('cancellation_policy_fields');

    let ps = [];

    Array.prototype.forEach.call(containers, (container: HTMLElement) => {
      ps.push(new CancellationPolicy(container));
    });

    return Promise.all(ps);
  }
}

module.exports = InstanceAdminCancellationPoliciesController;
