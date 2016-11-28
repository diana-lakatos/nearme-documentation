class NewSignupFormForSpacer < ActiveRecord::Migration
  def up
    instance = Instance.find_by(id: 130)
    if instance.present?
      instance.set_context!
      tt = TransactableType.first
      CustomAttributes::CustomAttribute.where(name: 'other_space_details').first.update_attribute(:attribute_type, :array)
      CustomAttributes::CustomAttribute.where(name: 'legally_rent_space').first.update_attribute(:attribute_type, :array)
      CustomAttributes::CustomAttribute.find(4522).update_attribute(:attribute_type, :array)
      CustomAttributes::CustomAttribute.find(4521).update_attributes(attribute_type: :array,
                                                                     valid_values: 'No other rules than the standard Spacer rules,Only store car or motorbike,Please let me know 24hours before visting the space,Suitable for parking only,Suitable for storage only,Access infrequently only'.split(','))

      tt.custom_attributes.where(name: 'additional_rules').first_or_create!(html_tag: 'textarea', attribute_type: 'string')
      Page.where(slug: 'new-signup').first_or_create!(path: 'new-signup').update_attributes(html_content: %Q(
{% content_for 'head_bottom' %}
<!-- <link rel="stylesheet" href="https://rawgit.com/mdyd-dev/marketplaces/master/spacer/signup.v02/dist/signup_form.css"> -->
<link href="http://localhost:4000/css/signup_form.css" rel="stylesheet">
{% endcontent_for %}

{% content_for 'body_bottom' %}
<!-- <script src="https://rawgit.com/mdyd-dev/marketplaces/master/spacer/signup.v02/dist/signup-bundle.js" async></script>
<script src="http://localhost:4000/js/signup-bundle.js" async></script>-->
{% endcontent_for %}

{% render_form New Lister Signup Form %}
                                                                       ))

      CustomAttributes::CustomAttribute.find(4523).update_attribute(:valid_values, '$50 Deposit,$100 Deposit,$150 Deposit,$200 Deposit'.split(','))
      fc = FormConfiguration.where(name: 'New Lister Signup Form', base_form: 'UserSignup::ListerUserSignup').first_or_create!.update_attributes(
configuration: {
        name: {
          validation: {
            'presence' => {}
          }
        },
        :seller_profile => {
          'enabled' => {},
          validation: {
            presence: true
          }
        },
        :companies => {
          name: {
            validation: {
              'presence' => {}
            }
          },
          locations: {
            location_address: {
              raw_address: {},
              address: {
                validation: {
                  'presence': {}
                }
              }
            },
            transactables: {
              'Space' => {
                name: {
                  validation: {
                    'presence' => {}
                  }
                },
                description: {
                  validation: {
                    'presence' => {}
                  }
                },
                :categories => {
                  'Storage Type' => {
                    validation: {
                      presence: true
                    }
                  },
                  'Access' => {
                    validation: {
                      presence: true
                    }
                  },
                  'Security Features' => {
                    validation: {
                      presence: true
                    }
                  },
                  validation: {
                    presence: true
                  }
                },
                photos: {},
                properties: {
                  size_of_space: {
                    validation: {
                      presence: {}
                    }
                  },
                  space_suitability: {
                    validation: {
                      presence: {}
                    }
                  },
                  other_space_details: {
                    validation: {
                      presence: {}
                    }
                  },
                  use_google_street_photos: {
                    validation: {
                      presence: {}
                    }
                  },
                  my_rules: {
                    validation: {
                      presence: {}
                    }
                  },
                  additional_rules: {},
                  bond_or_deposit: {}
                },
                action_types: {
                  pricings: {
                    price_cents: {
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
      },
        liquid_body: <<-EOS
<section class="multistep-signup" data-multistep-signup>
  {% if current_user == blank %}
    <h2>Let’s list your space and start<br>making you some extra money</h2>

    {% assign user_prefix = 'form' %}
    {% assign company_prefix = user_prefix | append: '[companies_attributes][0]' %}
    {% assign location_prefix = company_prefix | append: '[locations_attributes][0]' %}
    {% assign transactable_prefix = location_prefix | append: '[transactables][Space_attributes][0]' %}
    {% assign photo_prefix = transactable_prefix | append: '[photos_attributes][]' %}
    {% assign properties_prefix = transactable_prefix | append: '[properties]' %}
    {% assign storage_category_prefix = transactable_prefix | append: '[categories][Storage Type]' %}
    {% assign access_category_prefix = transactable_prefix | append: '[categories][Access]' %}
    {% assign security_category_prefix = transactable_prefix | append: '[categories][Security Features][]' %}
    {% assign location_address_prefix = location_prefix | append: '[location_address_attributes]' %}
    {% assign action_types_prefix = transactable_prefix | append: '[action_types_attributes][0]' %}
    {% assign pricing_prefix = action_types_prefix | append: '[pricings_attributes][0]' %}

    {% assign form = @forms['New Lister Signup Form'].form %}
    {% form_for form, url: '/api/users.html', as: user, method: 'post' %}
      {% if form.errors %}
        <ul>
        {% for error in form.errors %}
          <li>{{ error[0] }} - {{ error[1] }}</li>
        {% endfor %}
        </ul>
      {% endif %}
      <input value="{{ @forms['New Lister Signup Form'].configuration.id }}" type="hidden" name="form_configuration_id" />
      <input value="{{ @page.id }}" type="hidden" name="page_id" />
      <input value="/dashboard" type="hidden" name="return_to" />
      <input type="hidden" name="form[seller_profile_attributes][enabled]" value="1">
      <div class="step active-step" data-step="0">
        <h3>Evaluate rent income from your space</h3>
        <fieldset data-form-field="required-group">
          <legend>What type of space do you have? <abbr title="required field">*</abbr></legend>
          <ul class="radio-list">
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4598" id="transactable-space-type-garage" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4598' %}checked=checked{% endif %}>
              <label for="transactable-space-type-garage">
                  <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2109 491 100 100"> <path d="M-2021.6,527.9l-36-23.7c-0.5-0.3-1.1-0.3-1.6,0l-36,23.7c-0.4,0.3-0.7,0.7-0.7,1.3v49c0,0.8,0.7,1.5,1.5,1.5h9.8 c0.8,0,1.5-0.7,1.5-1.5v-39.3h49.4v39.3c0,0.8,0.7,1.5,1.5,1.5h9.8c0.8,0,1.5-0.7,1.5-1.5v-49 C-2020.9,528.6-2021.2,528.2-2021.6,527.9z M-2023.9,576.6h-6.8v-39.3c0-0.8-0.7-1.5-1.5-1.5h-52.4c-0.8,0-1.5,0.7-1.5,1.5v39.3 h-6.8v-46.7l34.5-22.7l34.5,22.7V576.6z M-2053.7,565.3h-9.2c-0.8,0-1.5,0.7-1.5,1.5c0,0.8,0.7,1.5,1.5,1.5h9.2 c0.8,0,1.5-0.7,1.5-1.5C-2052.2,566-2052.9,565.3-2053.7,565.3z M-2045.5,560.3c-2.3,0-4.2,1.9-4.2,4.2c0,2.3,1.9,4.2,4.2,4.2 c2.3,0,4.2-1.9,4.2-4.2C-2041.4,562.1-2043.2,560.3-2045.5,560.3z M-2045.5,565.6c-0.6,0-1.2-0.5-1.2-1.2c0-0.6,0.5-1.2,1.2-1.2 s1.2,0.5,1.2,1.2C-2044.4,565.1-2044.9,565.6-2045.5,565.6z M-2041.4,555.4l-2.2-6.8c-0.7-2.2-3.2-3.9-5.7-3.9h-18.2 c-2.5,0-4.9,1.7-5.7,3.9l-2.2,6.8c-2.8,0.5-4.9,3-4.9,5.9v9.1c0,1.7,1.2,3.1,2.8,3.3v3c0,1.6,1.3,2.9,2.9,2.9h3 c1.6,0,2.9-1.3,2.9-2.9v-3h20.3v3c0,1.6,1.3,2.9,2.9,2.9h3c1.6,0,2.9-1.3,2.9-2.9v-3c1.6-0.3,2.8-1.7,2.8-3.3v-9.1 C-2036.5,558.3-2038.6,555.9-2041.4,555.4z M-2070.2,549.5c0.3-1,1.7-1.9,2.8-1.9h18.2c1.2,0,2.5,0.9,2.8,1.9l1.9,5.8h-27.6 L-2070.2,549.5z M-2071.5,576.7h-2.9v-3h2.9V576.7z M-2042.3,576.6h-2.9v-2.9h2.9V576.6z M-2039.5,570.3c0,0.2-0.2,0.4-0.4,0.4 h-36.9c-0.2,0-0.4-0.2-0.4-0.4v-9.1c0-1.7,1.3-3,3-3h31.7c1.7,0,3,1.3,3,3L-2039.5,570.3L-2039.5,570.3z M-2071.1,560.3 c-2.3,0-4.2,1.9-4.2,4.2c0,2.3,1.9,4.2,4.2,4.2c2.3,0,4.2-1.9,4.2-4.2C-2067,562.1-2068.9,560.3-2071.1,560.3z M-2071.1,565.6 c-0.6,0-1.2-0.5-1.2-1.2c0-0.6,0.5-1.2,1.2-1.2c0.6,0,1.2,0.5,1.2,1.2C-2070,565.1-2070.5,565.6-2071.1,565.6z"/> </svg>
                  Garage
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="6521" id="transactable-space-type-parking-space" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '6521' %}checked=checked{% endif %}>
              <label for="transactable-space-type-parking-space">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2114 496 90 90"> <g> <polygon points="-2038.9,552.1 -2055.3,526.2 -2039,526.2 -2039,524.2 -2096.3,524.2 -2096.3,526.2 -2080.1,526.2 -2096.4,552.1 -2090.2,552.1 -2077,526.2 -2058.3,526.2 -2045.1,552.1   "/> <polygon points="-2059.7,527.5 -2075.6,527.5 -2076.6,528.2 -2076.9,529.5 -2058.5,529.5 -2058.7,528.2  "/> </g> </svg>
                Parking Space
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4604" id="transactable-space-type-yard" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4604' %}checked=checked{% endif %}>
              <label for="transactable-space-type-yard">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2109 491 100 100"> <g> <path d="M-2012.2,554h3.2v8h-3.2v7.8h-12.5V562h-7.8v7.8h-12.5V562h-7.8v7.8h-12.5V562h-8v7.8h-12.3V562h-8v7.8h-12.3V562h-3.3v-8 h3.3v-21.6h-3.3v-7.8h3.3v-4.5l6.1-8l6.1,8v4.5h8v-4.5l6.1-8l6.1,8v4.5h8v-4.5l6.1-8l6.3,8v4.5h7.8v-4.5l6.1-8l6.3,8v4.5h7.8v-4.5 l6.1-8l6.3,8v4.5h3.2v7.8h-3.2L-2012.2,554l0-21.6L-2012.2,554L-2012.2,554z M-2085.4,532.4h-8V554h8V532.4z M-2065.1,532.4h-8V554 h8V532.4z M-2044.9,532.4h-7.8V554h7.8V532.4z M-2024.6,532.4h-7.8V554h7.8V532.4z"/> </g> </svg>
                Yard
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4599" id="transactable-space-type-shed" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4599' %}checked=checked{% endif %}>
              <label for="transactable-space-type-shed">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2109 491 100 100"> <path d="M-2081.6,542.2c0.7,0,1.4-0.3,1.9-0.8l2-2v25.7c0,1.5,1.2,2.7,2.7,2.7h32c1.5,0,2.7-1.2,2.7-2.7v-25.7l2,2 c1.1,1.1,2.8,1.1,3.8,0c1-1.1,1.1-2.8,0-3.8l-22.6-22.7c-1.1-1.1-2.8-1.1-3.8,0l-22.6,22.7c-1.1,1.1-1.1,2.8,0,3.8 C-2083,541.9-2082.3,542.2-2081.6,542.2z M-2059,520.7l13.3,13.3v28.4h-26.6V534L-2059,520.7z"/> </svg>
                Shed
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4600" id="transactable-space-type-bedroom" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4600' %}checked=checked{% endif %}>
              <label for="transactable-space-type-bedroom">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-1903 285 512 512"> <g> <path d="M-1459.5,559.8c0-20.7-16.8-37.5-37.5-37.5V391h-300v131.3c-20.7,0-37.5,16.8-37.5,37.5v93.8h56.2V691h37.5v-37.5h187.8 V691h37.5v-37.5h56V559.8z M-1759.5,428.5h225v93.8h-225V428.5z M-1497,616h-300v-56.3h300V616z"/> <rect x="-1722" y="466" width="56.3" height="37.5"/> <rect x="-1628.3" y="466" width="56.3" height="37.5"/> </g> </svg>
                Bedroom
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="5617" id="transactable-space-type-storage-cage" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '5617' %}checked=checked{% endif %}>
              <label for="transactable-space-type-storage-cage">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2127 509 64 64"> <g> <g> <path d="M-2069,566h-5v-50h5c0.6,0,1-0.4,1-1s-0.4-1-1-1h-52c-0.6,0-1,0.4-1,1s0.4,1,1,1h5v50h-5c-0.6,0-1,0.4-1,1s0.4,1,1,1h52 c0.6,0,1-0.4,1-1S-2068.4,566-2069,566z M-2076,566h-8v-16h3c0.6,0,1-0.4,1-1v-16c0-0.6-0.4-1-1-1h-3v-16h8V566z M-2094,516h8v16 h-3c-0.6,0-1,0.4-1,1v16c0,0.6,0.4,1,1,1h3v16h-8V516z M-2096,566h-8v-50h8V566z M-2088,548v-14h6v14H-2088z M-2114,516h8v50h-8 V516z"/> <path d="M-2083,539c0-1.1-0.9-2-2-2s-2,0.9-2,2c0,0.8,0.5,1.5,1.1,1.8l-1.1,2.2h4l-1.1-2.2C-2083.5,540.5-2083,539.8-2083,539z"/> </g> </g> </svg>
                Storage Cage
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4602" id="transactable-space-type-basement" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4602' %}checked=checked{% endif %}>
              <label for="transactable-space-type-basement">
               <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 68.6 95.5"> <g> <path d="M67.5,57.5L8,1C7.3,0.3,6.5-0.1,6.3,0.1L5.5,1c-0.2,0.2,0.2,0.9,1,1.6L10,5.9v26.9H0v18.8v1.8v42.1h65.2V79h-4.1V54.4 l4.9,4.7c0.7,0.7,1.5,1.1,1.7,0.9l0.8-0.9C68.7,58.9,68.3,58.2,67.5,57.5z M59,79h-5.5V67.2H41.7V55.5H29.9V43.8H18.1v-11H12V8 l46.8,44.4V79H59z"/> </g> </svg>
               Basement
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4603" id="transactable-space-type-attic" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4603' %}checked=checked{% endif %}>
              <label for="transactable-space-type-attic">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2114 496 90 90"> <polygon points="-2102.1,564 -2111,564 -2093.1,525 -2084.2,525 "/> <polygon points="-2082,564 -2090.9,564 -2073,525 -2064.1,525 "/> <polygon points="-2071.9,564 -2080.9,564 -2063,525 -2054.1,525 "/> <polygon points="-2026,564 -2043.9,525 -2044,525 -2052.8,525 -2052.9,525 -2070.8,564 -2061.9,564 -2048.4,534.6 -2034.9,564 "/> <polygon points="-2076,525 -2076,518 -2083,518 -2083,525 -2083.1,525 -2101,564 -2092,564 -2074.2,525 "/> <g> <rect x="-2054" y="550" width="5" height="4"/> <rect x="-2048" y="550" width="5" height="4"/> <rect x="-2048" y="555" width="5" height="5"/> <rect x="-2054" y="555" width="5" height="5"/> </g> </svg>
                Attic
              </label>
            </li>
            <li>
              <input type="radio" name="{{ storage_category_prefix }}" value="4756" id="transactable-space-type-other" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Storage Type'] == '4756' %}checked=checked{% endif %}>
              <label for="transactable-space-type-other">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2151 533 16 16"> <path d="M-2151,533v2h16v-2H-2151z M-2151,536v11.8c0,0.1,0.1,0.2,0.2,0.2h15.6c0.1,0,0.2-0.1,0.2-0.3V536H-2151L-2151,536z M-2144.8,538h3.5c0.2,0,0.3,0.1,0.3,0.2v1.6c0,0.1-0.1,0.2-0.2,0.2h-3.6c-0.1,0-0.2-0.1-0.2-0.2v-1.6 C-2145,538.1-2144.9,538-2144.8,538z"/> </svg>
                Other
              </label>
            </li>
          </ul>
        </fieldset>

        <div class="form-field" data-form-field="location">
          <label for="transactable-location">Where is your space located <abbr title="required field">*</abbr></label>
          <input type="text" id="transactable-location" name="{{ location_address_prefix }}[address]" value="{{ form.companies.first.locations.first.location_address.address }}"  placeholder="Please start typing the location of your space..." required>
          <input type="hidden" name="{{ location_address_prefix }}[raw_address]" value="1">

          <input type="hidden" name="{{ location_address_prefix }}[local_geocoding]" data-local-geocoding>
          <input type="hidden" name="{{ location_address_prefix }}[latitude]" data-latitude value="0">
          <input type="hidden" name="{{ location_address_prefix }}[longitude]" data-longitude value="0">
          <input type="hidden" name="{{ location_address_prefix }}[formatted_address]" data-formatted-address>
          <input type="hidden" name="{{ location_address_prefix }}[street]" data-street>
          <input type="hidden" name="{{ location_address_prefix }}[suburb]" data-suburb>
          <input type="hidden" name="{{ location_address_prefix }}[city]" data-city>
          <input type="hidden" name="{{ location_address_prefix }}[state]" data-state>
          <input type="hidden" name="{{ location_address_prefix }}[country]" data-country>
          <input type="hidden" name="{{ location_address_prefix }}[postcode]" data-postcode>

          <p class="help">Start entering the FULL street address of your space and select from the dropdown list , e.g. 123 George St, Parramatta, NSW, Australia.</p>
          <p class="help">Your address will not be shown on the ad, but the Spacer Team needs to know where your space is close to in order to assist potential renters.</p>
        </div>

        <fieldset data-form-field="required-group">
          <legend>What access can the renter have to the space? <abbr title="require field">*</abbr></legend>
          <ul class="radio-list double">
            <li>
              <input type="radio" name="{{ access_category_prefix }}" id="transactable-access-type-fulltime" value="3389" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Access'] == '3389' %}checked=checked{% endif %}>
              <label for="transactable-access-type-fulltime">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2109 491 100 100"> <circle cx="-2045.1" cy="540.5" r="11.4"/> <path d="M-2053.1,528.5l-7.3-3.5l0.4,0.9l3,6.5C-2055.9,530.8-2054.6,529.5-2053.1,528.5z"/> <path d="M-2059.2,537.7l-0.2,0.1l-7.4,2.6l7.6,2.7c-0.2-0.9-0.3-1.8-0.3-2.7C-2059.5,539.5-2059.4,538.6-2059.2,537.7z"/> <path d="M-2042.3,526.3l-2.7-7.8l-0.3,0.9l-2.4,6.9c0.9-0.2,1.8-0.3,2.7-0.3C-2044.1,526-2043.2,526.1-2042.3,526.3z"/> <path d="M-2033.2,532.3l3.5-7.4l-0.9,0.4l-6.5,3.1C-2035.5,529.5-2034.2,530.8-2033.2,532.3z"/> <path d="M-2030.9,543.2l7.6-2.7l-7.6-2.7c0.2,0.9,0.3,1.8,0.3,2.7C-2030.6,541.4-2030.7,542.3-2030.9,543.2z"/> <path d="M-2047.8,554.7l0.1,0.3l2.6,7.5l2.7-7.8c-0.9,0.2-1.8,0.3-2.7,0.3C-2046,554.9-2046.9,554.8-2047.8,554.7z"/> <path d="M-2037,552.5l7.3,3.5l-3.5-7.4C-2034.2,550.1-2035.5,551.4-2037,552.5z"/> <path d="M-2057,548.6l-0.1,0.2l-3.3,7.1l7.3-3.5C-2054.6,551.5-2055.9,550.2-2057,548.6z"/> <path d="M-2085.2,540.5c0-8.5,6.6-15.4,15-15.9c-2.3-1-4.8-1.6-7.4-1.6c-9.7,0-17.6,7.9-17.6,17.6c0,9.7,7.9,17.6,17.6,17.6 c2.6,0,5.1-0.6,7.4-1.6C-2078.5,555.9-2085.2,549-2085.2,540.5z"/> <path d="M-2023.7,505.7c-9.1-9.1-21.5-14.7-35.3-14.7c-27.6,0-50,22.4-50,50c0,7.2,1.5,14,4.3,20.2l5.2-2.4 c-2.4-5.5-3.8-11.5-3.8-17.8c0-24.4,19.9-44.3,44.3-44.3c12.2,0,23.3,5,31.3,13l-6.9,6.9h12.6h3.6v-4.8v-11.4L-2023.7,505.7z"/> <path d="M-2013.3,520.8l-5.2,2.4c2.4,5.5,3.8,11.5,3.8,17.9c0,24.4-19.9,44.3-44.3,44.3c-12.2,0-23.3-5-31.3-13l7-7h-12.8h-3.5v5 v11.2l5.1-5.1c9.1,9.1,21.5,14.7,35.3,14.7c27.6,0,50-22.4,50-50C-2009,533.8-2010.5,527-2013.3,520.8z"/> </svg>
                24/7 Access
              </label>
              <p class="help">You provide a key / swipe pass to your garage / car space.</p>
            </li>

            <li>
              <input type="radio" name="{{ access_category_prefix }}" id="transactable-access-type-partial" value="3390" required {% if form.companies.first.locations.first.transactables['Space'].first.categories['Access'] == '3390' %}checked=checked{% endif %}>
              <label for="transactable-access-type-partial">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="-2109 491 100 100"> <path d="M-2060,589c-27,0-49-22-49-49c0-27,22-49,49-49c27,0,49,22,49,49C-2011,567-2033,589-2060,589L-2060,589z M-2060,501.2 c-21.4,0-38.8,17.4-38.8,38.8s17.4,38.8,38.8,38.8c21.4,0,38.8-17.4,38.8-38.8S-2038.6,501.2-2060,501.2L-2060,501.2z"/> <path d="M-2036,550h-33.2v-31.4c0-3.4,2.7-6.1,6.1-6.1s6.1,2.7,6.1,6.1v19.1h21c3.4,0,6.1,2.7,6.1,6.1 C-2029.9,547.3-2032.6,550-2036,550z"/> </svg>
                Partial Access
              </label>
              <p class="help">You provide entry to the renter by mutual arrangement.</p>
            </li>
          </ul>
        </fieldset>
      </div><!-- .step -->

      <div class="step" data-step="1">
        <h3>A few more details</h3>
        <fieldset data-form-field="required-group">
          <legend>What security does the space have? <abbr title="required field">*</abbr></legend>
          <ul class="checkbox-list">
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-alarm" value="4750" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '4750' %}checked=checked{% endif %}>
              <label for="transactable-security-alarm">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2122 503 75 75"> <g> <path d="M-2096.5,518.5c0.9-0.4,1.3-1.5,0.9-2.4c-0.4-0.9-1.5-1.3-2.4-0.9c-6.4,3-11.5,8.2-14.5,14.6c-0.4,0.9,0,2,0.9,2.4 c0.2,0.1,0.5,0.2,0.8,0.2c0.7,0,1.3-0.4,1.6-1.1C-2106.6,525.6-2102.1,521.1-2096.5,518.5z"/> <path d="M-2100.8,512c0.9-0.4,1.3-1.5,0.8-2.4c-0.4-0.9-1.5-1.3-2.4-0.8c-7.4,3.5-13.3,9.6-16.8,17c-0.4,0.9,0,2,0.9,2.4 c0.2,0.1,0.5,0.2,0.8,0.2c0.7,0,1.3-0.4,1.6-1.1C-2112.8,520.6-2107.4,515.2-2100.8,512z"/> <path d="M-2084,546.6c2.2,0,4-1.8,4-4c0-2.2-1.8-4-4-4c-2.2,0-4,1.8-4,4C-2088,544.8-2086.2,546.6-2084,546.6z"/> <path d="M-2107.3,542.6c0,12.8,10.4,23.2,23.2,23.2c12.8,0,23.2-10.4,23.2-23.2s-10.4-23.2-23.2-23.2 C-2096.9,519.4-2107.3,529.8-2107.3,542.6z M-2084,536.9c3.2,0,5.8,2.6,5.8,5.8c0,3.2-2.6,5.8-5.8,5.8c-3.2,0-5.8-2.6-5.8-5.8 C-2089.8,539.4-2087.2,536.9-2084,536.9z"/> <path d="M-2049.7,547.3c0-1.9-1.6-3.5-3.5-3.5s-3.5,1.6-3.5,3.5c0,1.7,1.3,3.2,2.9,3.4c0.3,2.5-0.1,5.1-1.2,7.5 c-1.2,2.7-3.3,4.8-5.8,6.2v-5.3c0-0.9-0.7-1.6-1.5-1.8c-4.7,7-12.7,11.6-21.8,11.6s-17.1-4.6-21.8-11.6c-0.9,0.1-1.5,0.9-1.5,1.8 v12.2c0,1,0.8,1.8,1.8,1.8h43c1,0,1.8-0.8,1.8-1.8v-3.9c3.6-1.6,6.6-4.4,8.3-8.1c1.4-3,1.8-6.2,1.4-9.3 C-2050.3,549.5-2049.7,548.5-2049.7,547.3z"/> </g> </svg>
                Alarm
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-cctv" value="4751" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '4751' %}checked=checked{% endif %}>
              <label for="transactable-security-cctv">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2135 517 48 48"> <g> <polygon points="-2089.3,537.5 -2116.5,517.5 -2126.4,531.9 -2115.2,540.1 -2120.7,547.8 -2130.7,547.8 -2130.7,518.1 -2134.5,518.1 -2134.5,564.5 -2130.7,564.5 -2130.7,551.8 -2118.9,551.8 -2112.1,542.4 -2099.2,551.9   "/> <polygon points="-2090.6,543.1 -2094.4,548.7 -2091.4,551.1 -2087.5,545.5  "/> </g> </svg>
                CCTV
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-deadlock" value="4752" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '4752' %}checked=checked{% endif %}>
              <label for="transactable-security-deadlock">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <g> <path d="M-2074.6,549.9c-2.8,0-5,2.2-5,5c0,2.8,2.2,5,5,5c2.8,0,5-2.2,5-5C-2069.6,552.1-2071.8,549.9-2074.6,549.9z M-2074.6,556.9c-1.1,0-2-0.9-2-2c0-1.1,0.9-2,2-2c1.1,0,2,0.9,2,2C-2072.6,556-2073.5,556.9-2074.6,556.9z"/> <path d="M-2074.6,544.9c-5.5,0-10,4.5-10,10c0,3.3,1.6,6.3,4.2,8.2v8.8c0,3.2,2.6,5.8,5.8,5.8c3.2,0,5.8-2.6,5.8-5.8v-8.8 c2.6-1.9,4.2-4.9,4.2-8.2C-2064.6,549.4-2069.1,544.9-2074.6,544.9z M-2071.1,560.9c-0.5,0.3-0.7,0.8-0.7,1.3v9.6 c0,1.5-1.2,2.8-2.8,2.8c-1.5,0-2.8-1.2-2.8-2.8v-9.6c0-0.5-0.3-1-0.7-1.3c-2.2-1.2-3.5-3.6-3.5-6.1c0-3.9,3.1-7,7-7 c3.9,0,7,3.1,7,7C-2067.6,557.4-2068.9,559.7-2071.1,560.9z"/> <path d="M-2029,515.2h-26.7v-1.9c0-10.4-8.4-18.8-18.8-18.8c-10.4,0-18.8,8.4-18.8,18.8v55.4c0,10.4,8.4,18.8,18.8,18.8 c10.4,0,18.8-8.4,18.8-18.8v-43.5h26.7c2.8,0,5-2.2,5-5C-2024,517.5-2026.3,515.2-2029,515.2z M-2058.8,568.7 c0,8.7-7.1,15.8-15.8,15.8c-8.7,0-15.8-7.1-15.8-15.8v-55.4c0-8.7,7.1-15.8,15.8-15.8c8.7,0,15.8,7.1,15.8,15.8v1.9h-7.2 c-1.7-3-5-5-8.6-5c-5.5,0-10,4.5-10,10c0,5.5,4.5,10,10,10c3.7,0,6.9-2,8.6-5h7.2L-2058.8,568.7L-2058.8,568.7z M-2074.5,525.2h4.9 c-1.3,1.2-3,2-4.9,2c-3.9,0-7-3.1-7-7c0-3.9,3.1-7,7-7c1.9,0,3.6,0.8,4.9,2h-4.9c-2.8,0-5,2.2-5,5 C-2079.5,523-2077.3,525.2-2074.5,525.2z M-2029,522.2h-45.5c-1.1,0-2-0.9-2-2c0-1.1,0.9-2,2-2h45.5c1.1,0,2,0.9,2,2 C-2027,521.3-2027.9,522.2-2029,522.2z"/> </g> </svg>
                Deadlock
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-security-bars" value="5960" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '5960' %}checked=checked{% endif %}>
              <label for="transactable-security-security-bars">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <path d="M-2077.7,502.6c0-3.4-2.8-5.8-6.6-5.8s-6.8,2.4-6.8,5.8v76.6c0,3.3,3,5.9,6.8,5.9s6.6-2.6,6.6-5.9V502.6z M-2040.3,579.2 c0,3.3,3,5.9,6.7,5.9s6.8-2.6,6.8-5.9v-76.7c0-3.4-3.1-5.8-6.8-5.8c-3.7,0-6.7,2.4-6.7,5.8V579.2z M-2065.8,579.2 c0,3.3,3,5.9,6.8,5.9s6.8-2.6,6.8-5.9v-76.7c0-3.4-3-5.8-6.8-5.8s-6.8,2.4-6.8,5.8V579.2z"/> </svg>
                Security bars
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-combination-lock" value="4753" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '4753' %}checked=checked{% endif %}>
              <label for="transactable-security-combination-lock">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 46 60"> <path d="M24,37c0.3,0,0.5-0.1,0.7-0.3l3-3c0.4-0.4,0.4-1,0-1.4s-1-0.4-1.4,0l-3,3c-0.4,0.4-0.4,1,0,1.4 C23.5,36.9,23.7,37,24,37 M38,19.6V14c0-7.7-6.7-14-15-14S8,6.3,8,14v5.6C3.1,23.8,0,30.1,0,37c0,12.7,10.3,23,23,23s23-10.3,23-23 C46,30,42.9,23.8,38,19.6L38,19.6z M42.3,31.8c0.1,0.5-0.2,1.1-0.7,1.2l-3.9,1c-0.1,0-0.2,0-0.3,0c-0.4,0-0.8-0.3-1-0.7 c-0.1-0.5,0.2-1.1,0.7-1.2l3.9-1C41.6,31,42.2,31.3,42.3,31.8L42.3,31.8z M40.3,27c0.3,0.5,0.1,1.1-0.4,1.4l-3.5,2 c-0.2,0.1-0.3,0.1-0.5,0.1c-0.3,0-0.7-0.2-0.9-0.5c-0.3-0.5-0.1-1.1,0.4-1.4l3.5-2C39.4,26.4,40,26.5,40.3,27L40.3,27z M14.4,20 l2,3.5c0.3,0.5,0.1,1.1-0.4,1.4C15.8,25,15.7,25,15.5,25c-0.3,0-0.7-0.2-0.9-0.5l-2-3.5c-0.3-0.5-0.1-1.1,0.4-1.4 C13.5,19.4,14.1,19.6,14.4,20L14.4,20z M8.9,22.9c0.4-0.4,1-0.4,1.4,0l2.8,2.8c0.4,0.4,0.4,1,0,1.4c-0.2,0.2-0.5,0.3-0.7,0.3 c-0.3,0-0.5-0.1-0.7-0.3l-2.8-2.8C8.5,23.9,8.5,23.2,8.9,22.9L8.9,22.9z M23,26c6.1,0,11,4.9,11,11s-4.9,11-11,11s-11-4.9-11-11 S16.9,26,23,26L23,26z M17.8,17.7c0.5-0.1,1.1,0.2,1.2,0.7l1,3.9c0.1,0.5-0.2,1.1-0.7,1.2c-0.1,0-0.2,0-0.3,0c-0.4,0-0.8-0.3-1-0.7 l-1-3.9C17,18.4,17.3,17.8,17.8,17.7L17.8,17.7z M22,22v-4c0-0.6,0.4-1,1-1s1,0.4,1,1v4c0,0.6-0.4,1-1,1S22,22.6,22,22L22,22z M25.9,22.3l1-3.9c0.1-0.5,0.7-0.8,1.2-0.7s0.8,0.7,0.7,1.2l-1,3.9c-0.1,0.4-0.5,0.7-1,0.7c-0.1,0-0.2,0-0.3,0 C26.1,23.3,25.8,22.8,25.9,22.3L25.9,22.3z M33,19.7c0.5,0.3,0.6,0.9,0.4,1.4l-2,3.5c-0.2,0.3-0.5,0.5-0.9,0.5c-0.2,0-0.3,0-0.5-0.1 c-0.5-0.3-0.6-0.9-0.4-1.4l2-3.5C31.9,19.6,32.5,19.4,33,19.7L33,19.7z M33.6,27.4c-0.3,0-0.5-0.1-0.7-0.3c-0.4-0.4-0.4-1,0-1.4 l2.8-2.8c0.4-0.4,1-0.4,1.4,0s0.4,1,0,1.4l-2.8,2.8C34.1,27.3,33.9,27.4,33.6,27.4L33.6,27.4z M14,14c0-4.5,4-8,9-8s9,3.5,9,8v1.8 c-2.8-1.2-5.8-1.8-9-1.8s-6.2,0.7-9,1.8V14L14,14z M5.7,27c0.3-0.5,0.9-0.6,1.4-0.4l3.5,2c0.5,0.3,0.6,0.9,0.4,1.4 c-0.2,0.3-0.5,0.5-0.9,0.5c-0.2,0-0.3,0-0.5-0.1l-3.5-2C5.6,28.1,5.4,27.5,5.7,27L5.7,27z M3.7,31.8c0.1-0.5,0.7-0.9,1.2-0.7l3.9,1 c0.5,0.1,0.9,0.7,0.7,1.2C9.4,33.7,9,34,8.5,34c-0.1,0-0.2,0-0.3,0l-3.9-1C3.9,32.9,3.5,32.4,3.7,31.8L3.7,31.8z M3,37 c0-0.6,0.4-1,1-1h4c0.6,0,1,0.4,1,1s-0.4,1-1,1H4C3.4,38,3,37.6,3,37L3,37z M4.6,42.9c-0.4,0-0.8-0.3-1-0.7 c-0.1-0.5,0.2-1.1,0.7-1.2l3.9-1c0.5-0.1,1.1,0.2,1.2,0.7c0.1,0.5-0.2,1.1-0.7,1.2l-3.9,1C4.8,42.9,4.7,42.9,4.6,42.9L4.6,42.9z M6.5,47.5c-0.3,0-0.7-0.2-0.9-0.5c-0.3-0.5-0.1-1.1,0.4-1.4l3.5-2c0.5-0.3,1.1-0.1,1.4,0.4c0.3,0.5,0.1,1.1-0.4,1.4l-3.5,2 C6.9,47.5,6.7,47.5,6.5,47.5L6.5,47.5z M9.6,51.4c-0.3,0-0.5-0.1-0.7-0.3c-0.4-0.4-0.4-1,0-1.4l2.8-2.8c0.4-0.4,1-0.4,1.4,0 s0.4,1,0,1.4l-2.8,2.8C10.1,51.3,9.8,51.4,9.6,51.4L9.6,51.4z M16.4,50.5l-2,3.5c-0.2,0.3-0.5,0.5-0.9,0.5c-0.2,0-0.3,0-0.5-0.1 c-0.5-0.3-0.6-0.9-0.4-1.4l2-3.5c0.3-0.5,0.9-0.6,1.4-0.4S16.6,50,16.4,50.5L16.4,50.5z M20.1,51.7l-1,3.9c-0.1,0.4-0.5,0.7-1,0.7 c-0.1,0-0.2,0-0.3,0c-0.5-0.1-0.8-0.7-0.7-1.2l1-3.9c0.1-0.5,0.7-0.9,1.2-0.7C19.9,50.7,20.2,51.2,20.1,51.7L20.1,51.7z M24,56 c0,0.6-0.4,1-1,1s-1-0.4-1-1v-4c0-0.6,0.4-1,1-1s1,0.4,1,1V56L24,56z M28.2,56.3c-0.1,0-0.2,0-0.3,0c-0.4,0-0.8-0.3-1-0.7l-1-3.9 c-0.1-0.5,0.2-1.1,0.7-1.2c0.5-0.1,1.1,0.2,1.2,0.7l1,3.9C29,55.6,28.7,56.2,28.2,56.3L28.2,56.3z M33,54.3 c-0.2,0.1-0.3,0.1-0.5,0.1c-0.3,0-0.7-0.2-0.9-0.5l-2-3.5c-0.3-0.5-0.1-1.1,0.4-1.4c0.5-0.3,1.1-0.1,1.4,0.4l2,3.5 C33.6,53.4,33.5,54,33,54.3L33,54.3z M37.1,51.1c-0.2,0.2-0.5,0.3-0.7,0.3c-0.3,0-0.5-0.1-0.7-0.3l-2.8-2.8c-0.4-0.4-0.4-1,0-1.4 s1-0.4,1.4,0l2.8,2.8C37.5,50.1,37.5,50.8,37.1,51.1L37.1,51.1z M40.3,47c-0.2,0.3-0.5,0.5-0.9,0.5c-0.2,0-0.3,0-0.5-0.1l-3.5-2 c-0.5-0.3-0.6-0.9-0.4-1.4c0.3-0.5,0.9-0.6,1.4-0.4l3.5,2C40.4,45.9,40.6,46.5,40.3,47L40.3,47z M42.3,42.2c-0.1,0.4-0.5,0.7-1,0.7 c-0.1,0-0.2,0-0.3,0l-3.9-1c-0.5-0.1-0.9-0.7-0.7-1.2c0.1-0.5,0.7-0.8,1.2-0.7l3.9,1C42.1,41.1,42.5,41.6,42.3,42.2L42.3,42.2z M42,38h-4c-0.6,0-1-0.4-1-1s0.4-1,1-1h4c0.6,0,1,0.4,1,1S42.6,38,42,38L42,38z"/> </svg>
                Combination lock
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ security_category_prefix }}" id="transactable-security-roller-door" value="4754" data-required-group="security" {% if form.companies.first.locations.first.transactables['Space'].first.categories['Security Features'] contains '4754' %}checked=checked{% endif %}>
              <label for="transactable-security-roller-door">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <path d="M-2101.2,529.8l42-29.3l42.5,29.7c0.4,0.3,0.8,0.4,1.2,0.4c0.7,0,1.3-0.3,1.7-0.9c0.7-0.9,0.4-2.2-0.5-2.9l-43.6-30.6 c-0.7-0.5-1.7-0.5-2.4,0l-43.2,30.1c-0.9,0.7-1.2,2-0.5,2.9C-2103.5,530.3-2102.2,530.5-2101.2,529.8z"/> <path d="M-2015.6,582.4h-8.8v-48.5c0-1-0.8-1.8-1.8-1.8c-1,0-1.8,0.8-1.8,1.8v48.5h-10.9v-45.6c0-1-0.8-1.8-1.8-1.8h-37 c-1,0-1.8,0.8-1.8,1.8v45.6h-10.9v-48.5c0-1-0.8-1.8-1.8-1.8c-1,0-1.8,0.8-1.8,1.8v48.5h-8.3c-1,0-1.8,0.8-1.8,1.8s0.8,1.8,1.8,1.8 h86.8c1,0,1.8-0.8,1.8-1.8C-2013.7,583.2-2014.6,582.4-2015.6,582.4z M-2042.6,562.3v4.2h-33.3v-4.2H-2042.6z M-2075.9,558.7v-4.2 h33.3v4.2H-2075.9z M-2042.6,550.8h-33.3v-4.2h33.3C-2042.6,546.5-2042.6,550.8-2042.6,550.8z M-2075.9,570.2h33.3v4.2h-33.3V570.2z M-2042.6,538.6v4.2h-33.3v-4.2H-2042.6z M-2075.9,582.4v-4.2h33.3v4.2H-2075.9z"/> </svg>
                Roller door
              </label>
            </li>
          </ul>
          <p class="help">Let prospective renters know what security features your space has. You can select multiple options.</p>
        </fieldset>

        <fieldset data-form-field="dimensions">
          <legend>What is the size of the space?</legend>
          <ul class="multistep-signup-dimensions">
            <li>
              <label for="transactable-dimensions-width">Width</label>
              <span class="field-addon">
                <input type="number" placeholder="Width" id="transactable-dimensions-width" required min="0" data-dimensions-width>
                <abbr title="Meters" class="field-suffix">m</abbr>
              </span>
            </li>
            <li>
              <label for="transactable-dimensions-length">Length</label>
              <span class="field-addon">
                <span class="field-prefix">&times;</span>
                <input type="number" placeholder="Length" id="transactable-dimensions-length" required min="0" data-dimensions-length>
                <abbr title="Meters" class="field-suffix">m</abbr>
              </span>
            </li>
            <li>
              <label for="transactable-dimensions-height">Height</label min="0">
              <span class="field-addon">
                <span class="field-prefix">&times;</span>
                <input type="number" placeholder="Height" id="transactable-dimensions-height" required min="0" data-dimensions-height>
                <abbr title="Meters" class="field-suffix">m</abbr>
              </span>
            </li>
          </ul>
          <input type='text' name='{{ properties_prefix }}[size_of_space]' value="{{ form.companies.first.locations.first.transactables['Space'].first.properties.size_of_space }}">

          <p class="multistep-signup-surface-capacity">
            Your space has

            <span class="field-addon">
              <input type="number" placeholder="surface" id="transactable-dimensions-surface" required min="0" data-dimensions-surface value="0">
              <label for="transactable-dimensions-surface" class="field-suffix">
                <abbr title="square meters">m<sup>2</sup></abbr>
                <span class="sr-only">surface</span>
              </label>
            </span>

            and

            <span class="field-addon">
              <input type="number" placeholder="capacity" id="transactable-dimensions-capacity" required min="0" value="0" data-dimensions-capacity>
              <label for="transactable-dimensions-capacity" class="field-suffix">
                <abbr title="cubic meters">m<sup>3</sup></abbr>
                <span class="sr-only">capacity</span>
              </label>
            </span>
          </p>

          <p class="help">Dimensions are the most important question renters will want to know about your space, especially for van/4WD owners. Enter Width &times; Length &times; Height of your space in metres. e.g. 2.8m &times; 5.6m &times; 2.1m</p>
        </fieldset>

        <fieldset data-form-field="required-group">
          <legend>What is the space suitable for? <abbr title="required field">*</abbr></legend>
          <ul class="checkbox-list">
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-clothes" value="Clothes" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Clothes' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-clothes">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <g> <g> <g> <path d="M-2012.2,513.3l-15-12c-1.1-0.9-2.4-1.3-3.8-1.3h-54c-1.4,0-2.7,0.5-3.8,1.3l-15,12c-2,1.6-2.7,4.2-1.9,6.6l6,18 c0.6,1.8,2,3.2,3.8,3.8c0.6,0.2,1.3,0.3,1.9,0.3c1,0,2.1-0.3,3-0.8V578c0,3.3,2.7,6,6,6h54c3.3,0,6-2.7,6-6v-36.8 c0.9,0.5,2,0.8,3,0.8c0.7,0,1.3-0.1,1.9-0.3c1.8-0.6,3.2-2,3.7-3.8l6-18C-2009.5,517.5-2010.3,514.9-2012.2,513.3z M-2046.7,506 c-1.7,3.5-6.1,6-11.3,6s-9.6-2.5-11.3-6H-2046.7z M-2022,536l-9-6v48h-54v-48l-9,6l-6-18l15-12h12.5c1.7,5.2,7.5,9,14.5,9 c7,0,12.8-3.8,14.5-9h12.5l15,12L-2022,536z"/> </g> </g> <g> <g> <path d="M-2028,573.5h-60c-0.8,0-1.5-0.7-1.5-1.5s0.7-1.5,1.5-1.5h60c0.8,0,1.5,0.7,1.5,1.5S-2027.2,573.5-2028,573.5z"/> </g> </g> </g> </svg>
                Clothes
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-caravan" value="Caravan" data-required-group="storage_purpose"  {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Caravan' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-caravan">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 46 37.6"> <path d="M38.9,29.2V14.1L24.7,0c0,0-12.8,0-18.5,0S0,5.4,0,5.4s0,14.5,0,19.1s5.1,5.2,5.1,5.2h8.6l0.2,0c-0.2,0.5-0.2,1.1-0.2,1.7 c0,3.4,2.8,6.2,6.2,6.2s6.2-2.8,6.2-6.2c0-0.6-0.1-1.1-0.2-1.7l0.2,0v0.5H46v-1H38.9z M12.5,15.3H5.8V5.1h6.7V15.3z M17.8,15.3V5.1 h3.8l9.8,10.2H17.8z"/> </svg>
                Caravan
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-boat" value="Boat" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Boat' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-boat">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <path d="M-2053.5,530.2h-12l1-6h10L-2053.5,530.2z M-2051.5,516.2h-16l-5,4h26L-2051.5,516.2z M-2055.7,516.2 c-0.5-1.6-2-2.7-3.8-2.7s-3.2,1.1-3.8,2.7H-2055.7z M-2059.1,533.7l-20.4,6.8c0,20,20.5,28,20.5,28s20.5-9,20.5-28L-2059.1,533.7z M-2059.5,533.7l13,4.2c0,0,0-0.1,0-0.1l-4.6-16.2c0-0.8-0.6-1.4-1.4-1.4h-14c-0.8,0-1.4,0.6-1.4,1.4l-4.6,16.2c0,0.1,0,0.2,0,0.3 L-2059.5,533.7z M-2061.9,534.9v31.3 M-2056.1,535.5v31.3 M-2078.5,544.2l16-3.7 M-2039.5,544.2l-16.6-3.7"/> </svg>
                Boat
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-car" value="Car" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Car' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-car">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 499.4 100 83.6"> <path d="M-2093.3,543.1"/> <path d="M-2018.1,528l-8.2-21.2c-1.5-4.1-4.9-7.5-11.2-7.5h-11.6h-19.8h-11.8c-6.3,0-9.7,3.5-11.2,7.5l-8.2,21.2 c-3.3,0.4-9,4.2-9,11.5v27h8v8.6c0,10.6,15,10.5,15,0v-8.6h27h26.9v8.6c0,10.5,15,10.6,15.1,0v-8.6h8v-27 C-2009,532.3-2014.8,528.5-2018.1,528z M-2093.3,550.2c-3.8,0-6.9-3.2-6.9-7.1c0-4,3.1-7.2,6.9-7.1c3.8,0,6.9,3.2,6.9,7.1 C-2086.3,547-2089.5,550.2-2093.3,550.2z M-2059,527.8L-2059,527.8h-32.5l6.2-16.7c0.7-2.4,1.9-4.1,4.6-4.1h21.6h0.1h21.6 c2.7,0,3.9,1.7,4.6,4.1l6.2,16.7H-2059z M-2024.7,550.2c-3.9,0-7-3.2-7-7.1c0-4,3.1-7.2,7-7.1c3.8,0,6.9,3.2,6.9,7.1 C-2017.8,547-2020.9,550.2-2024.7,550.2z"/> <path d="M-2024.7,543.1"/> </svg>
                Car
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-furniture" value="Furniture" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Furniture' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-furniture">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <g> <g> <path d="M-2058.7,590.6h0.4c-0.1,0-0.1,0-0.2,0S-2058.6,590.6-2058.7,590.6z"/> </g> <g> <path d="M-2058.7,492c-12.2,0-22.1,1.5-22.1,3.3v27.5v4.2c0,1.8,9.9,3.3,22.1,3.3c12.2,0,22.1-1.5,22.1-3.3v-4.2v-27.5 C-2036.7,493.5-2046.5,492-2058.7,492z"/> <path d="M-2048.4,582.5c0-0.4-4.2-0.7-9.5-0.7c0.8-0.7,1.4-2.3,1.7-4.4c2.1-0.5,3.5-1.7,3.5-3s-1.5-2.5-3.5-3 c-0.2-1.5-0.6-2.8-1.2-3.7c1.4-2.4,2.4-8.2,2.4-14.9c0-7.1-1.1-13.1-2.5-15.3c1.5-0.5,2.5-1.9,2.5-3.5c0-2.1-1.7-3.8-3.8-3.8 s-3.8,1.7-3.8,3.8c0,1.6,1.1,3,2.5,3.5c-1.5,2.2-2.5,8.2-2.5,15.3c0,6.8,1,12.6,2.4,14.9c-0.5,0.8-0.9,2.1-1.2,3.7 c-2.1,0.5-3.5,1.7-3.5,3s1.5,2.5,3.5,3c0.3,2.1,0.9,3.7,1.7,4.4c-5.3,0-9.5,0.3-9.5,0.7v0.2v6.2c0,0.4,4.6,0.6,10.3,0.6 c5.7,0,10.3-0.3,10.3-0.6v-6.2L-2048.4,582.5L-2048.4,582.5z"/> </g> </g> </svg>
                Furniture
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-docs" value="Office Docs" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Office Docs' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-docs">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <path d="M-2014,519.4c0-1-0.8-1.8-1.8-1.8h-86.4c-1,0-1.8,0.8-1.8,1.8h0v14.4c0,1,0.8,1.8,1.8,1.8h1.8v48.6c0,1,0.8,1.8,1.8,1.8 h79.2c1,0,1.8-0.8,1.8-1.8v-48.6h1.8c1,0,1.8-0.8,1.8-1.8V519.4L-2014,519.4z M-2021.2,582.4h-75.6v-46.8h75.6 C-2021.2,535.6-2021.2,582.4-2021.2,582.4z M-2017.6,532h-82.8v-10.8h26.9h55.9V532z"/> <path d="M-2072.5,544.6h27c1,0,1.8-0.8,1.8-1.8c0-1-0.8-1.8-1.8-1.8h-27c-1,0-1.8,0.8-1.8,1.8 C-2074.3,543.8-2073.5,544.6-2072.5,544.6z"/> </svg>
                Office Docs
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-trailer" value="Trailer" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Trailer' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-trailer">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <g> <path d="M-2020.7,534.2c-3.5-4.6-9-7.6-15.2-7.6s-11.7,3-15.2,7.6h-14.6h-37.4v11.5h5.7h27.9h14.4h5.2c0-4.8,2.4-9,6.1-11.5 c2.2-1.5,4.9-2.4,7.8-2.4c2.9,0,5.6,0.9,7.8,2.4c3.7,2.5,6.1,6.7,6.1,11.5h5.2h3.8v-11.5H-2020.7z"/> <path d="M-2035.8,536c-5.4,0-9.7,4.3-9.7,9.7c0,5.4,4.3,9.7,9.7,9.7c5.4,0,9.7-4.3,9.7-9.7C-2026.1,540.4-2030.5,536-2035.8,536z"/> </g> </svg>
                Trailer
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-workshop" value="Workshop" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Workshop' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-workshop">
                <svg xmlns="http://www.w3.org/2000/svg" viewbox="-2109 491 100 100"> <path d="M-2023.2,493.9c-0.6-0.5-6.9-0.9-8.6-0.5c-1.5,0.4-3.1,2.3-4.4,2.9c-2.4,1.3-7.4,0.7-10.3-1c-1.1-0.7-2.1-2-3.4-2.6 c-4.3-1.8-12-0.2-17.1,0.6c-6.3,1-18.3,7.2-25.3,17.9c-1.5,2.3-3.1,4.6-4,7.2c-0.5,1.5,5.4,2.6,7.9-0.7c4-5.3,9.2-9.2,13.7-10.7 c3.6-1.1,8.1,2.7,8.7,7.4c0.1-0.1,0.1,11.9,0,23.2h12.8c0-8.9,0.2-18.3,1-20.3c2.9-7.5,10.9-12.4,16.9-9.6c1.4,0.7,2.2,2,3.4,2.6 c2,1,7,1.1,8.2,0.2c2.4-1.8,2.7-5.4,2.6-8C-2021.3,500.3-2021.5,495.4-2023.2,493.9z"/> <path d="M-2066.6,541c-1.3,1.6-2.1,3.6-2.1,5.8c0,1,0,2,0,3c0,2.4,0,4.8,0.1,7.2c0,2.8,0.1,5.7,0.1,8.5c0,2.3,0,4.6,0.1,7 c0,1.6,0,3.1-0.1,4.6c-0.2,2.1-0.7,4.2-1,6.3c-0.2,1.5-0.5,3.5,0.3,4.8c2.3,3.8,7.9,2.6,11.4,2.4c3.5-0.2,10.8-0.8,10.9-5.5 c0.1-1.8-1.7-4.3-2.5-6.6c-1.5-4.5-0.8-9.4-0.9-14.1c-0.1-4.8-0.1-9.7-0.1-14.5c0-1.1,0-2.2,0-3.2c0-2.2-0.8-4.1-2.1-5.7H-2066.6z"/> </svg>
                Workshop
              </label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[space_suitability][]" id="transactable-storage-purpose-container" value="Container" data-required-group="storage_purpose" {% if form.companies.first.locations.first.transactables['Space'].first.properties.space_suitability contains 'Container' %}checked=checked{% endif %}>
              <label for="transactable-storage-purpose-container">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 46 46"> <path d="M46,24.7V46h-5.1V24.7h-1V46h-4.8V24.7h-1V46h-4.8V24.7h-1V46h-4.8V24.7h-1V46h-4.8V24.7h-1V46h-4.8V24.7h-1V46H6.1V24.7h-1 V46H0V24.7H46z M20.7,14.5L7.4,23.6L8,24.4l13.3-9.1c0.9-0.6,2.4-0.6,3.4,0l13.4,9l0.6-0.8l-13.4-9c-0.5-0.3-1.1-0.5-1.7-0.6v-3.2 c2-0.2,3.6-2,3.6-4h-1c0,1.6-1.1,2.8-2.6,3.1V9.2h-1v0.6c-1.5-0.2-2.6-1.5-2.6-3.1V0h-1v6.7c0,2.1,1.6,3.8,3.6,4v3.2 C21.9,14,21.2,14.2,20.7,14.5z"/> </svg>
                Container
              </label>
            </li>
          </ul>

          <p class="help">What can renters store in your space? Only select storage options if your space is water tight.</p>
        </fieldset>

        <fieldset data-form-field="group">
          <legend>What are the key features of your space?</legend>
          <ul class="checkbox-list">
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-water-tight" value="The space is water tight" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'The space is water tight' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-water-tight">The space is water tight</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-power" value="The space has power" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'The space has power' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-power">The space has power</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-train" value="Close to Train station" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'Close to Train station' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-train">Close to Train station</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-uni" value="Close to UNI" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'Close to UNI' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-uni">Close to UNI</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-hospital" value="Close to hospital" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'Close to hospital' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-hospital">Close to hospital</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[other_space_details][]" id="transactable-storage-feature-shopping-centre" value="Close to shopping centre" {% if form.companies.first.locations.first.transactables['Space'].first.properties.other_space_details contains 'Close to shopping centre' %}checked=checked{% endif %}>
              <label for="transactable-storage-feature-shopping-centre">Close to shopping centre</label>
            </li>
          </ul>
        </fieldset>
      </div><!-- step -->

      <div class="step" data-step="2">
        <h3>Upload photos and set your rules</h3>

        <fieldset data-form-field="photos">
          <legend>What photos do you want to use?</legend>
          <ul class="radio-list double" data-upload-photos-toggler>
            <li>
              <input type="radio" name="{{ properties_prefix }}[use_google_street_photos]" id="transactable-photo-source-google" value="use google street photos" required checked>
              <label for="transactable-photo-source-google">Use photos from Google Street View</label>
            </li>
            <li>
              <input type="radio" name="{{ properties_prefix }}[use_google_street_photos]" id="transactable-photo-source-self" value="" required data-upload-photos-on-toggler>
              <label for="transactable-photo-source-self">I will upload my own photos</label>
            </li>
          </ul>

          <div data-upload-photos class="upload-photos-wrapper">
            <label for="photos">Upload photos</label>
            <!--NEED TO BE HANDLED PROPERLY <input type="file" name="{{ photo_prefix }}" id="photos" multiple>-->

            <p class="help">You can upload up to 10 photos. A picture tells a thousand words! Listings with photos are rented 3 times faster than those without. Be sure to include photos showing the inside of your space, door, access, lock(s), and any special features. If you don't have a photo handy, you can take one with your smart phone and upload it to Spacer later, or just email it to us <a href="mailto:support@spacer.com.au">support@spacer.com.au</a> and we'll do it for you!</p>
          </div>
        </fieldset>

        <fieldset data-form-field="group">
          <legend>What rules would you like to set for your space?</legend>
          <ul class="checkbox-list double">
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[my_rules][]" id="transactable-storage-rule-storage-only" value="Suitable for storage only" {% if form.companies.first.locations.first.transactables['Space'].first.properties.my_rules contains 'Suitable for storage only' %}checked=checked{% endif %}>
              <label for="transactable-storage-rule-storage-only">Suitable for storage only</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[my_rules][]" id="transactable-storage-rule-parking-only" value="Suitable for parking only" {% if form.companies.first.locations.first.transactables['Space'].first.properties.my_rules contains 'Suitable for parking only' %}checked=checked{% endif %}>
              <label for="transactable-storage-rule-parking-only">Suitable for parking only</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[my_rules][]" id="transactable-storage-rule-notice" value="Please let me know 24hours before visting the space" {% if form.companies.first.locations.first.transactables['Space'].first.properties.my_rules contains 'Please let me know 24hours before visting the space' %}checked=checked{% endif %}>
              <label for="transactable-storage-rule-notice">Let me know 24hrs before visiting</label>
            </li>
            <li>
              <input type="checkbox" name="{{ properties_prefix }}[my_rules][]" id="transactable-storage-rule-infrequent-access" value="Access infrequently only" {% if form.companies.first.locations.first.transactables['Space'].first.properties.my_rules contains 'Access infrequently only' %}checked=checked{% endif %}>
              <label for="transactable-storage-rule-infrequent-access">Access infrequently only</label>
            </li>
          </ul>
        </fieldset>

        <div class="form-field" data-form-field>
          <label for="transactable-additional-rules">Additional rules</label>
          <textarea id="transactable-additional-rules" name="{{ properties_prefix }}[additional_rules]" placeholder="Enter any additional rules you might have regarding your space" rows="4" cols="70">{{ form.companies.first.locations.first.transactables['Space'].first.properties.additional_rules }}</textarea>
          <p class="help">Remember, you set the rules, you are in control. Renters agree to Spacer's terms and conditions, so are agreeing not to store any flammables, chemicals, perishables, illegal items, etc.</p>
        </div>

        <fieldset data-form-field="required-group">
          <legend>What deposit would you like to set for your key/fob? <abbr title="required field">*</abbr></legend>
          <ul class="radio-list double">
            <li>
              <input type="radio" name="{{ properties_prefix }}[bond_or_deposit]" value="$50 Deposit" id="transactable-deposit-50" required {% if form.companies.first.locations.first.transactables['Space'].first.properties.bond_or_deposit contains '$50 Deposit' %}checked=checked{% endif %}> <label for="transactable-deposit-50">$50 Deposit</label>
            </li>
            <li>
              <input type="radio" name="{{ properties_prefix }}[bond_or_deposit]" value="$100 Deposit" id="transactable-deposit-100" required {% if form.companies.first.locations.first.transactables['Space'].first.properties.bond_or_deposit contains '$100 Deposit' %}checked=checked{% endif %}> <label for="transactable-deposit-100">$100 Deposit</label>
            </li>
            <li>
              <input type="radio" name="{{ properties_prefix }}[bond_or_deposit]" value="$150 Deposit" id="transactable-deposit-150" required {% if form.companies.first.locations.first.transactables['Space'].first.properties.bond_or_deposit contains '$150 Deposit' %}checked=checked{% endif %}> <label for="transactable-deposit-150">$150 Deposit</label>
            </li>
            <li>
              <input type="radio" name="{{ properties_prefix }}[bond_or_deposit]" value="$200 Deposit" id="transactable-deposit-200" required {% if form.companies.first.locations.first.transactables['Space'].first.properties.bond_or_deposit contains '$200 Deposit' %}checked=checked{% endif %}> <label for="transactable-deposit-200">$200 Deposit</label>
            </li>
          </ul>
        </fieldset>
      </div><!-- step -->

      <div class="step" data-step="3">
        <h3>Confirm &amp; Submit your listing</h3>

        <div class="form-field" data-form-field>
          <label for="transactable-name">Title for your listing<abbr title="required field">*</abbr></label>
          <input type="text" name="{{ transactable_prefix }}[name]" id="transactable-name" required placeholder="My awesome space to rent" required value="{{ form.companies.first.locations.first.transactables['Space'].first.name }}">

          <p class="help">Title is used to identify your listing on search results pages, in favorties etc. Make it descriptive!</p>
        </div>

        <div class="form-field" data-form-field>
          <label for="transactable-description">Describe your space<abbr title="required field">*</abbr></label>
          <textarea name="{{ transactable_prefix }}[description]" id="transactable-description" required placeholder="Enter short description..." rows="8" cols="70" required>{{ form.companies.first.locations.first.transactables['Space'].first.description }}</textarea>
        </div>

        <input type='hidden' name='{{ action_types_prefix }}[transactable_type_action_type_id]' value='777'>
        <input type='hidden' name='{{ action_types_prefix }}[type]' value='Transactable::SubscriptionBooking'>
        <input type='hidden' name='{{ action_types_prefix }}[enabled]' value='1'>

        <div class="form-field space-cost" data-form-field="price">
          <label for="transactable-cost">How much would you like to list your space for? (per month <span>in dollars</span>)<abbr title="required field">*</abbr></label>
          <span class="field-addon">
            <span class="field-prefix">$</span><input type="number" name="{{ pricing_prefix }}[price_cents]" id="transactable-cost" required min="0" value="{{ form.companies.first.locations.first.transactables['Space'].first.action_types.first.pricings.first.price_cents }}">
            <input type='hidden' name='{{ pricing_prefix }}[enabled]' value="1" >
            <input type='hidden' name='{{ pricing_prefix}}[transactable_type_pricing_id]' value='1672'>
          </span>

          <p class="help" data-markup-info>Total cost of renting will be increased by 16.5% to include Spacer fees.</p>
        </div>
      </div>

      <div class="step" data-step="4">
        <h3>Your login details</h3>

        <div class="form-field user-email">
          <label for="user-email">Name<abbr title="required field">*</abbr></label>
          <input type="text" name="form[name]" id="user-name" value="{{ form.name }}">
          <input type="hidden" name="{{ company_prefix }}[name]" id="company-name" value="Company">
        </div>
        <div class="form-field user-email">
          <label for="user-email">Email<abbr title="required field">*</abbr></label>
          <input type="text" name="form[email]" id="user-email" value="{{ form.email }}">
        </div>
        <div class="form-field user-password">
          <label for="user-password">Password<abbr title="required field">*</abbr></label>
          <input type="password" name="form[password]" id="user-password">
        </div>
        <div class="form-field user-password">
          <input type="checkbox" name="form[accept_terms_of_service]" id="user-tos" value="1" {% if form.accept_terms_of_service == '1' %}checked=checked{% endif %}>
          <label for="user-tos">
            I accept terms and conditions
          </label>
        </div>
        <div class="multistep-signup-navigation">
          <button type="submit" class="next submit">List your space</button>
        </div>
      </div><!-- step -->
    {% endform_for %}
  {% else %}
    <h2>You already are a registered user.</h2>
  {% endif %}
</section>
EOS
      )
    end
    p = Page.where(slug: 'new-signup').first_or_create!(path: 'new-signup', content: 'Hello')
    p.page_forms.where(form_configuration: fc).first_or_create!
  end

  def down
  end
end
