module.exports = {
    load: function(element) {
        element = element || '[data-add-favorite-button]';

        $(element).each(function(index, item){
            var container = $(item);
            var data = {
                'object_type': container.data('object-type'),
                'link_to_classes': container.data('link-to-classes')
            };
            $.get(container.data('path'), data, function(response){
                $(container).html(response);
            });
        });
    },

    init: function(element, event) {
        $(element).find('[data-action-link]').on('click', function(event){
            $.ajax({
                url: $(this).attr('href'),
                method: $(this).data('method'),
                dataType: "script"
            });
            event.preventDefault();
            return false;
        });
    }
}
