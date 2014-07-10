FactoryGirl.define do
  factory :csv_template_file, class: DataImporter::CsvFile::TemplateCsvFile  do
    skip_create

    initialize_with do
      begin
        @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
        FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
        path = "#{Dir.tmpdir}/template_csv_time_#{Time.now.to_i}.csv"
        FileUtils.touch(path)
        File.open(path, 'w') do |f|
          f.write(DataImporter::CsvTemplateGenerator.new(@transactable_type).generate_template)
          f.write(([ 'user1@example.com', 'Example User1',
                     "My Company's", 'www.mycompany.example.com', 'company@example.com', "1",
                     'location@example.com', 'My Type', 'This is my cool location', '"Be careful, cool place!"',
                     'Ursynowska 1/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 1);arr } +
          ["http://www.example.com/image.jpg"]).join(',') + "\n")
          f.write((['user1@example.com', 'Example User1',
                    "My Company's", 'www.mycompany.example.com', 'company@example.com', "1",
                    'location@example.com','My Type', 'This is my cool location', '"Be careful, cool place!"',
                    'Ursynowska 1/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 1);arr } +
          ["http://www.example.com/photo.jpg"]).join(',') + "\n")
          f.write(([
            'user1@example.com', 'Example User1',
            "My Company's", 'www.mycompany.example.com', 'company@example.com', "1",
            'location@example.com','My Type','This is my cool location', '"Be careful, cool place!"',
            'Ursynowska 1/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 2);arr } +
          ["http://www.example.com/photo.jpg"]).join(',')+ "\n")
          f.write(([
            'user1@example.com', 'Example User1',
            "My Company's", 'www.mycompany.example.com', 'company@example.com', "1",
            'location2@example.com', 'My Type', 'This is my cool2 location', '"Be careful, cool2 place!"',
            'Pulawska 34/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 3);arr } +
          ["http://www.example.com/photo.jpg"]).join(',') + "\n")
          f.write(([
            'user2@example.com', 'Example User2',
            "My Company's", 'www.mycompany.example.com', 'company@example.com', "1",
            'location2@example.com', 'My Type', 'This is my cool2 location', '"Be careful, cool2 place!"',
            'Pulawska 34/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 3);arr } +
          ["http://www.example.com/photo.jpg"]).join(',') + "\n")
          f.write(([
            'user2@example.com', 'Example User2',
            "My second Company's", 'www.mycompany.example.com', 'company@example.com', "2",
            'location3@example.com', 'My Type', 'This is my cool3 location', '"Be careful, cool3 place!"',
            'Pulawska 34/2B', 'Warsaw', 'Ursynowska', 'Mokotów', 'Mazowieckie', '02-605'
          ] + Transactable.csv_fields(@transactable_type).inject([]) { |arr, k| arr << DataImporter::CsvTemplateGenerator.value_for_attribute(k[0], 4);arr }
                  ).join(',') + "\n")
        end
        new(path, @transactable_type)
      ensure
        FileUtils.rm(path)
      end
    end
  end

  factory :xml_template_file, class: DataImporter::XmlFile  do
    skip_create

    initialize_with do
      begin
        @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
        path = "#{Dir.tmpdir}/template_xml_time_#{Time.now.to_i}.xml"
        FileUtils.touch(path)
        File.open(path, 'w') do |f|
          f.write <<-XML
<?xml version="1.0"?>
<companies send_invitation="false">
  <company id="1">
    <name><![CDATA[My Company's]]></name>
    <url><![CDATA[www.mycompany.example.com]]></url>
    <email><![CDATA[company@example.com]]></email>
    <external_id><![CDATA[1]]></external_id>
    <users>
      <user>
        <email><![CDATA[user1@example.com]]></email>
        <name><![CDATA[Example User1]]></name>
      </user>
      <user>
        <email><![CDATA[user2@example.com]]></email>
        <name><![CDATA[Example User2]]></name>
      </user>
    </users>
    <locations>
      <location>
        <email><![CDATA[location@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool location]]></description>
        <special_notes><![CDATA[Be careful, cool place!]]></special_notes>
        <location_address>
          <address><![CDATA[Ursynowska 1/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="1">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[1]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 1]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/image.jpg]]></image_original_url>
              </photo>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
          <listing id="2">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[2]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 2]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
      <location>
        <email><![CDATA[location2@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool2 location]]></description>
        <special_notes><![CDATA[Be careful, cool2 place!]]></special_notes>
        <location_address>
          <address><![CDATA[Pulawska 34/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="3">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[3]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 3]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
    </locations>
  </company>
  <company id="2">
    <name><![CDATA[My second Company's]]></name>
    <url><![CDATA[www.mycompany.example.com]]></url>
    <email><![CDATA[company@example.com]]></email>
    <external_id><![CDATA[2]]></external_id>
    <users>
      <user>
        <email><![CDATA[user2@example.com]]></email>
        <name><![CDATA[Example User2]]></name>
      </user>
    </users>
    <locations>
      <location>
        <email><![CDATA[location3@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool3 location]]></description>
        <special_notes><![CDATA[Be careful, cool3 place!]]></special_notes>
        <location_address>
          <address><![CDATA[Pulawska 34/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="4">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[4]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 4]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos/>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
    </locations>
  </company>
</companies>
          XML
        end
        new(path)
      end
    end
  end

  factory :xml_template_file_send_invitations, class: DataImporter::XmlFile  do
    skip_create

    initialize_with do
      begin
        @transactable_type = FactoryGirl.create(:transactable_type_csv_template)
        path = "#{Dir.tmpdir}/template_xml_time_#{Time.now.to_i}.xml"
        FileUtils.touch(path)
        File.open(path, 'w') do |f|
          f.write <<-XML
<?xml version="1.0"?>
<companies send_invitation="true">
  <company id="1">
    <name><![CDATA[My Company's]]></name>
    <url><![CDATA[www.mycompany.example.com]]></url>
    <email><![CDATA[company@example.com]]></email>
    <external_id><![CDATA[1]]></external_id>
    <users>
      <user>
        <email><![CDATA[user1@example.com]]></email>
        <name><![CDATA[Example User1]]></name>
      </user>
      <user>
        <email><![CDATA[user2@example.com]]></email>
        <name><![CDATA[Example User2]]></name>
      </user>
    </users>
    <locations>
      <location>
        <email><![CDATA[location@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool location]]></description>
        <special_notes><![CDATA[Be careful, cool place!]]></special_notes>
        <location_address>
          <address><![CDATA[Ursynowska 1/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="1">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[1]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 1]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/image.jpg]]></image_original_url>
              </photo>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
          <listing id="2">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[2]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 2]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
      <location>
        <email><![CDATA[location2@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool2 location]]></description>
        <special_notes><![CDATA[Be careful, cool2 place!]]></special_notes>
        <location_address>
          <address><![CDATA[Pulawska 34/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="3">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[3]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 3]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
              <photo>
                <image_original_url><![CDATA[http://www.example.com/photo.jpg]]></image_original_url>
              </photo>
            </photos>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
    </locations>
  </company>
  <company id="2">
    <name><![CDATA[My second Company's]]></name>
    <url><![CDATA[www.mycompany.example.com]]></url>
    <email><![CDATA[company@example.com]]></email>
    <external_id><![CDATA[2]]></external_id>
    <users>
      <user>
        <email><![CDATA[user2@example.com]]></email>
        <name><![CDATA[Example User2]]></name>
      </user>
    </users>
    <locations>
      <location>
        <email><![CDATA[location3@example.com]]></email>
        <location_type><![CDATA[My Type]]></location_type>
        <description><![CDATA[This is my cool3 location]]></description>
        <special_notes><![CDATA[Be careful, cool3 place!]]></special_notes>
        <location_address>
          <address><![CDATA[Pulawska 34/2B]]></address>
          <city><![CDATA[Warsaw]]></city>
          <street><![CDATA[Ursynowska]]></street>
          <state><![CDATA[Mazowieckie]]></state>
          <postcode><![CDATA[02-605]]></postcode>
        </location_address>
        <listings>
          <listing id="4">
            <confirm_reservations><![CDATA[true]]></confirm_reservations>
            <daily_price_cents><![CDATA[10]]></daily_price_cents>
            <enabled><![CDATA[true]]></enabled>
            <external_id><![CDATA[4]]></external_id>
            <hourly_price_cents><![CDATA[4]]></hourly_price_cents>
            <monthly_price_cents><![CDATA[30]]></monthly_price_cents>
            <my_attribute><![CDATA[my attrs! 4]]></my_attribute>
            <weekly_price_cents><![CDATA[15]]></weekly_price_cents>
            <photos/>
            <availability_rules/>
          </listing>
        </listings>
        <availability_rules/>
        <amenities/>
      </location>
    </locations>
  </company>
</companies>
          XML
        end
        new(path)
      end
    end
  end

end

