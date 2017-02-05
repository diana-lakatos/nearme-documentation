# frozen_string_literal: true
require 'test_helper'
require 'helpers/gmaps_fake'

class ListerUserSignupBuilderTest < ActiveSupport::TestCase
  setup do
    GmapsFake.stub_requests
    CustomAttributes::CustomAttribute.destroy_all
    @transactable_type_boat = FactoryGirl.create(:transactable_type_subscription, name: 'Boat')
    FactoryGirl.create(:custom_attribute, name: 'boat_attr', target: @transactable_type_boat)
    @boat_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'boat_photo', target: @transactable_type_boat)
    @boat_attachment = FactoryGirl.create(:custom_attribute, attribute_type: 'file', name: 'boat_attachment', target: @transactable_type_boat)
    category = FactoryGirl.create(:category, name: 'Boat Category',
                                             multiple_root_categories: true,
                                             transactable_types: [@transactable_type_boat])
    @boat_sub_cat = FactoryGirl.create(:category, name: 'Boat Sub Cat 1', parent: category)
    @boat_sub_cat2 = FactoryGirl.create(:category, name: 'Boat Sub Cat 2', parent: category)
    @boat_sub_cat3 = FactoryGirl.create(:category, name: 'Boat Sub Cat 3', parent: category)
    model = FactoryGirl.create(:custom_model_type, name: 'Boat Reviews', transactable_types: [@transactable_type_boat])
    FactoryGirl.create(:custom_attribute, name: 'author', target: model)
    @boat_review_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'review_photo', target: model)
    @boat_review_attachment = FactoryGirl.create(:custom_attribute, attribute_type: 'file', name: 'review_attachment', target: model)

    buyer_profile_type = PlatformContext.current.instance.buyer_profile_type
    seller_profile_type = PlatformContext.current.instance.seller_profile_type
    default_profile_type = PlatformContext.current.instance.default_profile_type

    FactoryGirl.create(:custom_attribute, name: 'seller_attr', target: seller_profile_type)
    @seller_photo = FactoryGirl.create(:custom_attribute, attribute_type: 'photo', name: 'seller_photo', target: seller_profile_type)
    @seller_attachment = FactoryGirl.create(:custom_attribute, attribute_type: 'file', name: 'seller_attachment', target: seller_profile_type)
    FactoryGirl.create(:custom_attribute, name: 'default_attr', target: default_profile_type)

    category = FactoryGirl.create(:category, name: 'Seller Category',
                                             multiple_root_categories: true,
                                             instance_profile_types: [seller_profile_type])
    @seller_sub_cat = FactoryGirl.create(:category, name: 'Seller Sub Cat 1', parent: category)
    @seller_sub_cat2 = FactoryGirl.create(:category, name: 'Seller Sub Cat 2', parent: category)

    category = FactoryGirl.create(:category, name: 'Default Category', instance_profile_types: [default_profile_type])
    FactoryGirl.create(:category, name: 'Default Sub Cat 1', parent: category)
    @default_sub_cat = FactoryGirl.create(:category, name: 'Default Sub Cat 2', parent: category)

    model = FactoryGirl.create(:custom_model_type, name: 'Reviews', instance_profile_types: [buyer_profile_type, seller_profile_type])
    FactoryGirl.create(:custom_attribute, name: 'author', target: model)
    FactoryGirl.create(:custom_attribute, name: 'body', target: model)

    model = FactoryGirl.create(:custom_model_type, name: 'Seller Model', instance_profile_types: [seller_profile_type])
    FactoryGirl.create(:custom_attribute, name: 'seller_model_attr', target: model)

    model = FactoryGirl.create(:custom_model_type, name: 'Default Model', instance_profile_types: [default_profile_type])
    FactoryGirl.create(:custom_attribute, name: 'default_model_attr', target: model)

    @lister_user_signup_builder = FormBuilder.new(base_form: UserSignup::ListerUserSignup,
                                                  configuration: configuration,
                                                  object: User.new).build
  end

  should 'correctly validate empty params' do
    @lister_user_signup_builder.prepopulate!
    refute @lister_user_signup_builder.validate({})
    assert_equal "Email can't be blank, Password can't be blank, Avatar can't be blank, Seller profile properties seller attr can't be blank, Seller profile custom images #{@seller_photo.id} image can't be blank, Seller profile custom attachments #{@seller_attachment.id} file can't be blank, Seller profile categories seller category can't be blank, Default profile properties default attr can't be blank, Default profile categories default category can't be blank, Companies name can't be blank, Companies locations name can't be blank, Companies locations transactables boat photos is too short (minimum is 1 character), Companies locations transactables boat action types is too short (minimum is 1 character), Companies locations transactables boat name can't be blank, Companies locations transactables boat properties boat attr can't be blank, Companies locations transactables boat custom images #{@boat_photo.id} image can't be blank, Companies locations transactables boat custom attachments #{@boat_attachment.id} file can't be blank, Companies locations transactables boat categories boat category can't be blank, Companies locations location address address can't be blank", @lister_user_signup_builder.errors.full_messages.join(', ')
  end

  should 'be able to save all parameters' do
    assert @lister_user_signup_builder.validate(parameters), @lister_user_signup_builder.errors.full_messages.join(', ')
    assert_difference 'User.count' do
      @lister_user_signup_builder.save
    end
    @user = User.last
    assert_equal 'Maciej', @user.name
    assert_contains 'foobear.jpeg', @user.avatar.path
    assert_equal '604 103 204', @user.mobile_number

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
    assert_equal 1, @user.companies.count
    company = @user.companies.first
    assert_equal 'My Company', company.name
    assert_equal @user.id, company.creator_id
    assert_equal 1, company.locations.count
    location = company.locations.first
    assert_equal 'My Location', location.name
    assert_equal @user.id, location.creator_id
    assert_equal 1, location.transactables.count
    address = location.location_address
    assert location.location_address.present?
    assert_equal 'Adelaide SA, Australia', address.address
    transactable = location.transactables.first
    assert_equal 'My first boat', transactable.name
    assert_equal 'boat attr value', transactable.properties.boat_attr
    assert_equal 1, transactable.photos.count
    photo = transactable.photos.first
    assert_equal @user.id, photo.creator_id
    assert_equal 'Transactable', photo.owner_type
    assert_equal 1, transactable.action_types.count
    action_type = transactable.action_type
    assert action_type.present?
    assert action_type.enabled?
    pricing = action_type.pricings.first
    assert pricing.present?
    assert_equal Money.new(1023, 'PLN'), pricing.price
    assert_equal 'month', pricing.unit

    assert_equal @user.id, transactable.creator_id
    assert_equal [@boat_sub_cat.id, @boat_sub_cat2.id], transactable.categories.pluck(:id).sort
    assert_equal [['bully.jpeg', @user.id]], transactable.custom_images.pluck(:image, :uploader_id)
    assert_equal [['foobear.jpeg', @user.id]], transactable.custom_attachments.pluck(:file, :uploader_id)
    assert_equal [{ 'author' => 'Jane Doe', 'review_photo' => nil, 'review_attachment' => nil },
                  { 'author' => 'John Doe', 'review_photo' => nil, 'review_attachment' => nil }],
                 transactable.customizations.map { |c| c.properties.to_h }
    assert_equal ['bully.jpeg', 'foobear.jpeg'], transactable.customizations.joins(:custom_images).pluck('custom_images.image').sort
    assert_equal ['bully.jpeg', 'hello.pdf'], transactable.customizations.joins(:custom_attachments).pluck('custom_attachments.file').sort
  end

  protected

  def parameters
    {
      'name' => 'Maciej',
      'email' => 'maciej@example.com',
      'password' => 'this is very long and secure password',
      'avatar' => File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg')),
      'mobile_number' => '604 103 204',
      'tag_list' => 'mac, iek',
      :default_profile => {
        'enabled' => '0',
        :properties => {
          'default_attr' => 'my default value'
        },
        :categories => {
          'Default Category' => @default_sub_cat.id
        },
        :customizations => {
          'Default Model_attributes' => {
            '0' => { properties: { default_model_attr: 'my first value' } },
            '1' => { properties: { default_model_attr: 'my second value' } }
          }
        }
      },
      :seller_profile => {
        'enabled' => '1',
        :properties => {
          'seller_attr' => 'my seller value'
        },
        custom_images: {
          :"#{@seller_photo.id}" => {
            image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
          }
        },
        custom_attachments: {
          :"#{@seller_attachment.id}" => {
            file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
          }
        },
        :categories => {
          'Seller Category' => [@seller_sub_cat.id, @seller_sub_cat2.id]
        },
        :customizations => {
          'Seller Model_attributes' => {
            '0' => { properties: { seller_model_attr: 'my first value' } }
          }
        }
      },
      'companies_attributes' => {
        '0' => {
          name: 'My Company',
          'locations_attributes' => {
            '0' => {
              name: 'My Location',
              'location_address_attributes' => {
                address: 'adelaide'
              },
              transactables: {
                'Boat_attributes' => {
                  '0' => {
                    name: 'My first boat',
                    currency: 'PLN',
                    custom_images: {
                      :"#{@boat_photo.id}" => {
                        image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
                      }
                    },
                    custom_attachments: {
                      :"#{@boat_attachment.id}" => {
                        file: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
                      }
                    },
                    'photos_attributes' => {
                      '0' => {
                        image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
                      }
                    },
                    :categories => {
                      'Boat Category' => [@boat_sub_cat.id, @boat_sub_cat2.id]
                    },
                    :customizations => {
                      'Boat Reviews_attributes' => {
                        '0' => {
                          properties: {
                            author: 'John Doe'
                          },
                          custom_images: {
                            :"#{@boat_review_photo.id}" => {
                              image: File.open(File.join(Rails.root, 'test', 'assets', 'foobear.jpeg'))
                            }
                          },
                          custom_attachments: {
                            :"#{@boat_review_attachment.id}" => {
                              file: File.open(File.join(Rails.root, 'test', 'assets', 'hello.pdf'))
                            }
                          }
                        },
                        '1' => {
                          properties: { author: 'Jane Doe' },
                          custom_images: {
                            :"#{@boat_review_photo.id}" => {
                              image: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
                            }
                          },
                          custom_attachments: {
                            :"#{@boat_review_attachment.id}" => {
                              file: File.open(File.join(Rails.root, 'test', 'assets', 'bully.jpeg'))
                            }
                          }
                        }
                      }
                    },
                    properties: {
                      'boat_attr' => 'boat attr value'
                    },
                    'action_types_attributes' => {
                      '0' => {
                        transactable_type_action_type_id: @transactable_type_boat.action_types.first.id,
                        type: 'Transactable::SubscriptionBooking',
                        enabled: '1',
                        'pricings_attributes' => {
                          '0' => {
                            price_cents: 1023,
                            transactable_type_pricing_id: @transactable_type_boat.action_types.first.pricings.first.id,
                            unit: 'month'
                          }
                        }
                      }
                    }
                  }
                }
              }
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
      'current_address' => {},
      'mobile_number' => {},
      'tags' => {},
      :default_profile => {
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
          'Default Model' => {
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
      :seller_profile => {
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
          }
        },
        :custom_attachments => {
          "#{@seller_attachment.id}": {
            validation: {
              'presence' => {}
            }
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
          'Seller Model' => {
            properties: {
              'seller_model_attr' => {
                validation: {
                  'presence' => {}
                }
              }
            }
          }
        }
      },
      :companies => {
        name: {
          validation: {
            presence: true
          }
        },
        locations: {
          name: {
            validation: {
              presence: true
            }
          },
          location_address: {
            address: {
              validation: {
                'presence': {}
              }
            }
          },
          transactables: {
            'Boat' => {
              name: {
                validation: {
                  'presence' => {}
                }
              },
              photos: {
                validation: {
                  length: { minimum: 1 }
                }
              },
              categories: {
                'Boat Category' => {
                  validation: {
                    presence: true
                  }
                }
              },
              customizations: {
                'Boat Reviews' => {
                  properties: {
                    'author' => {
                      validation: {
                        'presence' => {}
                      }
                    }
                  },
                  custom_images: {
                    "#{@boat_review_photo.id}": {
                      validation: {
                        'presence' => {}
                      }
                    }
                  },
                  custom_attachments: {
                    "#{@boat_review_attachment.id}": {
                      validation: {
                        'presence' => {}
                      }
                    }
                  }
                }
              },
              custom_images: {
                "#{@boat_photo.id}": {
                  validation: {
                    'presence' => {}
                  }
                }
              },
              custom_attachments: {
                "#{@boat_attachment.id}": {
                  validation: {
                    'presence' => {}
                  }
                }
              },
              properties: {
                boat_attr: {
                  validation: {
                    presence: {}
                  }
                }
              },
              action_types: {
                pricings: {
                  price_cents: {
                    validation: {
                      presence: true
                    }
                  },
                  unit: {
                    validation: {
                      presence: true
                    }
                  },
                  validation: {
                    length: { minimum: 1 }
                  }
                },
                validation: {
                  length: { minimum: 1 }
                }
              },
              validation: {
                length: { minimum: 1 }
              }
            },
            validation: {
              presence: {}
            }
          },
          validation: {
            length: { minimum: 1 }
          }
        },
        validation: {
          length: { minimum: 1 }
        }
      }
    }
  end
end
