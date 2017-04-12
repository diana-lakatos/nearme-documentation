# frozen_string_literal: true
class I18n::LanguagesWrapper
  CHINESE_LANGUAGES = {
    'zh-CN' => 'Chinese Simplified, PRC',
    'zh-SG' => 'Chinese Simplified, Singapore',
    'zh-TW' => 'Chinese Traditional, Taiwan',
    'zh-HK' => 'Chinese Traditional, Hong Kong S.A.R.',
    'zh-MO' => 'Chinese Traditional, Macao S.A.R.'
  }.freeze

  def self.languages_for_select
    return @i18n_languages if defined? @i18n_languages

    i18n_languages = I18nData.languages.reject { |key, _value| key == 'ZH' }.map do |lang|
      translated_name = begin
                          I18nData.languages(lang[0])[lang[0]].mb_chars.capitalize
                        rescue
                          lang[1].capitalize
                        end
      [lang[1].capitalize, lang[0].downcase, { 'data-translated' => translated_name }]
    end

    chinese_name_translated = I18nData.languages('ZH')['ZH'].mb_chars.capitalize

    CHINESE_LANGUAGES.each do |key, value|
      i18n_languages << [value, key, { 'data-translated' => chinese_name_translated }]
    end

    @i18n_languages = i18n_languages.sort { |lang1, lang2| lang1[0] <=> lang2[0] }
  end

  def self.language_name(code)
    name = I18nData.languages[code.upcase]

    if name.blank?
      CHINESE_LANGUAGES[code]
    else
      name
    end
  end

  def self.language_codes
    return @language_codes if defined? @language_codes

    language_codes = I18nData.languages.map { |l| Regexp.escape(l[0].downcase) }
    language_codes.delete('zh')
    language_codes += CHINESE_LANGUAGES.keys
    @language_codes = language_codes.sort
  end
end
