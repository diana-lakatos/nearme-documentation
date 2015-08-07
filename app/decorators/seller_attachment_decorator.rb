class SellerAttachmentDecorator < Draper::Decorator
  include Draper::LazyHelpers

  delegate_all

  def title
    object.title.presence || object.data_file_name
  end
end
