class UserDecorator < Draper::Decorator
  delegate_all

  def job_title_and_company_name
    result = []
    result << job_title
    result << company_name
    result.join(" at ")
  end

  def current_location_and_industry
    result = []
    result << current_location
    result << industries.map(&:name).join(", ")
    result.join(" | ")
  end

end
