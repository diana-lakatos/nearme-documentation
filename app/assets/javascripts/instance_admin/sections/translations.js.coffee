jQuery ->
  $('#translations-table').DataTable({
    'ordering': false,
    'info': false,
    'paging': false
    'dom': '<"col-xs-10"f'
  })

jQuery ->
  $("form[data-edit=keys").on 'submit', ->
    $('#translations-table').DataTable().search('').columns().search('').draw()
    true
