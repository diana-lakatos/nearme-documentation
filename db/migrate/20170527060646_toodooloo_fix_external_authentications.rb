class ToodoolooFixExternalAuthentications < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:toodooloo).each do |i|
      i.set_context!
      view_content = <<-BODY
{% query_graph 'login_providers', result_name: g %}

<span id="service_buttons">
  {% for provider_name in g.login_providers %}
    {% assign provider = provider_name | downcase %}
    {% if provider == 'google' %}
      {% assign auth_url = '/auth-google-with-terms-of-service' %}
    {% else %}
      {% assign auth_url = '/auth/' | append: provider %}
    {% endif %}
    <a class="btn btn-large {{ provider }} submit" id="{{ provider }}" href="{{ auth_url }}">
      <i class="icon ico-{{ provider }}"></i>
    </a>
  {% endfor %}
</span>
<div class="hr divider">
  <span>or</span>
</div>
        BODY
      iv = InstanceView.where(
        instance_id: i.id,
        view_type: 'view',
        partial: true,
        path: 'authentications/services',
        format: 'html',
        handler: 'liquid'
      ).first
      iv.body = view_content
      iv.save!

  query = <<-QUERY
{
  login_providers
}
      QUERY

      i.graph_queries.create!(name: 'login_providers', query_string: query)
    end
  end

  def down
  end
end
