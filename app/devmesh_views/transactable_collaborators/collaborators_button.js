$container = $("[data-collaborators-button]")
$container.html("<%= escape_javascript(render(partial: 'collaborators_button', locals: { project: @project })) %>")
$container.parent().find("[data-collaborators-count]").html(parseInt("<%= @collaborators_count %>"))
