# frozen_string_literal: true
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  config.wrappers :admin_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label

    b.use :input, class: 'form-control'
    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_addon, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label

    b.wrapper tag: 'div', class: 'input-group' do |ba|
      ba.optional :prefix, wrap_with: { tag: 'div', class: 'input-group-addon' }
      ba.use :input, class: 'form-control'
      ba.optional :suffix, wrap_with: { tag: 'div', class: 'input-group-addon' }
    end

    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_file_input, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :readonly
    b.use :label

    b.use :input
    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_boolean, tag: 'div', class: 'form-group', boolean_style: :inline, error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly

    b.wrapper tag: 'div', class: 'checkbox' do |ba|
      ba.use :label_input
    end

    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_switch, tag: 'div', class: 'form-group', boolean_style: :inline, error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly

    b.use :input
    b.use :label

    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_radio_and_checkboxes, tag: 'div', class: 'form-group', boolean_style: :inline, error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label
    b.use :input
    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_select, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label

    b.wrapper tag: 'div', class: 'select-wrapper' do |ba|
      ba.use :input, class: 'form-control'
    end
    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  config.wrappers :admin_combobox, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
    b.use :html5
    b.optional :readonly
    b.use :label

    b.wrapper tag: 'div', class: 'combobox-wrapper' do |ba|
      ba.use :input, class: 'form-control'
    end
    b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
    b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  end

  # config.wrappers :admin_inline_form, tag: 'div', class: 'form-group', error_class: 'has-error' do |b|
  #   b.use :html5
  #   b.use :placeholder
  #   b.optional :maxlength
  #   b.optional :pattern
  #   b.optional :min_max
  #   b.optional :readonly
  #   b.use :label, class: 'sr-only'

  #   b.use :input, class: 'form-control'
  #   b.use :error, wrap_with: { tag: 'strong', class: 'form-error' }
  #   b.use :hint,  wrap_with: { tag: 'p', class: 'hint help-block' }
  # end
end
