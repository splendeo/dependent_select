require "dependent_select/dependent_select.rb"
require "dependent_select/form_helpers.rb"
require "dependent_select/includes_helper.rb"

if Object.const_defined?(:Rails) && File.directory?(Rails.root.to_s + "/public")  
  ActionView::Helpers::FormHelper.send(:include, DependentSelect::FormHelpers)
  ActionView::Base.send(:include, DependentSelect::FormHelpers)
  ActionView::Base.send(:include, DependentSelect::IncludesHelper)
  
  # install files
  unless File.exists?(RAILS_ROOT + '/public/javascripts/dependent_select/dependent_select.js')
    ['/public', '/public/javascripts/dependent_select'].each do |dir|
      source = File.dirname(__FILE__) + "/../#{dir}"
      dest = RAILS_ROOT + dir
      FileUtils.mkdir_p(dest)
      FileUtils.cp(Dir.glob(source+'/*.*'), dest)
    end
  end
end