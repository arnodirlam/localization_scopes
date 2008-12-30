module LocalizationScopes
  def with_scope(*args)
    with_options(:scope => args) { |s| yield(s) }
  end

  def with_context_scope
    with_scope(get_scope_of_context) { |s| yield(s) }
  end

  def tc(*args)
    with_context_scope { |s| s.translate(*args) }
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
    
    scope
  end
end

ActionController::Base.send :extend, LocalizationScopes
ActionController::Base.send :include, LocalizationScopes
ActiveRecord::Base.send :extend, LocalizationScopes
ActiveRecord::Base.send :include, LocalizationScopes
ActionView::Base.send :include, LocalizationScopes
