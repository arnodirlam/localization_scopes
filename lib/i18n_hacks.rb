module I18n
  # allow symbol parameter list for defining the scope
  class << self
    alias :translate_single_key_strict :translate

    def translate(*keys)
      opt = keys.last.is_a?(Hash)  ? keys.pop : {}
      key = keys.last.is_a?(Array) ? keys.pop : ''

      if opt[:scope].nil?
        opt[:scope] = keys
      elsif opt[:scope].is_a?(Array)
        opt[:scope] += keys
      else
        opt[:scope] = [opt[:scope]] + keys
      end

      translate_single_key_strict key, opt
    end
    alias :t :translate
  end
end

module ActionView
  module Helpers
    module TranslationHelper
      def translate(*args)
        options = args.last.is_a?(Hash) ? args.pop : {}
        options[:raise] = true
        I18n.translate(*(args << options))
      rescue I18n::MissingTranslationData => e
        keys = I18n.send(:normalize_translation_keys, e.locale, e.key, e.options[:scope])
        content_tag('span', keys.join(', '), :class => 'translation_missing')
      end
      alias :t :translate
    end
  end
end
