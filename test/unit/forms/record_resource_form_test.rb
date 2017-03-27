# frozen_string_literal: true
require 'test_helper'

def txt_record
  {
    type: 'TXT',
    value: 'txt record value',
    hosted_zone_name: 'linguamag.eu.',
    ttl: 1000
  }
end

def cname_record
  {
    type: 'CNAME',
    name: 'api',
    value: 'linguamag.eu',
    hosted_zone_name: 'linguamag.eu.',
    ttl: 1000
  }
end

class ResourceRecordFormTest < ActiveSupport::TestCase
  context 'CNAME record' do
    setup do
      @form = ResourceRecordForm.new cname_record
    end

    should 'be properly prepared' do
      assert_equal @form.type, 'CNAME'

      assert_equal(@form.record,
                   name: 'api.linguamag.eu.',
                   type: 'CNAME',
                   resource_records: [
                     { value: 'linguamag.eu' }
                   ],
                   ttl: 1000)
    end
  end

  context 'TXT record' do
    setup do
      @form = ResourceRecordForm.new txt_record
    end

    should 'be properly prepared' do
      assert_equal @form.type, 'TXT'

      assert_equal(@form.record,
                   name: 'linguamag.eu.',
                   type: 'TXT',
                   resource_records: [
                     { value: '"txt record value"' }
                   ],
                   ttl: 1000)
    end
  end
end
