# frozen_string_literal: true
class RequestPreviewConfiguration < ActiveRecord::Migration
  class SpacerPreviewRequestCreator < Utils::DefaultAlertsCreator::WorkflowCreator
    def create_preview_request_created_api!
      create_alert!(
        associated_class: WorkflowStep::CustomizationWorkflow::Created,
        name: 'create_preview_request_api',
        alert_type: 'api_call',
        recipient_type: 'Administrator',
        endpoint: 'https://hooks.slack.com/services/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'
      )
    end

    protected

    def workflow_type
      'customization_workflow'
    end
  end

  def up
    Instances::InstanceFinder.get(:spacerau, :spacercom).each do |i|
      i.set_context!

      cmt = CustomModelType.create!(
        name: 'Preview Request Form',
        parameterized_name: 'preview_request_form',
        custom_attributes: [
          CustomAttributes::CustomAttribute.new(
            name: 'message',
            attribute_type: 'string',
            html_tag: 'input',
            search_in_query: false,
            label: 'Message',
            searchable: false,
            input_html_options: {}
          ),
          CustomAttributes::CustomAttribute.new(
            name: 'transactable_id',
            attribute_type: 'integer',
            html_tag: 'hidden',
            search_in_query: false,
            searchable: false,
            input_html_options: {}
          ),
          CustomAttributes::CustomAttribute.new(
            name: 'date_of_visit',
            attribute_type: 'string',
            html_tag: 'input',
            search_in_query: false,
            searchable: false,
            input_html_options: {}
          ),
          CustomAttributes::CustomAttribute.new(
            name: 'time_of_visit',
            attribute_type: 'string',
            html_tag: 'input',
            search_in_query: false,
            searchable: false,
            input_html_options: {}
          )
        ]
      )

      content = <<-eos
       <main id=\"main\">
         <div class=\"container\">
           {% if current_user %}
             <h2>Request to Inspect Space</h2>
             {% render_form preview_request_form, object_class: 'Customization', parent_object_class: 'CustomModelType', parent_object_id: 'preview_request_form', object_id: 'new', input_html-rows: 20 %}
           {% endif %}
        </div>
       </main>
       eos

      page = Page.create!(path: 'Request to inspect space',
                          content:  content,
                          slug: 'request-to-inspect-space',
                          html_content:  content,
                          theme: i.theme,
                          no_layout: true,
                          layout_name: '')

      template = <<-eos
      {% if params.transactable_id %}
        {% query_graph 'get_transactable_by_id', result_name: g, id: params.transactable_id %}
          <div>
            {% form_for form, url: '/api/user/customizations.html', as: customization, form_for_type: 'dashboard', html-data-modal: true %}
              <input value="{{ form_configuration.id }}" type="hidden" name="form_configuration_id" />
              <input value="{{ page.id }}" type="hidden" name="page_id" />
              <input value="{{ g.transactable.show_path }}" type="hidden" name="return_to" />
              <input value="{{ form.custom_model_type_id }}" type="hidden" name="custom_model_type_id" />
              <input value="{{ g.transactable.id }}" type="hidden" name="transactable_id" />
              {% fields_for properties, form: refer_a_friend %}
                {% assign t_id = g.transactable.id %}
                {% input transactable_id, as: hidden, form: properties, input_html-value: @t_id %}
                {% input message, as: limited_text, form: properties, label: 'Your message' %}
                {% input date_of_visit, form: properties, label: 'Date of your visit' %}
                {% input time_of_visit, form: properties, label: 'Time of your visit' %}
              {% endfields_for %}

              <div class='user-profile__form-actions'>
                {% submit 'Send', class: 'button-a button-lg', data-disable-with: 'Sending...' %}
              </div>
            {% endform_for %}
          </div>
        {% endif %}
      eos
      workflow_alert = SpacerPreviewRequestCreator.new.create_preview_request_created_api!
      workflow_alert.update_attributes!(
        use_ssl: true,
        request_type: 'POST',
        prevent_trigger_condition: '',
        payload_data: '{"text": " ---- New Preview Request  --- \n\n *Date of visit:* {{customization.properties.date_of_visit}}\n *Time of visit* {{ customization.properties.time_of_visit }} \n *Message:* {{ customization.properties.message }} \n*Listing:* {% query_graph "get_transactable_by_id", result_name: g, id: {{customization.properties.transactable_id}} %}{{ g.transactable.name }}"}'
      )
      workflow_alert.workflow_step.update_attributes!(name: 'Preview Request Created')

      FormConfiguration.create!(name: 'preview_request_form',
                                base_form: 'CustomizationForm',
                                workflow_steps: [workflow_alert.workflow_step],
                                liquid_body: template,
                                configuration: {
                                  properties: {
                                    message: {
                                      validation: {}
                                    },
                                    transactable_id: {
                                      validation: {}
                                    },
                                    date_of_visit: {
                                      validation: {
                                        presence: true
                                      }
                                    },
                                    time_of_visit: {
                                      validation: {
                                        presence: true
                                      }
                                    }
                                  }
                                })

      query = <<-eos
        query get_transactable_by_id($id: ID!) {
          transactable(id: $id) {
            id
            name
            show_path
          }
        }
      eos
      GraphQuery.create!(name: 'get_transactable_by_id', query_string: query)

      Translation.create!(locale: 'en',
                          key: 'flash.api.user.customizations.preview_request_form.notice',
                          value: 'Request to inspect space successfully created.',
                          instance_id: i.id)
    end
  end

  def down
    Instances::InstanceFinder.get(:spacerau, :spacercom).each do |i|
      i.set_context!
      Page.find_by(slug: 'request-to-inspect-space').try(:destroy)
      CustomModelType.find_by(parameterized_name: 'preview_request_form').try(:destroy)
      FormConfiguration.find_by(name: 'preview_request_form').try(:destroy)
      GraphQuery.find_by(name: 'get_transactable_by_id').try(:destroy)
      WorkflowStep.find_by(name: 'Preview Request Created').try(:destroy)
      Translation.find_by(key: 'flash.api.user.customizations.preview_request_form.notice').try(:destroy)
    end
  end
end
