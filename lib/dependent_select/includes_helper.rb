module DependentSelect::IncludesHelper
  # returns html necessary to load the javascript needed for dependent_select
  def dependent_select_includes(options = {})
    return "" if @ds_already_included
    @ds_already_included=true
    
    javascript_include_tag("dependent_select/dependent_select")
  end
end
