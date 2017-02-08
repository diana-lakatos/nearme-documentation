# frozen_string_literal: true
require 'test_helper_lite'
require './app/helpers/coercion_helpers'

class CoercionHelpersTest < ActiveSupport::TestCase
  test 'coverts propertly :page params' do
    default = 1

    # INT-COERCABLE VALUES

    assert_equal to_positive_integer(100, default),     100
    assert_equal to_positive_integer("100", default),   100
    assert_equal to_positive_integer("1_000", default), 1000
    assert_equal to_positive_integer(3.14, default),    3

    # NON-INT VALUES

    assert_equal to_positive_integer('3.14', default),  1

    assert_equal to_positive_integer(-100, default),    default
    assert_equal to_positive_integer("x100", default),  default

    assert_equal to_positive_integer("CONCAT('whs(',')SQLi')", default),                     default
    assert_equal to_positive_integer("',res.setHeader(\"WhiteHat\",\"Test\"),'", default),   default
    assert_equal to_positive_integer("\",res.setHeader(\"WhiteHat\",\"Test\"),\"", default), default
    assert_equal to_positive_integer("<% whs=21705 %>whscheck<%= whs.to_s %>", default),     default
    assert_equal to_positive_integer("+ADw-whscheck+AD4-", default),                         default
    assert_equal to_positive_integer("default'\"><whscheck>", default),                      default

    assert_equal to_positive_integer("whs1SQLi", default),   default
    assert_equal to_positive_integer("Ig==", default),       default
    assert_equal to_positive_integer("&#x22;", default),     default
    assert_equal to_positive_integer("%22", default),        default
    assert_equal to_positive_integer("\"", default),         default
    assert_equal to_positive_integer("Jw==", default),       default
    assert_equal to_positive_integer("&#x27;", default),     default
    assert_equal to_positive_integer("%27", default),        default
    assert_equal to_positive_integer("'", default),          default
    assert_equal to_positive_integer("\\\"", default),       default
    assert_equal to_positive_integer("\\'", default),        default
    assert_equal to_positive_integer("default/0", default),  default
    assert_equal to_positive_integer("1234'5", default),     default
    assert_equal to_positive_integer("() { :", default),     default
    assert_equal to_positive_integer("whs'check", default),  default
    assert_equal to_positive_integer("1501610*2", default),  default
    assert_equal to_positive_integer("6006440/2", default),  default
    assert_equal to_positive_integer("3003240-20", default), default
    assert_equal to_positive_integer("3003200+20", default), default
  end

  def to_positive_integer(value, default)
    CoercionHelpers::SearchPaginationParams.to_positive_integer(value, default)
  end
end
