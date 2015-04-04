jQuery ->
  $('#translations-table').DataTable({
    'ordering': false,
    'info': false,
    'paging': false,
    'dom': '<"col-xs-10"f'
  })

jQuery ->
  $("form[data-edit=keys]").on 'submit', ->
    $('#translations-table').DataTable().search('').columns().search('').draw()
    true

jQuery ->
  select = $("form[id=new_locale] select")
  select.on 'change', ->
    translated_name = $("select :selected").data('translated')
    $('#locale_custom_name').val(translated_name)
