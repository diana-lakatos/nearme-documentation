class UserBlogDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def image_preview(attribute_name)
    image_attribute = object.try(attribute_name.to_sym)
    if image_attribute && image_attribute.present?
      link_to image_attribute.url, target: '_blank' do
        image_tag image_attribute.url, width: 100, height: 100
      end
    end
  end
end
