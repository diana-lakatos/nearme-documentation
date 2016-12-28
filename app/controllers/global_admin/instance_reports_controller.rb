class GlobalAdmin::InstanceReportsController < GlobalAdmin::BaseController

  def show
  end

  def download_urls
    csv = CSV.generate do |csv|
      csv << ['Instance', 'URL']

      Instance.order('id ASC').each do |instance|
        domains = instance.domains

        www_regexp = /^www/i
        near_me_regexp = /\.near-me\./i
        domains = domains.sort do |domain1, domain2|
          if domain1.secured? && !domain2.secured?
            -1
          elsif !domain1.secured? && domain2.secured?
            +1
          elsif domain1.name.match(www_regexp) && !domain2.name.match(www_regexp)
            -1
          elsif !domain1.name.match(www_regexp) && domain2.name.match(www_regexp)
            +1
          elsif domain1.name.match(near_me_regexp) && !domain2.name.match(near_me_regexp)
            +1
          elsif !domain1.name.match(near_me_regexp) && domain2.name.match(near_me_regexp)
            -1
          else
            domain1.name.length <=> domain2.name.length
          end
        end

        chosen_domain = domains.first
        chosen_domain_url = chosen_domain.name
        if chosen_domain.secured?
          chosen_domain_url = "https://" + chosen_domain_url
        else
          chosen_domain_url = "http://" + chosen_domain_url
        end

        values = [instance.name, chosen_domain_url]

        csv << values
      end
    end

    respond_to do |format|
      format.csv { send_data csv }
    end
  end

end

