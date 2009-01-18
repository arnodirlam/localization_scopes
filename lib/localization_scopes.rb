module LocalizationScopes
  module TranslationScopeHelper
    def t_scope(*args)
      with_options(:scope => args) { |s| yield(s) }
    end
  
    def t_context_scope
      t_scope(get_scope_of_context) { |s| yield(s) }
    end
  
    def tc(*args)
      t_context_scope { |s| s.translate(*args) }
    end
    
  private
    def get_scope_of_context
      stack_to_analyse = $lc_test_get_scope_of_context_stack || caller
      app_dirs = '(helpers|controllers|views|models)'
      latest_app_file = stack_to_analyse.detect { |level| level =~ /.*\/app\/#{app_dirs}\// }
      return [] unless latest_app_file
      
      path = latest_app_file.match(/([^:]+):\d+.*/)[1]
      dir, file = path.match(/.*\/app\/#{app_dirs}\/([^\.]+)/)[1, 2]
      
      scope = file.split('/')
      case dir
      when 'controllers'
        scope.last.gsub! /_controller$/, ''
      when 'helpers'
        scope.last.gsub! /_helper$/, ''
      when 'views'
        scope.last.gsub! /^_/, ''
      when 'models'
        scope.last.gsub! /_observer$/, ''
      end
      
      scope.join('.')
    end
  end
end

ActionController::Base.send :extend, LocalizationScopes::TranslationScopeHelper
ActionController::Base.send :include, LocalizationScopes::TranslationScopeHelper
ActiveRecord::Base.send :extend, LocalizationScopes::TranslationScopeHelper
ActiveRecord::Base.send :include, LocalizationScopes::TranslationScopeHelper
ActionMailer::Base.send :extend, LocalizationScopes::TranslationScopeHelper
ActionMailer::Base.send :include, LocalizationScopes::TranslationScopeHelper
ActionView::Base.send :include, LocalizationScopes::TranslationScopeHelper
