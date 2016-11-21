# frozen_string_literal: true
class UpdateUotFavoriteButtons < ActiveRecord::Migration
  def up
    i = Instance.find(195)
    i.set_context!
    search_list_from = "                                <div data-add-favorite-button=\"true\" data-path=\"{{ user.wish_list_path }}\" data-wishlistable-type=\"{{ user.class_name }}\" data-link-to-classes=\"{{ link_to_classes }}\" data-path-bulk=\"{{ user.wish_list_bulk_path }}\" data-object-id=\"{{ user.id }}\" id=\"favorite-button-{{ user.class_name }}-{{ user.id }}\">\n                                  <div class=\"text-center\"><img src=\"{{ 'components/modal/loader.gif' | image_url }}\" /></div>\n                                </div>"
    search_list_to   = "                                {% include 'shared/components/wish_list_button_injection', object: user, link_to_classes: 'button-b action-favorite' %}"

    registration_show_from = "                        <div data-add-favorite-button=\"true\" data-path=\"{{ user.wish_list_path }}\" data-wishlistable-type=\"{{ user.class_name }}\" data-link-to-classes=\"{{ link_to_classes }}\" data-path-bulk=\"{{ user.wish_list_bulk_path }}\" data-object-id=\"{{ user.id }}\" id=\"favorite-button-{{ user.class_name }}-{{ user.id }}\">\n                          <div class=\"text-center\"><img src=\"{{ 'components/modal/loader.gif' | image_url }}\" /></div>\n                        </div>"
    registration_show_to   = "                        {% include 'shared/components/wish_list_button_injection', object: user, link_to_classes: 'button-b action-favorite' %}"

    search_list_template = InstanceView.where(instance_id: i.id, path: 'search/list', partial: false, format: 'html', handler: 'liquid').first
    search_list_template.update_column :body, search_list_template.body.gsub(search_list_from, search_list_to)
    puts "\tupdating UoT search/list template"

    registration_show_template = InstanceView.where(instance_id: i.id, path: 'registrations/show', partial: false, format: 'html', handler: 'liquid').first
    registration_show_template.update_column :body, registration_show_template.body.gsub(registration_show_from, registration_show_to)
    puts "\tupdating UoT registration/show template"
  end

  def down
  end
end
