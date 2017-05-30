class ToodoolooRequireTosBeforeAuthWithProviders < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:toodooloo).each do |i|
          i.set_context!
          view_content = <<-BODY
{% query_graph 'login_providers', result_name: g %}

{% if g.login_providers.size > 0 %}
<form id="providers_service_buttons">
  <span id="service_buttons">
    {% for provider_name in g.login_providers %}
      {% assign provider = provider_name | downcase %}
      {% capture auth_url %}/auth/{{ provider }}?role={{ params.role }}{% endcapture %}
      <a class="btn btn-large {{ provider }} submit" id="{{ provider }}" href="{{ auth_url }}">
        <i class="icon ico-{{ provider }}"></i>
      </a>
    {% endfor %}
  </span>
  <p class="notice legal controlgroup">
    <label class="checkbox control checked" for="form_provider_accept_terms_of_service" data-custom-input-initialized="true">
      <span class="checkbox-icon-outer"><span class="checkbox-icon-inner"></span></span>
      <input type="checkbox" id="form_provider_accept_terms_of_service" value="1" class="input-block-level" checked="checked">
      confirm that you accept the <a href="/terms-of-use" rel="nofollow">Terms of Use</a> and <a href="/privacy-policy" rel="nofollow">Privacy Policy</a>.
    </label>
  </p>
  <p class="error-block hidden">
    must be accepted
  </p>
  <div class="hr divider">
    <span>or</span>
  </div>
</form>

<script>
  $('#service_buttons a').on('click', function(e) {
    if(!$('#form_provider_accept_terms_of_service')[0].checked){
      e.preventDefault();
      $('#providers_service_buttons .error-block').removeClass('hidden');
    }
  })
</script>
{% endif %}
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
    end
  end

  def down
  end
end
