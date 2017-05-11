class FixSpacerCustomQuestionLayout < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:spacercom, :spacerau).each do |i|
      i.set_context!

      views = [
        {
          path: 'dashboard/user_messages/custom_question',
          body: <<-BODY
<div class="col-md-4 question">
  <label class="select required control-label" for="{{ question }}">
    {{ question | prepend: 'reservation_type.reservations.labels.' | t }}
  </label>
  <div class="controls">
    <select value="" class="form-control" name="{{ question }}" id="{{ question }}" style="width: 100%">
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
        iv = InstanceView.find_or_initialize_by(
          instance_id: i.id,
          view_type: 'view',
          partial: true,
          path: view[:path],
          format: 'html',
          handler: 'liquid',
          locale: nil
        )
        iv.body = view[:body]
        iv.save!
      end
    end
  end

  def down
  end
end
