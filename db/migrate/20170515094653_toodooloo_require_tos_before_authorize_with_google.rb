class ToodoolooRequireTosBeforeAuthorizeWithGoogle < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:toodooloo).each do |i|
      i.set_context!
      content = <<-BODY
        <div class="row">
  <div class="col-sm-6 col-sm-offset-3">
<form method="GET" action="/auth/google">
  <p class="checkbox-a ">
    <input type="checkbox" id="user_accept_terms_of_service"  class="input-block-level" required>
    <label for="user_accept_terms_of_service">
      Confirm that you accept the <a href="/terms-of-use" target="_blank">Terms of Use</a> and <a href="/privacy-policy" target="_blank">Privacy Policy</a>
    </label>
  </p>
  <div class="actions">
    <button type="submit" class="desksnearme submit btn btn-green" data-disable-with="Signing up...">
      Authorize with
      <i class="icon ico-google"></i>
    </button>
  </div>
</div>
</div>
</form>
            BODY
        Page.create!(path: 'Accept Terms of Service',
                      content:  content,
                      slug: 'auth-google-with-terms-of-service',
                      html_content:  content,
                      theme: i.theme,
                      no_layout: true,
                      layout_name: 'application')




        view_content = <<-BODY
<span id="service_buttons">
  <a class="btn btn-large google submit" id="google" href="/auth-google-with-terms-of-service">
    <i class="icon ico-google"></i>
  </a>
</span>
<div class="hr divider">
  <span>or</span>
</div>
        BODY
        iv = InstanceView.new(
          instance_id: i.id,
          view_type: 'view',
          partial: true,
          path: 'authentications/services',
          format: 'html',
          handler: 'liquid'
        )
        iv.locales << Locale.find_by(code: 'en')
        iv.body = view_content
        iv.save!
      end
    end
  end

  def down
    Instances::InstanceFinder.get(:toodooloo).each do |i|
      i.set_context!

      InstanceView.where(path: 'authentications/services').destroy_all
      Page.where(slug: 'auth-google-with-terms-of-service').destroy_all
  end
end
