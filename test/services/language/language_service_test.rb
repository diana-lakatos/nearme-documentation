require 'test_helper'

class LanguageServiceTest < ActiveSupport::TestCase

    test 'cleans language params codes before usage' do
        language_service = Language::LanguageService.new([:en, 'en', '', nil], [], [])
        assert_equal language_service.language_params, [:en]
    end

    test 'cleans fallback languages codes before usage' do
        language_service = Language::LanguageService.new([], [:de, 'de', :es, 'es', nil, ''], [])
        assert_equal language_service.fallback_languages, [:de, :es]
    end

    test 'cleans available languages codes before usage' do
        language_service = Language::LanguageService.new([], [], [:de, 'de', :es, 'es', :en, 'en', nil, ''])
        assert_equal language_service.available_languages, [:de, :es, :en]
    end

    test 'uses locale from params when available' do
        language_service = Language::LanguageService.new([:es], [], [:es, :de, :en])
        assert_equal language_service.get_language, :es
    end

    test 'uses fallback locale when locale from params is not available' do
        language_service = Language::LanguageService.new([:es], [:de, :en], [:de, :en])
        assert_equal language_service.get_language, :de
    end

end
