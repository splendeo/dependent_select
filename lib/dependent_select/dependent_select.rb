module DependentSelect

  # Returns the default_options hash.  These options are by default provided to every calendar_date_select control, unless otherwise overrided.
  # 
  # Example:
  #   # At the bottom of config/environment.rb:
  #   DependentSelect.default_options.update(
  #     :collapse_spaces => false
  #   )
  def self.default_options
    @default_options ||= { :collapse_spaces => true, :use_jquery => false }
  end

  # By default, spaces are collapsed on browsers when printing the select option texts
  # For example:
  #    <select>
  #       <option>This  option    should   have      lots of       spaces   on its text</option>
  #    </select>
  # When you browse that, some browsers collapse the spaces, so you get an option that says
  #       "This option should have lots of spaces on its text"
  # Setting collapse_blanks to false will replace the blanks with the &nbsp; character, using
  # javascript
  #    option_text.replace(/ /g, "\240"); // "\240" is the octal representation of charcode 160 (nbsp)
  def self.collapse_spaces=(value)
    default_options[:collapse_spaces] = value
  end
  
  def self.collapse_spaces?
    default_options[:collapse_spaces]
  end
  
  # By default, dependent_select will use Prototype. If you need to use jquery, you can do so by doing
  #    DependentSelect.use_jquery = true
  def self.use_jquery=(value)
    default_options[:use_jquery] = value
  end
  
  def self.use_jquery?
    default_options[:use_jquery]
  end
end
