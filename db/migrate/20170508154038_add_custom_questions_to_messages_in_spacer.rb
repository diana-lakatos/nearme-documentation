class AddCustomQuestionsToMessagesInSpacer < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!

      views = [
        {
          path: 'dashboard/user_messages/form',
          body: <<-BODY
{% query_graph 'reservation_custom_attributes', result_name: g %}

<div class="new-user-message-container">
  <header class="dialog__header">
    <h2 id="dialog__title">
      {{ 'user_messages.send_a_message_to' | translate: recipient_name: user_message.recipient_name }}
    </h2>
  </header>

  <form novalidate="novalidate" class="simple_form new_user_message" id="new_user_message" data-modal="true" action="{{ user_message.create_path }}" accept-charset="UTF-8" method="post">
    <input name="authenticity_token" data-authenticity-token="1" type="hidden">
    <div class="dialog__body">
      <div class="row custom-questions">
        <div class="form-group">
          {% include 'dashboard/user_messages/custom_question', g: g, question: 'how_long_do_you_need_the_space' %}
          {% include 'dashboard/user_messages/custom_question', g: g, question: 'how_often_will_you_be_visiting' %}
          {% include 'dashboard/user_messages/custom_question', g: g, question: 'what_will_you_be_storing' %}
        </div>
      </div>
      <div class="form-group text required user_message_body">
        <label class="text required control-label control-label" for="user_message_body">
          <abbr title="required">*</abbr>
          {{ 'simple_form.labels.user_message.body' | translate }}
        </label>
        <textarea class="text required form-control" placeholder="{{ 'simple_form.placeholders.user_message.body' | translate }}" name="user_message[body]" id="user_message_body"></textarea>
        {% if error %}
          <span class="help-block">{{ error }}</span>
        {% endif %}
      </div>
    </div>
    <div class="dialog__actions">
      <input type="submit" name="commit" value="{{ 'user_messages.send_message' | translate }}" class="btn btn-green">
    </div>
  </form>
</div>

<script type="text/javascript">
  function copyAnswerToBody(e) {
    var form = $(e.target);
    form.find('.custom-questions .question').each(function(){
      var answer = $(this).find('select').val();
      if (answer){
        var body = form.find('textarea');
        var label = $(this).find('label').text();
        body.val(body.val() + ' ' + label + ': ' + answer);
      }
    });
  };

  $(document).trigger('modal-shown.nearme', $('.new-user-message-container'));
  $('form.new_user_message').on('submit', copyAnswerToBody);
</script>
          BODY
        },
        {
          path: 'dashboard/user_messages/custom_question',
          body: <<-BODY
<div class="col-md-4 question">
  <label class="select required control-label" for="{{ question }}">
    {{ question | prepend: 'reservation_type.reservations.labels.' | t }}
  </label>
  <div class="controls">
    <select value="" class="form-control" name="{{ question }}" id="{{ question }}">
      <option value="">Please select</option>
      {% for value in g[question].valid_values %}
        <option value="{{ value }}">{{ value }}</option>
      {% endfor %}
    </select>
  </div>
</div>
          BODY
        }
      ]

      views.each do |view|
        iv = InstanceView.new(
          instance_id: i.id,
          view_type: 'view',
          partial: true,
          path: view[:path],
          format: 'html',
          handler: 'liquid'
        )
        iv.locales << Locale.find_by(code: 'en')
        iv.body = view[:body]
        iv.save!
      end
    end
  end

  def down
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!

      InstanceView.where(path: ['dashboard/user_messages/form', 'dashboard/user_messages/custom_question'], instance_id: i.id)
                  .destroy_all
    end
  end
end
