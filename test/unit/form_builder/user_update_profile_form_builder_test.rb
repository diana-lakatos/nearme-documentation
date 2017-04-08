# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

class UserUpdateProfileFormBuilderTest < ActiveSupport::TestCase
  context 'complex configuration' do
    setup do
      GmapsFake.stub_requests
      CustomAttributes::CustomAttribute.destroy_all
      buyer_profile_type = PlatformContext.current.instance.buyer_profile_type
      seller_profile_type = PlatformContext.current.instance.seller_profile_type
      default_profile_type = PlatformContext.current.instance.default_profile_type

      FactoryGirl.create(:custom_attribute, name: 'buyer_attr', target: buyer_profile_type)
      FactoryGirl.create(:custom_attribute, name: 'seller_attr', target: seller_profile_type)
      @seller_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'seller_photo', target: seller_profile_type)
      FactoryGirl.create(:custom_attribute, name: 'default_attr', target: default_profile_type)

      category = FactoryGirl.create(:category, name: 'Buyer Category', instance_profile_types: [buyer_profile_type])
      FactoryGirl.create(:category, name: 'Buyer Sub Cat 1', parent: category)
      @buyer_sub_cat = FactoryGirl.create(:category, name: 'Buyer Sub Cat 2', parent: category)

      category = FactoryGirl.create(:category, name: 'Seller Category',
                                               multiple_root_categories: true,
                                               instance_profile_types: [seller_profile_type])
      @seller_sub_cat = FactoryGirl.create(:category, name: 'Seller Sub Cat 1', parent: category)
      @seller_sub_cat2 = FactoryGirl.create(:category, name: 'Seller Sub Cat 2', parent: category)

      category = FactoryGirl.create(:category, name: 'Default Category', instance_profile_types: [default_profile_type])
      FactoryGirl.create(:category, name: 'Default Sub Cat 1', parent: category)
      @default_sub_cat = FactoryGirl.create(:category, name: 'Default Sub Cat 2', parent: category)

      model = FactoryGirl.create(:custom_model_type, name: 'Buyer Model', instance_profile_types: [buyer_profile_type])
      FactoryGirl.create(:custom_attribute, name: 'buyer_model_attr', target: model)
      @buyer_model_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'buyer_model_photo', target: model)

      model = FactoryGirl.create(:custom_model_type, name: 'Reviews', instance_profile_types: [buyer_profile_type, seller_profile_type])
      FactoryGirl.create(:custom_attribute, name: 'author', target: model)
      FactoryGirl.create(:custom_attribute, name: 'body', target: model)

      model = FactoryGirl.create(:custom_model_type, name: 'Seller Model', instance_profile_types: [seller_profile_type])
      FactoryGirl.create(:custom_attribute, name: 'seller_model_attr', target: model)

      model = FactoryGirl.create(:custom_model_type, name: 'Default Model', instance_profile_types: [default_profile_type])
      FactoryGirl.create(:custom_attribute, name: 'default_model_attr', target: model)

      @user = FactoryGirl.create(
        :user,
        user_profiles: [UserProfile.new(instance_profile_type: buyer_profile_type, profile_type: 'buyer'),
                        UserProfile.new(instance_profile_type: default_profile_type, profile_type: 'default'),
                        UserProfile.new(instance_profile_type: seller_profile_type, profile_type: 'seller')]
      )
      @user.password = nil

      @user_update_profile_form_builder = FormBuilder.new(base_form: UserUpdateProfileForm,
                                                          configuration: configuration,
                                                          object: @user).build
    end

    should 'correctly validate empty params' do
      refute @user_update_profile_form_builder.validate({})
      assert_equal "Avatar can't be blank, Profiles buyer properties buyer attr can't be blank, Profiles default categories default category can't be blank, Profiles default properties default attr can't be blank, Profiles seller categories seller category can't be blank, Profiles seller custom images can't be blank, Profiles seller properties seller attr can't be blank", @user_update_profile_form_builder.errors.full_messages.sort.join(', ')
    end

    should 'be able to save all parameters' do
      assert @user_update_profile_form_builder.validate(parameters), @user_update_profile_form_builder.errors.full_messages.join(', ')
      @user_update_profile_form_builder.save
      @user.reload
      assert_equal 'Maciej', @user.name
      assert_contains 'foobear.jpeg', @user.avatar.path
      assert_equal '604 103 204', @user.mobile_number
      assert_equal 'Adelaide SA, Australia', @user.current_address.address
      assert @user.buyer_profile.enabled
      assert_equal 'my buyer value', @user.buyer_profile.properties.buyer_attr
      assert_equal [@buyer_sub_cat.id], @user.buyer_profile.categories.pluck(:id)
      assert_equal [{ 'buyer_model_attr' => 'my second value', 'buyer_model_photo' => nil },
                    { 'buyer_model_attr' => 'my first value', 'buyer_model_photo' => nil },
                    { 'body' => 'valid review despite lack of author', 'author' => nil },
                    { 'author' => 'Maciek', 'body' => 'hey hi hello' }].sort_by { |h| h.keys.sort.first },
                   @user.buyer_profile.customizations.map { |c| c.properties.to_h }.sort_by { |h| h.keys.sort.first }
      assert_equal ['bully.jpeg', 'foobear.jpeg'], @user.buyer_profile.customizations.joins(:custom_images).pluck('custom_images.image').sort

      refute @user.default_profile.enabled
      assert_equal 'my default value', @user.default_profile.properties.default_attr
      assert_equal [@default_sub_cat.id], @user.default_profile.categories.pluck(:id)
      assert_equal [{ 'default_model_attr' => 'my second value' },
                    { 'default_model_attr' => 'my first value' }],
                   @user.default_profile.customizations.map { |c| c.properties.to_h }

      assert @user.seller_profile.enabled
      assert_equal 'my seller value', @user.seller_profile.properties.seller_attr
      assert_equal [@seller_sub_cat.id, @seller_sub_cat2.id], @user.seller_profile.categories.pluck(:id).sort
      assert_equal [{ 'seller_model_attr' => 'my first value' }],
                   @user.seller_profile.customizations.map { |c| c.properties.to_h }
      assert_equal ['bully.jpeg'], @user.seller_profile.custom_images.pluck(:image)
    end
  end

  context 'particular fields' do
    setup do
      @user = FactoryGirl.create(:user)
      @user.password = nil
      @user.current_address = nil
      @user.save!
      GmapsFake.stub_requests
    end

    context 'without validation' do
      setup do
        @user_update_profile_form_builder = FormBuilder.new(
          base_form: UserUpdateProfileForm,
          configuration: {
            name: {},
            current_address: {
              address: {}
            }
          },
          object: @user
        ).build
      end

      # FIXME: the test should allow to actually save address
      # it's just that we can't remove built-in validation for now :|
      should 'not be able to not provide current address' do
        assert @user_update_profile_form_builder.validate(
          name: 'Maciek',
          'current_address_attributes' => { 'address' => '' }
        )
        # assert_raise should be removed and two assets below should be uncommented
        assert_raise ActiveRecord::RecordNotSaved do
          @user_update_profile_form_builder.save
        end
        # assert_equal 'Maciek', @user.name
        # assert_nil @user.current_address
      end

      should 'be able to save and then update address' do
        assert @user_update_profile_form_builder.validate(
          name: 'John',
          'current_address_attributes' => { 'address' => 'Adelaide' }
        )
        assert_difference 'Address.count' do
          @user_update_profile_form_builder.save
        end
        @user = @user.reload
        assert_equal 'John', @user.name
        assert_equal 'Adelaide SA, Australia', @user.current_address.address

        @user_update_profile_form_builder = FormBuilder.new(
          base_form: UserUpdateProfileForm,
          configuration: {
            name: {},
            current_address: {
              id: {},
              address: {}
            }
          },
          object: @user
        ).build
        assert @user_update_profile_form_builder.validate(
          name: 'Maciek',
          'current_address_attributes' => { 'address' => 'Auckland' }
        )
        assert_no_difference 'Address.count' do
          @user_update_profile_form_builder.save
        end
        @user = @user.reload
        assert_equal 'Maciek', @user.name
        assert_equal 'Auckland, New Zealand', @user.current_address.address
      end
    end

    context 'with validation' do
      setup do
        @user_update_profile_form_builder = FormBuilder.new(
          base_form: UserUpdateProfileForm,
          configuration: {
            name: {},
            current_address: {
              address: {
                validation: {
                  presence: {}
                }
              },
              validation: {
                presence: {}
              }
            }
          },
          object: @user
        ).build
      end

      should 'trigger validation error for blank address' do
        refute @user_update_profile_form_builder.validate(
          name: 'Maciek',
          'current_address_attributes' => { 'address' => '' }
        )
        assert_equal "Current address address can't be blank", @user_update_profile_form_builder.errors.full_messages.join(',')
      end
    end
  end

  protected

  def parameters
    {
      'name' => 'Maciej',
      'avatar' => File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')),
      'current_address_attributes' => { address: 'adelaide' },
      'mobile_number' => '604 103 204',
      'tag_list' => 'mac, iek',
      profiles: {
        buyer: {
          'enabled' => true,
          :properties => {
            'buyer_attr' => 'my buyer value'
          },
          :categories => {
            'Buyer Category' => @buyer_sub_cat.id
          },
          :customizations => {
            'buyer_model_attributes' => {
              '0' => {
                properties: {
                  buyer_model_attr: 'my first value'
                },
                custom_images: {
                  :"#{@buyer_model_photo.id}" => {
                    image: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
                  }
                }
              },
              '1' => {
                properties: {
                  buyer_model_attr: 'my second value'
                },
                custom_images: {
                  :"#{@buyer_model_photo.id}" => {
                    image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
                  }
                }
              }
            },
            'reviews_attributes' => {
              '0' => { properties: { author: 'Maciek', body: 'hey hi hello' } },
              '1' => { properties: { body: 'valid review despite lack of author' } }
            }
          }
        },
        default: {
          'enabled' => false,
          :properties => {
            'default_attr' => 'my default value'
          },
          :categories => {
            'Default Category' => @default_sub_cat.id
          },
          :customizations => {
            'default_model_attributes' => {
              '0' => { properties: { default_model_attr: 'my first value' } },
              '1' => { properties: { default_model_attr: 'my second value' } }
            }
          }
        },
        seller: {
          'enabled' => true,
          :properties => {
            'seller_attr' => 'my seller value'
          },
          custom_images: {
            :"#{@seller_photo.id}" => {
              image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
            }
          },
          :categories => {
            'Seller Category' => [@seller_sub_cat.id, @seller_sub_cat2.id]
          },
          :customizations => {
            'seller_model_attributes' => {
              '0' => { properties: { seller_model_attr: 'my first value' } }
            }
          }
        }
      }
    }
  end

  def configuration
    {
      'name' => {},
      'avatar' => {
        validation: {
          'presence' => {}
        }
      },
      current_address: {
        address: {
          validation: {
            presence: {}
          }
        },
        validation: {
          presence: {}
        }
      },
      'mobile_number' => {},
      'tags' => {},
      profiles: {
        buyer: {
          'enabled' => {},
          :properties => {
            'buyer_attr' => {
              validation: {
                'presence' => {}
              }
            }
          },
          :categories => {
            'Buyer Category' => {}
          },
          :customizations => {
            'buyer_model' => {
              properties: {
                'buyer_model_attr' => {
                  validation: {
                    'presence' => {}
                  }
                }
              },
              custom_images: {
                "#{@buyer_model_photo.id}": {
                  validation: {
                    'presence' => {}
                  }
                }
              }
            },
            'reviews' => {
              properties: {
                'author' => {},
                'body' => {
                  validation: {
                    'presence' => {}
                  }
                }
              }
            }
          }
        },
        default: {
          'enabled' => {},
          :properties => {
            'default_attr' => {
              validation: {
                'presence' => {}
              }
            }
          },
          :categories => {
            'Default Category' => {
              validation: {
                presence: true
              }
            }
          },
          :customizations => {
            'default_model' => {
              properties: {
                'default_model_attr' => {
                  validation: {
                    'presence' => {}
                  }
                }
              }
            }
          }
        },
        seller: {
          'enabled' => {},
          :properties => {
            'seller_attr' => {
              validation: {
                'presence' => {}
              }
            }
          },
          :custom_images => {
            "#{@seller_photo.id}": {
              validation: {
                'presence' => {}
              }
            },
            validation: {
              'presence' => {}
            }
          },
          :categories => {
            'Seller Category' => {
              validation: {
                presence: true
              }
            }
          },
          :customizations => {
            'seller_model' => {
              properties: {
                'seller_model_attr' => {
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
end
