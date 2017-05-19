var Modal,
  ShippingProfiles,
  bind = function(fn, me) {
    return function() {
      return fn.apply(me, arguments);
    };
  };

Modal = require('../../components/modal');

require('select2/select2');

ShippingProfiles = function() {
  function ShippingProfiles(form, profile_add_success) {
    this.profile_add_success = profile_add_success != null ? profile_add_success : false;
    this.setupZoneKind = bind(this.setupZoneKind, this);
    this.setupZoneInputs = bind(this.setupZoneInputs, this);
    this.modalSuccessActions = bind(this.modalSuccessActions, this);
    this.form = $(form);
    this.setupZoneInputs();
    this.setupZoneKind();
    this.setupShippingMethods();
    this.modalSuccessActions();
  }

  ShippingProfiles.prototype.modalSuccessActions = function() {
    var params, url, url_for_shipping_categories;
    if (this.profile_add_success) {
      Modal.close();
      params = { form: 'products' };
      url = location.href;
      if (!url.match(/\/dashboard\//)) {
        params['form'] = 'boarding';
      }
      url_for_shipping_categories = '/dashboard/shipping_categories/get_shipping_categories_list';
      if (url.match(/instance_admin/)) {
        url_for_shipping_categories = '/instance_admin/shipping_options/shipping_profiles/get_shipping_categories_list';
      }
      return jQuery.ajax({
        type: 'get',
        url: url_for_shipping_categories,
        data: params,
        success: function(data) {
          $('.shipping_method_block.shipping_method_list').empty();
          return $('.shipping_method_block.shipping_method_list').append(data);
        }
      });
    }
  };

  ShippingProfiles.prototype.setupZoneInputs = function() {
    var i, input, len, ref, results;
    ref = this.form.find('.select2');
    results = [];
    for (i = 0, len = ref.length; i < len; i++) {
      input = ref[i];
      results.push(
        $(input).select2({
          multiple: true,
          initSelection: function(element, callback) {
            var url;
            url = '/dashboard/api/' + $(input).attr('data-api') + '?ids=' + element.val();
            return $.getJSON(url, null, function(data) {
              return callback(data);
            });
          },
          ajax: {
            url: '/dashboard/api/' + $(input).attr('data-api'),
            datatype: 'json',
            data: function(term, page) {
              return { per_page: 50, page: page, q: { name_cont: term } };
            },
            results: function(data, page) {
              var more;
              more = page < data.pages;
              return { results: data, more: more };
            }
          },
          formatResult: function(country) {
            return country.name;
          },
          formatSelection: function(country) {
            return country.name;
          }
        })
      );
    }
    return results;
  };

  ShippingProfiles.prototype.setupZoneKind = function() {
    var that;
    that = this;
    this.form.find('.zone_kind_select').each(function() {
      return that.enableZoneSelect($(this));
    });
    that = this;
    return this.form.find('.zone_kind_select').change(function() {
      return that.enableZoneSelect($(this).parent().find('.zone_kind_select'));
    });
  };

  ShippingProfiles.prototype.enableZoneSelect = function(select) {
    if ($(select).val() === 'state_based') {
      $(select).closest('.state_based_select').parent().show();
      $(select).closest('.state_based_select').removeAttr('disabled');
      $(select).closest('.country_based_select').parent().hide();
      return $(select).closest('.country_based_select').attr('disabled', 'disabled');
    } else {
      $(select).closest('.country_based_select').parent().show();
      $(select).closest('.country_based_select').removeAttr('disabled');
      $(select).closest('.state_based_select').parent().hide();
      return $(select).closest('.state_based_select').attr('disabled', 'disabled');
    }
  };

  ShippingProfiles.prototype.setupShippingMethods = function() {
    var i, j, len, len1, ref, ref1, shipping_hidden, shipping_remove;
    this.form.find('.remove_shipping_profile:not(:first)').removeClass('hidden');
    ref = this.form.find('.shipping_hidden');
    for (i = 0, len = ref.length; i < len; i++) {
      shipping_hidden = ref[i];
      if ($(shipping_hidden).prop('checked')) {
        $(shipping_hidden).parents('.shipping_method_block').hide();
      }
    }
    this.form.find('.shipping_hidden').change(function() {
      if ($(this).prop('checked')) {
        return $(this).parents('.shipping_method_block').hide('slow');
      } else {
        return $(this).parents('.shipping_method_block').show('slow');
      }
    });
    ref1 = this.form.find('.remove_shipping');
    for (j = 0, len1 = ref1.length; j < len1; j++) {
      shipping_remove = ref1[j];
      if ($(shipping_remove).prop('checked')) {
        $(shipping_remove).parents('.shipping_method_block').hide();
      }
    }
    this.form.find('.remove_shipping').change(function() {
      if ($(this).prop('checked')) {
        return $(this).parents('.shipping_method_block').hide('slow');
      }
    });
    return this.form.find('.add_shipping_profile').click(
      function(_this) {
        return function() {
          _this.form
            .find('.shipping_hidden:checked')
            .eq(0)
            .prop('checked', false)
            .trigger('change');
          if (_this.form.find('.shipping_hidden:checked').length === 0) {
            return _this.form.find('.add_shipping_profile').hide();
          }
        };
      }(this)
    );
  };

  return ShippingProfiles;
}();

module.exports = ShippingProfiles;
