# frozen_string_literal: true
require 'googl'
require 'sanitize'
require 'addressable'

module Liquid
  module Filters
    module PlatformFilters
      # @param template - url template
      # @param [String] url
      # @return params [Hash]
      # @example
      # /search/Sydney/BlueRoad + /search/{city}/{street}
      # returns { city: Sydney, street: 'BlueRoad'}
      def extract_url_params(url, template)
        Addressable::Template.new(template).extract(Addressable::URI.parse(url))
      end

      # @param template - url template
      # @param params [Hash]
      # @return [String] url
      # @example
      # /search/{city}/{street} + { city: Sydney, street: 'BlueRoad'} produces
      # /search/Sydney/BlueRoad
      def expand_url_template(template, params)
        Addressable::Template.new(template).expand(params).to_s
      rescue
        template
      end

      # @return [String] url shortened using the Google service
      # @param url [String] the original url to be shortened
      def shorten_url(url)
        if DesksnearMe::Application.config.googl_api_key.present?
          Googl.shorten(url, nil, DesksnearMe::Application.config.googl_api_key).short_url
        else
          Googl.shorten(url).short_url
        end
      # We use Exception to silence exceptions already encountered coming from the Goo.gl service;
      # a MarketplaceLogger error will be logged
      rescue Exception => e
        if Rails.env.production?
          MarketplaceLogger.error('Url Shortening Error', e.to_s + ' :: ' + url, raise: false)
          ''
        else
          'http://limitreached'
        end
      end

      # @return Boolean returns true if provided user satisfies policy with specified name
      #   two arguments are equal, nil otherwise
      # @param user [UserDrop] user object - in most scenarios it will be current_user
      # @param object_name [String] name  - name of the form_cofiguration or page slug to which
      #   we want to check access
      # @param object_type [String] name string - by default form_configuration, can also be page
      def authorized?(user, object_name, object_type = 'form_configuration', _params = {})
        AuthorizeAction.new(object: AuthorizationPolicy::AuthorizableFetcher.new(object_name: object_name,
                                                                                object_type: object_type).fetch,
                            user: user.source).authorize
      rescue AuthorizeAction::UnauthorizedAction
        false
      end

      # @return [String, nil] returns class_name (by default 'active') if the first
      #   two arguments are equal, nil otherwise
      # @param arg1 [String] any string - will be used for comparison with the other string
      # @param arg2 [String] any string - will be used for comparison with the other string
      def active_class(arg1, arg2, class_name = 'active')
        class_name if arg1 == arg2
      end

      # @return [Boolean] whether the array includes the element given
      # @param array [Array] array of elements where we look into
      # @param el [Object] we will look for this element inside the array
      def is_included_in_array(array, el)
        array.include?(el)
      end

      # @return [Array] result contains all elements from both arrays.
      # @param array [Array] base array
      # @param obj [Object] we will transform object into array and add it to the other. Method
      #   is called soft, because it will not crash when nil is provided as argument
      def soft_concat(array, obj)
        Array.wrap(array) + Array.wrap(obj)
      end

      # @return [Array<Array<Object>>] the original array split into groups having the size
      #   specified by the second parameter (an array of arrays)
      # @param array [Array<Object>] array to be split into groups
      # @param integer [Integer] the size of each group the array is to be split into
      def in_groups_of(array, integer)
        array.in_groups_of(integer)
      end

      # @return [Hash<MethodResult => Array<Object>>] the original array grouped by method
      #   specified by the second parameter
      # @param objects [Array<Object>] array to be grouped
      # @param method [String] method name to be used to group Objects
      def group_by(objects, method)
        objects.group_by(&method.to_sym)
      end

      # @return [String] pluralized version of the input string
      # @param string [String] string to be pluralized
      # @param count [Number] optional count number based on which string will be pluralized or singularized
      def pluralize(string, count = 2)
        count == 1 ? string.try(:singularize) : string.try(:pluralize)
      end

      # @return [Array<Object>] array from which nil values are removed
      # @param array [Array<Object>] array from which to remove nil values
      def compact(array)
        array.compact
      end

      # @return [Array<Object>] array to which we add the item given as the second parameter
      # @param array [Array<Object>] array to which we add a new element
      # @param item [Object] item we add to the array
      def add_to_array(array, item)
        Array(array.presence).push(item)
      end

      # @return [Array<Object>] the input array rotated by a number of times given as the second
      #   parameter; [1,2,3,4] rotated by 2 gives [3,4,1,2]
      # @param array [Array<Object>] array to be rotated
      # @param count [Integer] number of times to rotate the input array
      def rotate(array, count = 1)
        array.rotate(count)
      end

      # @return [String] formatted price using the global price formatting rules
      # @param amount [Numeric] amount to be formatted
      # @param currency [String] currency to be used for formatting
      def pricify(amount, currency = 'USD')
        render_money(amount.to_f.to_money(currency))
      end

      # @return [String] formatted price using the global price formatting rules
      # @param amount [Numeric] amount in cents to be formatted
      # @param currency [String] currency to be used for formatting
      def pricify_cents(amount, currency = 'USD')
        render_money(Money.new(amount.to_i, currency))
      end

      # @return [String] formatted price using the global price formatting rules; the default currency will be used
      # @param money [Numeric] amount to be formatted
      def price_with_cents_with_currency(money)
        render_money(money)
      end

      # @return [String] formatted price using the global price formatting rules; the default currency will be used
      # @param money [Numeric] amount to be formatted
      # @todo Duplicate of price_with_cents_with_currency; they should be unified into one method; requires making
      #   sure we're not affecting marketplaces already using them
      def price_without_cents_with_currency(money)
        render_money(money)
      end

      # @return [String] formatted price using the global price formatting rules; the default currency will be used
      # @param money [Numeric] amount to be formatted
      # This should be used instead of the deprecated price_with_cents_with_currency and price_without_cents_with_currency
      def render_price(money)
        render_money(money)
      end

      # @return [String] formatted price using the global price formatting rules, displayed as negative amount; the default currency will be used
      # @param money [Numeric] amount to be formatted
      def price_with_cents_with_currency_as_cost(money)
        pricify(money.to_f * -1, money.currency)
      end

      # @return [String] a human readable string derived from the input; capitalizes the first word, turns
      #   underscores into spaces, and strips a trailing '_id' if present. Meant for creating pretty output.
      # @param key [String] input string to be transformed
      def humanize(key)
        key.try(:humanize)
      end

      # @return [String] translation value taken from translations for the key given as parameter
      # @param key [String] translation key
      # @param options [Hash{String => String}] values passed to translation string
      def translate(key, options = {})
        ::I18n.t(key, options.deep_symbolize_keys).html_safe
      end
      alias t translate

      # @return [String, nil] formatted representation of the passed in DateTime object
      # @param datetime [String, DateTime] DateTime object to be formatted; can be a string and it will be converted
      #   to a date
      # @param format [String] the format to be used for formatting the date; default is 'long'; other values can be used:
      #   they are taken from translations, keys are of the form 'time.formats.#!{format_name}'
      def localize(datetime, format = 'long')
        if datetime
          datetime = datetime.to_date if datetime.is_a?(String)
          ::I18n.l(datetime, format: format.to_sym)
        end
      end
      alias l localize

      # @return [Date] input date/time to which the number_of_days days have been added; use negative values to obtain
      #   a date in the past
      # @param date [Date] date to which we add number_of_days
      # @param number_of_days [Integer] number of days to add to the input date
      def add_to_date(date, number_of_days)
        date + number_of_days.days
      end

      def is_date_in_past(date)
        to_date(date)&.past?
      end

      # @return [String] filtered version of the input text using the marketplace global text filters
      # @param text [String] text to be filtered
      def filter_text(text = '')
        return text unless text.is_a?(String)
        return '' if text.blank?
        if PlatformContext.current.instance.apply_text_filters
          @text_filters ||= TextFilter.pluck(:regexp, :replacement_text, :flags)
          @text_filters.each { |text_filter| text.gsub!(Regexp.new(text_filter[0].strip, text_filter[2]), text_filter[1]) }
        end
        text
      end

      # @return [Integer] minutes since the start of day for the date parsed from the input string
      # @param string [String] string representing a date/time
      def parse_to_minute(string)
        time = parse_time(string)
        hour = time.strftime('%H')
        minute = time.strftime('%M')
        hour.to_i * 60 + minute.to_i
      end

      # @return [String] time in string in HH:MM format 24h clock
      # @param minutes [Integer] number of minutes
      def number_of_minutes_to_time(minutes)
        minutes = minutes.to_i % 1440 # in case we made overnight booking
        hours = (minutes.to_f / 60).floor
        minutes -= (hours * 60)
        "#{'%.2d' % hours}:#{'%.2d' % minutes}"
      end

      # @return [Time] a Time object obtained/parsed from the input object
      # @param string [String] object from which we try to obtain/parse a date object
      def to_time_from_str(string)
        parse_time(string)
      end

      # @return [Date] a Date object obtained/parsed from the input object
      # @param datetime [Date, String, Object] object from which we try to obtain/parse a date object
      def to_date(datetime)
        datetime.try(:to_date)
      end

      # @return [String] sanitized version of the input string; uses a whitelist based approach for allowed elements
      #   and their attributes; the sanitization rules are not currently editable from the marketplace interface
      # @param html [String] HTML string to be sanitized
      def custom_sanitize(html = '')
        return '' if html.blank?
        html = html.to_s
        html = nl2br(html)

        if PlatformContext.current.instance.custom_sanitize_config.present?
          @custom_sanitizer ||= CustomSanitizer.new(PlatformContext.current.instance.custom_sanitize_config)
          @custom_sanitizer.sanitize(html).html_safe
        else
          html
        end
      end

      # @return [String] sanitized version of the input string; uses a strict approach which means it will
      #   strip all HTML and leave only safe text behind
      # @param html [String] HTML string to be sanitized
      def strip_tags(html = '')
        return '' if html.blank?
        html = html.to_s
        @custom_sanitizer ||= CustomSanitizer.new
        @custom_sanitizer.strip_tags(html).html_safe
      end

      # @return [String] replaces newlines in the input string with the <br /> HTML tag
      # @param html [String] HTML string to be processed
      def nl2br(html = '')
        return '' if html.blank?
        html = html.to_s
        html.gsub!("\r\n", '<br />')
        html
      end

      # @return [String] sanitized input string to be used as a meta tag content; uses a strict approach which means it
      #   will strip all HTML and leave only safe text behind; also will replace one or more spaces with a single space
      #   and will strip beginning and ending blank characters
      # @param content [String] string to be sanitized
      def meta_attr(content)
        Sanitize.clean(content).gsub(/\s+/, ' ').strip
      end

      # @return [String] if the given url is supported, an HTML formatted string containing a video player (inside an iframe)
      #   which will play the video at the given url; otherwise an empty string is returned
      # @param url [String] url to a video on the internet
      def videoify(url = '', options = {})
        return url if url.blank?

        options.symbolize_keys!
        embedder_options = {}
        embedder_options = { iframe_attributes: options } if options.present?

        Videos::VideoEmbedder.new(url, embedder_options).html.html_safe
      end

      # @return [String] JSON formatted string containing a representation of object
      # @param object [Object] object we want a JSON representation of
      def json(object)
        object.to_json
      end

      # @return [String] SHA1 digest of the input object
      # @param object [Object] input object whose digest we want to obtain
      def sha1(object)
        Digest::SHA1.hexdigest object
      end

      # @return [String] full url to the image given as a parameter; e.g. 'chevron.jpg' | image_url
      # @param path_to_file [String] file name or relative path to file
      def image_url(path_to_file)
        ActionController::Base.helpers.image_url(path_to_file)
      end

      # @return [String] returns a url for the given url helper name and the given arguments; allows to generate
      #   any url inside our platform; e.g. 'user_path' | generate_url: id: 1 generates /users/1
      def generate_url(url_name, *args)
        return "unknown route #{url_name}" unless UrlGenerator.respond_to_missing?(url_name)

        UrlGenerator.public_send(url_name, *args)
      end

      # @return [String] returns a url for the given url helper name and the given arguments with the user temporary token;
      # e.g: 'user_path' | generate_url_with_user_token: current_user, id: 1 generates /users/1?temporary_token=TOKEN_HERE
      def generate_url_with_user_token(url_name, user, args = {})
        generate_url url_name, args.merge(TemporaryTokenAuthenticatable::PARAMETER_NAME => user.source.temporary_token)
      end

      # @return [String] returns a url for the given page slug, which includes user temporary token;
      # e.g: '/account' | url_for_with_token: current_user generates https://example.com/account?temporary_token=TOKEN_HERE
      def url_for_path_with_token(path, user)
        'https://' +
          PlatformContext.current.decorate.host +
          path +
          "?#{TemporaryTokenAuthenticatable::PARAMETER_NAME}=#{user.source.temporary_token}"
      end

      # @return [Time] a time object created from parsing the string representation of time given as input
      # @param time [String] a string representation of time for example 'today', '3 days ago' etc.
      def parse_time(time, format = nil)
        parsed_time = case time
                      when /\A\d+\z/, Integer
                        Time.zone.at(time.to_i)
                      when String
                        Chronic.parse(time) || time&.to_time(:local)
                      end

        format.blank? ? parsed_time : parsed_time.strftime(format.to_s)
      end

      # @return [Time] a time object created from time in string
      # @param time [String] a string representation of time in hours and minutes, like 4:0 -> 4:00
      # @param zone [String] string representing the time zone
      # 16:3 -> 16:03 etc
      def to_time(time, zone = nil)
        ActiveSupport::TimeZone[zone || Time.zone.name]&.parse(time.to_s)
      end

      # @return [String] the input text marked as 'HTML safe'; this ensures that all HTML content will be output to the
      #   page; otherwise, without this filter the text would be sanitized;
      #   e.g. !{{ @some_variable_with_html_contents | make_html_safe }}
      # @param html [String] input string to mark as 'HTML safe'
      def make_html_safe(html = '')
        html.to_s.html_safe
      end

      # @return [String] input string HTML-escaped; this will return a string whose HTML tags will be visible in
      #   the browser
      # @param value [String] input string to be HTML-escaped
      def raw_escape_string(value)
        CGI.escapeHTML(value.to_s).html_safe
      end

      # @return [String] capitalizes all the words and replaces some characters in the string to create
      #   a nicer looking title; it is meant for creating pretty output
      # @param text [String] string to be processed
      def titleize(text)
        text.to_s.titleize
      end

      # @return [String] a query string (e.g. "name=Dan&id=1") from a given Hash (e.g. { name: 'Dan', id: 1 })
      # @param hash [Hash{Object => Object}] hash to be "querified"
      def querify(hash)
        hash.to_query
      end

      # @return [String] replaces special characters in a string so that it may be used as part of a 'pretty' URL;
      #   the default separator used is '-'; e.g. 'John arrived_foo' becomes 'john-arrived_foo'
      # @param text [String] input string to be 'parameterized'
      # @param separator [String] string to be used as separator in the output string; default is '-'
      def parameterize(text, separator = '-')
        text.parameterize(separator)
      end

      # @return [String] replaces special characters in a string so that it may be used as part of a 'pretty' URL;
      #   e.g. 'John arrived_foo' becomes 'john-arrived-foo'
      # @param text [String] input string to be 'slugified'
      def slugify(text)
        parameterize(text)
          .tr('_', '-')
      end

      # @return [Boolean] whether the given string matches the given regular expression
      # @param string [String] string we check against the regular expression
      # @param regexp [String] string representing a regular expression pattern against which
      #   we try to match the first parameter
      def matches(string, regexp)
        return false if regexp.blank?
        !!(string =~ Regexp.new(regexp))
      end

      # @return [Array<Object>] array of objects obtained from the original array of objects
      #   (passed in as the object parameter) by calling the method 'method' on each object
      #   in the original array
      # @param object [Array<Object>] array of objects to be processed
      # @param method [String] method name to be called on each of the objects in the passed
      #   in array of objects
      def map(object, method)
        object.map do |o|
          if o.is_a?(Hash)
            o[method]
          else
            o.public_send(method)
          end
        end
      end

      # @example
      #   items => [{id: 1, name: 'foo', label: 'Foo'}, {id: 2, name: 'bar', label: 'Bar'}]
      #   {{ items | map_attributes: 'id', 'name' }} => [[1, 'foo'], [2, 'bar']]
      #
      # @return [Array<Array>] array of arrays with values for given keys
      # @param array [Array<Object>] array of objects to be processed
      # @param attributes [Array<String>] array of keys to be extracted
      def map_attributes(array, *attributes)
        array.map { |a| a.values_at(*attributes) }
      end

      # @return [Array<Object>] that exists in both arrays
      # @param array [Array<Object>] array of objects to be processed
      # @param other_array [Array<Object>] array of objects to be processed
      def intersection(array, other_array)
        array & other_array
      end

      # @return [Array<Object>] that is a difference between two arrays
      # @param array [Array<Object>] array of objects to be processed
      # @param other_array [Array<Object>] array of objects to be processed
      def subtract_array(array, other_array)
        Array.wrap(array) - Array.wrap(other_array)
      end

      # @return [Array<Object>] with objects
      # @param array [Array<Array>] array of arrays to be processed
      def flatten(array)
        array.flatten
      end

      # @return [Object] with first object from collection that matches provided conditions
      # @param objects [Array<Object>] array of objects to be processed
      # @param conditions [Hash] hash with conditions { field_name: value }
      def detect(objects, conditions = {})
        objects.detect do |object|
          return object if conditions.to_a.all? do |attrib, val|
            object[attrib] == val
          end
        end
      end

      # @return [Array<Object>] with objects from collection that matches provided conditions
      # @param objects [Array<Object>] array of objects to be processed
      # @param conditions [Hash] hash with conditions { field_name: value }
      def select(objects, conditions = {})
        objects.select do |object|
          conditions.to_a.all? do |attrib, val|
            object[attrib] == val
          end
        end
      end

      # @return [String] formatted representation of the date object; the formatted representation
      #   will be based on what the format parameter specifies
      # @param date [Date, Time, DateTime] date object
      # @param format [String] string representing the desired output format
      # @param zone [String] string representing the time zone
      #   e.g. '%Y-%m-%d' will result in something like '2020-12-12'
      def strftime(date, format, zone = nil)
        date&.in_time_zone(zone || Time.zone.name)&.strftime(format)
      end

      # @return [MoneyDrop] a Money object constructed with the given amount and currency
      # @param amount [Float] currency amount
      # @param currency [String] name of the currency
      def to_money(amount, currency)
        Money.new(amount, currency)
      end

      # @return [String] formatted HTML snippet containing the translated time (using the 'short' format)
      #   e.g. <abbr class='timeago' title='2020-11-26T03:36:07+12:00'>3:35</abbr>
      # @param time [Time] time object
      def timeago(time)
        "<time class='timeago' datetime='#{time.to_time.iso8601}'>#{l(time, 'short')}</time>".html_safe
      end

      # @return [String] processed text with markdown syntax changed to HTML
      # @param text [String] text using markdown syntax
      def markdownify(text)
        markdown = MarkdownWrapper.new(text)
        markdown.to_html
      end

      # @return [String] returns string padded from left to length of count with symbol character
      # @param str [String] string to pad
      # @param count [Integer] minimum length of output string
      # @param symbol [String] string to pad with
      def pad_left(str, count, symbol = ' ')
        str.to_s.rjust(count, symbol)
      end

      # @return [String] returns mobile number in E.164 format; recommended for sending sms notifications
      # @param number [String] the base part of mobile number
      # @param country [String] country for which country code should be used. Can be anything - full name, iso2, iso3
      def to_mobile_number(number, country)
        PhoneHelper.new(number: number, country: country).full_number
      end

      # @return [Boolean] checks if given array contains at least one queried string/number
      # @param arr [Array] array to search through
      # @param query [String, Number] String/Number compared to each item in the given array
      def any(arr = [], query = 'true')
        Array(arr).any? { |item| item == query }
      end

      # @return [Integer]
      # @param query [param] value to be coersed to posivite integer
      # @param arr [default] default value in case param is not valid positive integer

      def to_positive_integer(param, default)
        CoercionHelpers::SearchPaginationParams.to_positive_integer(param, default)
      end
    end
  end
end
