module LinksHelper

  def set_links_creator_id(link_owner)
    link_owner.links.each do |link|
      if !link.persisted?
        link.creator = current_user
      end
    end
  end

end

