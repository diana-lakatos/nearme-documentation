# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

class CustomProfileUserSignupBuilderTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    CustomAttributes::CustomAttribute.destroy_all
    driver_profile_type = FactoryGirl.create(:instance_profile_type, name: 'Driver', profile_type: 'driver')

    FactoryGirl.create(:custom_attribute, name: 'driver_attr', target: driver_profile_type)
    @driver_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'driver_photo', target: driver_profile_type)
    @driver_attachment = FactoryGirl.create(:custom_attribute, attribute_type: 'file', name: 'driver_attachment', target: driver_profile_type)

    category = FactoryGirl.create(:category, name: 'Driver Category',
                                             multiple_root_categories: true,
                                             instance_profile_types: [driver_profile_type])
    @driver_sub_cat = FactoryGirl.create(:category, name: 'Driver Sub Cat 1', parent: category)
    @driver_sub_cat2 = FactoryGirl.create(:category, name: 'Driver Sub Cat 2', parent: category)

    model = FactoryGirl.create(:custom_model_type, name: 'Reviews', instance_profile_types: [driver_profile_type])
    FactoryGirl.create(:custom_attribute, name: 'author', target: model)
    FactoryGirl.create(:custom_attribute, name: 'body', target: model)

    model = FactoryGirl.create(:custom_model_type, name: 'Driver Model', instance_profile_types: [driver_profile_type])
    FactoryGirl.create(:custom_attribute, name: 'driver_model_attr', target: model)

    @lister_user_signup_builder = FormBuilder.new(base_form: UserForm,
                                                  configuration: configuration,
                                                  object: User.new).build
  end

  should 'correctly validate empty params' do
    @lister_user_signup_builder.prepopulate!
    refute @lister_user_signup_builder.validate({})
    messages = [
      "Profiles driver properties driver attr can't be blank",
      "Profiles driver custom images #{@driver_photo.name.humanize.downcase} image can't be blank",
      "Profiles driver custom attachments #{@driver_attachment.name.humanize.downcase} file can't be blank",
      "Profiles driver categories driver category can't be blank",
    ]
    messages.each do |message|
      assert_includes @lister_user_signup_builder.errors.full_messages, message
    end
  end

  should 'be able to save all parameters' do
    assert @lister_user_signup_builder.validate(parameters), @lister_user_signup_builder.errors.full_messages.join(', ')
    assert_difference 'User.count' do
      @lister_user_signup_builder.save
    end
    @user = User.last
    assert_equal 'Maciej', @user.name

    driver_profile = user_profile(@user, 'driver')
    assert driver_profile.enabled
    assert_equal 'my driver value', driver_profile.properties.driver_attr
    assert_equal [@driver_sub_cat.id, @driver_sub_cat2.id], driver_profile.categories.pluck(:id).sort
    assert_equal [{ 'driver_model_attr' => 'my first value' }],
                 driver_profile.customizations.map { |c| c.properties.to_h }
    assert_equal ['bully.jpeg'], driver_profile.custom_images.pluck(:image)
  end

  protected

  def parameters
    {
      'name' => 'Maciej',
      'email' => 'maciej@example.com',
      'password' => 'this is very long and secure password',
      'profiles_attributes' => {
        'driver_attributes' => {
          'enabled' => '1',
          :properties => {
            'driver_attr' => 'my driver value'
          },
          custom_images: {
            :"#{@driver_photo.name}" => {
              image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
            }
          },
          custom_attachments: {
            :"#{@driver_attachment.name}" => {
              file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
            }
          },
          :categories => {
            'Driver Category' => [@driver_sub_cat.id, @driver_sub_cat2.id]
          },
          :customizations => {
            'driver_model_attributes' => {
              '0' => { properties: { driver_model_attr: 'my first value' } }
            }
          }
        }
      }
    }
  end

  def configuration
    {
      'name' => {},
      profiles: {
        driver: {
          'enabled' => {},
          :properties => {
            'driver_attr' => {
              validation: {
                'presence' => {}
              }
            }
          },
          :custom_images => {
            "#{@driver_photo.name}": {
              validation: {
                'presence' => {}
              }
            }
          },
          :custom_attachments => {
            "#{@driver_attachment.name}": {
              validation: {
                'presence' => {}
              }
            }
          },
          :categories => {
            'Driver Category' => {
              validation: {
                presence: true
              }
            }
          },
          :customizations => {
            'driver_model' => {
              properties: {
                'driver_model_attr' => {
                  validation: {
                    'presence' => {}
                  }
                }
              }
            }
          }
        }
      }
    }
  end

  def user_profile(user, parameterized_name)
    user.user_profiles.joins(:instance_profile_type)
                      .find_by(instance_profile_types: { parameterized_name: parameterized_name })
  end
end
