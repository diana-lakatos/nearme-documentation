# frozen_string_literal: true
module LinksHelper
  def set_links_creator_id(link_owner)
    link_owner.links.each do |link|
      link.creator = current_user unless link.persisted?
    end
  end
end
