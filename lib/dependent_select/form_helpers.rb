# Various helpers available for use in your view
module DependentSelect::FormHelpers

  # Similar to collection_select form helper, but adds a "filter_method" parameter
  # the generated code includes a javascript observer that modifies the select
  # using the value of a form method.
  #
  # == Parameters
  #   +object_name+:: The name of an object being modified by this select. Example: +:employee+
  #   +method+:: The name of a method of the object designated by "object_name" that
  #              this select affects. Example: +:city_id+
  #   +collection+:: The collection used for generating the +<options>+ on the
  #                  select. Example: +@cities+
  #   +value_method+:: The method that returns the value of each +<option>+ when
  #                    applied to each element on +collection+.
  #                    Example: +:id+ (for city.id)
  #   +text_method+:: The method that returns the text of each +<option>+ when
  #                   applied to each to each element on +collection+.
  #                   Example: +:name+ (for city.name)
  #   +filter_method:: The method being used for filtering. For example,
  #                    +:province_id+ will filter cities by province.
  #                    Important notice: this parameter also sets the DOM field
  #                    id that should be used for getting the filter value.
  #                    In other words, setting this to :province_id and the +object_name+ to
  #                    :employee will mean that somewhere on your form there will be a
  #                    field called "employee_province_id", used for filtering.
  #   +options+:: (Optional) Usual options for +collection_select+ (such as
  #               +include_blank+) plus 3 new ones, detailed below.
  #   +html_options+:: (Optional)The same html options as +collection_select+.
  #                    They are appended to the html +select+ as attributes.
  # == Options
  # In addition to all options for +collection_select+, several new options are available
  #
  # === :collapse_spaces
  # By default, blank spaces are collapsed on browsers when printing the select option texts
  # For example, given the following html:
  #    <select>
  #       <option>This  option    should   have      lots of       spaces   on its text</option>
  #    </select>
  # Most browsers will "collapse" the spaces, and present something like this instead:
  #       "This option should have lots of spaces on its text"
  # Setting collapse_spaces to false will replace the blanks with the &nbsp; character.
  # This is accomplised on the javascript function using code similar to the following
  #
  #    option_text.replace(/ /g, "\240"); // "\240" is the octal representation of charcode 160 (nbsp)
  #
  # On the following example, a sale occurs on a store that belongs to a company. The store model
  # has a method called +name_for_selects+ that prints a two-column text - the first column has
  # the company name on it, while the second has the store address. They are separated by a '|'
  # character, and padded with spaces when necesary (company name has 10 chars or less)
  #
  #    class Store < ActiveRecord::Model
  #      belongs_to :company
  #      has_many :sales
  #      validates_presence_of :address
  #
  #      def name_for_selects
  #        "#{company.name.ljust(10)} | #{address}"
  #      end
  #    end
  #
  # Now on the edit/new sale view, we will need to use the :collapse_spaces option like this:
  #
  #    <%= dependent_collection_select(:sale, :store_id, @stores, :id, :name_for_selects, :company_id,
  #          {:collapse_spaces => true}, {:class => 'monospaced'})
  #     %>
  #
  # It is recommended that you use this function in conjunction with a monospaced css style. The following
  # rule should be available, for example on application.css:
  #
  #    .monospaced {
  #      font-family: monospaced;
  #    }
  #
  # === :filter_field
  # The javascript employed for updating the dependent select needs a field for getting
  # the "filter value". The default behaviour is calculating this field name by using the
  # +:object_name+ and +:filter_value+ parameters. For example, on this case:
  #
  #    <%= dependent_collection_select(:sale, :province_id, @provinces, :id, :name, :country_id) %>
  #
  # +:object_name+ is +:sale+, and +:filter_id+ is +:country_id+, so the javascript will look
  # for a field called +'sale_country_id'+ on the html.
  #
  # It is possible to override this default behaviour by specifying a +:filter_field+ option.
  # For example, in this case:
  #
  #    <%= dependent_collection_select(:sale, :province_id, @provinces, :id, :name, 
  #          :country_id, {:filter_field => :state_id})
  #     %>
  #
  # This will make the javascript to look for a field called +'sale_state_id+
  # Notice that the chain 'sale_' is still appended to the field name. It is possible to override this
  # by using the +:complete_filter_field+ option istead of this one.
  #
  # The most common use of this property will be for dealing with multiple relationships between the same
  # models. See the complex example below for details.
  #
  # === :complete_filter_field
  # Works the same way as :filter_field, except that it uses its value directly, instead
  # of appending the :object_name at all. For example:
  #
  #    <%= dependent_collection_select(:sale, :province_id, @provinces, :id, :name, 
  #          :country_id, {:complete_filter_field => :the_province})
  #     %>
  #
  # This will make the javascript to look for a field called +'the_province'+ on the
  # page, and use its value for filtering.
  #
  # === :array_name
  # dependent_select generates a javascript array with all the options available to the dependent select.
  # By default, the name of that variable is automatically generated using the following formula:
  #
  #    js_array_name = "ds_#{dependent_field_id}_array"
  #
  # This can be overriden by using the js_array_name option (its value will be used instead of the previous)
  #
  # This is useful because, by default, dependant_select forms will keep track of generated arrays, and *will not*
  # generate the same array twice. This is very useful for situations in which lots of dependent_selects have
  # to be generated, with the same data. For example, a flight has a destination and origin city:
  #
  #    <%= dependent_collection_select( :flight, :origin_city_id, @cities, :id, :name, :province_id,
  #          { :filter_field => :origin_province_id, js_array_name => 'cities_array' }
  #     %>
  #
  #    <%= dependent_collection_select( :flight, :destination_city_id, @cities, :id, :name, :province_id,
  #          { :filter_field => :destination_province_id, js_array_name => 'cities_array' }
  #     %>
  #
  # This example will generate the first javascript array and call it cities_array. Then the second
  # call to +dependent_select+ is done, the form will already know that the javascript for this script
  # is generated, so it will not generate an array.
  #
  # The +:array_name+ option can also be used in the opposite way: to force the generation of an array.
  # This should happen very rarely - two dependent selects generate the same object name and method but are not
  # supposed to use the same list of values.
  #
  # == Examples
  #
  # === Example 1: A store on a City
  # In a form for creating a Store, the three selects used for Store, Province and City.
  #
  # views/Stores/new and views/Stores/edit:
  #
  #    <p>
  #      Country:
  #      <%= collection_select :store, :country_id, @countries, :id, :name %>
  #    </p><p>
  #      Province:
  #      <%= dependent_collection_select :store, :province_id, @provinces, :id, :name, :country_id %>
  #    </p><p>
  #      City:
  #      <%= dependent_collection_select :store, :city_id, @cities, :id, :name, :province_id %>
  #    </p>
  #
  # Notes:
  #   * The first helper is rail's regular +collection_select+, since countries don't
  #     "depend" on anything on this example.
  #   * You only need a +city_id+ on the +stores+ table (+belongs_to :city+).
  #
  #  You need to define methods on your model for obtaining a +province_id+ and
  #  +country_id+. One of the possible ways is using rails' +delegate+ keyword. See
  #  example below (and note the +:include+ clause)
  #
  #    class Store < ActiveRecord::Base
  #      belongs_to :city, :include => [{:province => :country}] #:include not necessary, but nice
  #      delegate :country, :country_id, :country_id=, :to =>:city, :allow_nil => true
  #      delegate :province, :province_id, :province_id=, :to =>:city, :allow_nil => true
  #    end
  #
  # This delegates the +province_id+ and +country_id+ methods to the +:city+ object_name.
  # So a City must be able to handle country-related stuff too. Again, using +delegate+, you can
  # do:
  #
  #    class City < ActiveRecord::Base
  #      belongs_to :province, :include => [:country]
  #      delegate :country, :country_id, :country_id=, :to =>:province, :allow_nil => true
  #    end
  #
  # Note that I've also delegated +province+, +province=+, +country+ and +country=+ .
  # This is so I'm able to do things like +puts store.country.name+.
  # This is convenient but not needed.
  #
  # === Example 2: Using html_options
  # Imagine that you want your selects to be of an specific css class, for formatting.
  # You can accomplish this by using the +html_options+ parameter
  #
  #    <p>
  #      Country:
  #      <%= collection_select :store, :country_id, @countries, :id, :name,
  #            {:include_blanks => true}, {:class=>'monospaced'}
  #       %>
  #    </p><p>
  #      Province:
  #      <%= dependent_collection_select :store, :province_id, @provinces, :id, :name,
  #            :country_id, {:include_blanks => true}, {:class=>'brightYellow'}
  #       %>
  #    </p><p>
  #      City:
  #      <%= dependent_collection_select :store, :city_id, @cities, :id, :name,
  #            :province_id, {:include_blanks => true}, {:class=>'navyBlue'}
  #       %>
  #    </p>
  #
  # Notice the use of +{}+ for the +:options+ parameter. If we wanted to include +html_options+
  # but not options, we would have had to leave empty brackets.
  #
  # === Example 3: Multiple relations and +:filter_field+
  # Imagine that you want your stores to have two cities instead of one; One for
  # importing and another one for exporting. Let's call them +:import_city+ and
  # +:export_city+:
  #
  # Models/Store.rb:
  #
  #     class Store < ActiveRecord::Base
  #
  #      belongs_to :import_city, :class_name => "City", :include => [{:province => :country}]
  #      delegate :country, :country_id, :country_id=, :to =>:import_city,
  #        :allow_nil => true, :prefix => :import
  #      delegate :province, :province_id, :province_id=, :to =>:import_city,
  #        :allow_nil => true, :prefix => :import
  #
  #      belongs_to :export_city, :class_name => "City", :include => [{:province => :country}]
  #      delegate :country, :country_id, :country_id=, :to =>:export_city,
  #        :allow_nil => true, :prefix => :export
  #      delegate :province, :province_id, :province_id=, :to =>:export_city,
  #        :allow_nil => true, :prefix => :import
  #    end
  #
  # In this case, the store doesn't have a +:city_id+, +:country_id+ or +:province_id+. Instead, it has
  # +:export_city_id+, +:export_country_id+ and +:export_province_id+, and the same for import.
  #
  # We'll have to use the +:filter_field+ option in order to use the right field for
  # updating the selects.
  #
  # views/Stores/new and views/Stores/edit:
  #
  #    <p>
  #      Import Country:
  #      <%= collection_select :store, :import_country_id, @countries, :id, :name %>
  #    </p><p>
  #      Import Province:
  #      <%= dependent_collection_select :store, :import_province_id, @provinces, :id, :name,
  #            :country_id, :filter_field => :import_country_id, :array_name => 'provinces_array'
  #       %>
  #    </p><p>
  #      Import City:
  #      <%= dependent_collection_select :store, :import_city_id, @cities, :id, :name,
  #            :province_id, :filter_field => :import_province_id, :array_name => 'cities_array'
  #       %>
  #    </p><p>
  #      Export Country:
  #      <%= collection_collection_select :store, :export_country_id, @countries, :id, :name %>
  #    </p><p>
  #      Export Province:
  #      <%= dependent_collection_select :store, :export_province_id, @provinces, :id, :name,
  #            :country_id, :filter_field => :export_country_id, :array_name => 'provinces_array'
  #       %>
  #    </p><p>
  #      Export City:
  #      <%= dependent_select :store, :export_city_id, @cities, :id, :name,
  #            :province_id, :filter_field => :export_province_id, :array_name => 'cities_array'
  #       %>
  #    </p>
  # Notice the use of +:array_name+. This is optional, but greatly reduces the amount of js code generated
  #
  def dependent_collection_select(object_name, method, collection, value_method, 
    text_method, filter_method, options = {}, html_options = {}
  )
    object, options, extra_options = dependent_select_process_options(object_name, options)

    initial_collection = dependent_select_initial_collection(object,
      method, collection, value_method)
    
    tag, dependent_field_id = dependent_collection_select_build_tag(
      object_name, object, method, initial_collection, value_method, 
      text_method, options, html_options)

    script = dependent_select_js_for_collection(object_name, object, method, 
      collection, value_method, text_method, filter_method, options, html_options,
      extra_options, dependent_field_id)
      
    return "#{tag}\n#{script}"
  end


  # Similar to +select+ form helper, but generates javascript for filtering the
  # results depending on the value on another field.
  # Consider using +dependent_collection_select+ instead of this one, it will probably
  # help you more. And I'll be updating that one more often.
  # == Parameters
  #   +object_name+:: The name of the object being modified by this select. 
  #                   Example: +:employee+
  #   +method+:: The name of the method on the object cadded "object_name" that this
  #              will affect. Example: +:city_id+
  #   +choices_with_filter+:: The structure is +[[opt1_txt, opt1_value, opt1_filter],
  #                           [opt2_txt, opt2_value, opt2_filter] ... ]+.
  #   +filter_method:: The method being used for filtering. For example,
  #                    +:province_id+ will filter cities by province.
  #                    Important notice: this parameter also sets the DOM field
  #                    id that should be used for getting the filter value.
  #                    In other words, setting this to :province_id and the +object_name+ to
  #                    :employee will mean that somewhere on your form there will be a
  #                    field called "employee_province_id", used for filtering.
  #   +options+ and +html_options+:: See +dependent_collection_select+.
  # == Examples
  #
  # === Example 1: Types of animals
  # Create an animal on a children-oriented app, where groups and subgroups
  # are predefined constants.
  #
  # models/animal.rb
  #
  #    class Animal < ActiveRecord::Base
  #      GROUPS = [['Invertebrates', 1], ['Vertebrates', 2]]
  #      SUBGROUPS = [
  #        ['Protozoa', 1, 1], ['Echinoderms',2,1], ['Annelids',3,1], ['Mollusks',4,1],
  #        ['Arthropods',5,1], ['Crustaceans',6,1], ['Arachnids',7,1], ['Insects',8,1],
  #        ['Fish',9,2], ['Amphibians',10,2], ['Reptiles',11,2], ['Birds',12,2],
  #        ['Mammals',13,2], ['Marsupials',14,2], ['Primates',15,2], ['Rodents',16,2],
  #        ['Cetaceans',17,2], ['Seals, Seal Lions and Walrus',18,2]
  #      ]
  #    end
  #
  # new/edit animal html.erb
  #
  #    <p>
  #      Group: <%= select :animal, :group_id, Animal::GROUPS %>
  #    </p><p>
  #      Subgroup: <%= select :animal, :subgroup_id, :group, Animal::SUBGROUPS %>
  #    </p>
  #
  def dependent_select(object_name, method, choices_with_filter, filter_method,
    options = {}, html_options = {})

    object, options, extra_options = dependent_select_process_options(object_name, options)

    initial_choices = dependent_select_initial_choices(object, method, choices_with_filter)
    
    tag, dependent_field_id = dependent_select_build_tag(
      object_name, object, method, initial_collection, value_method, 
      text_method, options, html_options)

    script = dependent_select_js(object_name, method, choices_with_filter,
      filter_method, options, html_options, extra_options)
    
    return "#{tag}\n#{script}"
  end

  private
    #holds the names of the arrays already generated, so repetitions can be avoided.
    def dependend_select_array_names
      @dependend_select_array_names ||= {}
    end
  
    # extracts any options passed into calendar date select, appropriating them to either the Javascript call or the html tag.
    def dependent_select_process_options(object_name, options)
      options, extra_options = DependentSelect.default_options.merge(options), {}
      for key in [:collapse_spaces, :filter_field, :complete_filter_field, :array_name]
        extra_options[key] = options.delete(key) if options.has_key?(key)
      end
       
      object = options.delete(:object) || instance_variable_get("@#{object_name}")
      
      options[:object]=object

      [object, options, extra_options]
    end

    # generates the javascript that will follow the dependent select
    # contains:
    #  * An array with all the possible options (structure [text, value, filter])
    #  * An observer that detects changes on the "observed" field and triggers an update
    #  * An extra observer for custon events. These events are raised by the dependent_select itself.
    #  * An first call to update_dependent_select, that sets up the initial stuff
    def dependent_select_js(object_name, object, method, choices_with_filter, 
      filter_method, options, html_options, extra_options, dependent_field_id)

      # the js variable that will hold the array with option values, texts and filters
      js_array_name = extra_options[:array_name] || "ds_#{dependent_field_id}_array"
      
      js_array_code = ""
      
      if(dependend_select_array_names[js_array_name].nil?)
        dependend_select_array_names[js_array_name] = true;
        js_array_code += "#{js_array_name} = #{choices_with_filter.to_json};\n"    
      end
      
      observed_field_id = dependent_select_calculate_observed_field_id(object_name, object,
        filter_method, html_options, extra_options)
      initial_value = dependent_select_initial_value(object, method)
      include_blank = options[:include_blank] || false
      collapse_spaces = extra_options[:collapse_spaces] || DependentSelect.collapse_spaces?
      
      
      if(DependentSelect.use_jquery?)
        js_function = 'update_depentent_select_jquery'
      else
        js_function = 'update_dependent_select'
      end
      
      js_callback =
        "function(e) { #{js_function}( '#{dependent_field_id}', '#{observed_field_id}', #{js_array_name}, " +
        "'#{initial_value}', #{include_blank}, #{collapse_spaces}, false); }"
      
      if(DependentSelect.use_jquery?)
        observers = "$('##{observed_field_id}').change(#{js_callback});\n"
      else
        observers = "$('#{observed_field_id}').observe('change', #{js_callback});\n" +
          "$('#{observed_field_id}').observe('DependentSelectFormBuilder:change', #{js_callback}); \n"
      end

      initial_call =
        "#{js_function}( '#{dependent_field_id}', '#{observed_field_id}', #{js_array_name}, " +
        "'#{initial_value}', #{include_blank}, #{collapse_spaces}, true);\n"

      return javascript_tag(js_array_code + observers + initial_call)
    end
    
    # generates the js script for a dependent_collection_select. See +dependent_select_js+
    def dependent_select_js_for_collection(object_name, object, method, collection, 
      value_method, text_method, filter_method, options, html_options, extra_options, dependent_field_id)

      # the array that, converted to javascript, will be assigned values_var variable,
      # so it can be used for updating the select
      choices_with_filter = collection.collect do |c|
        [ c.send(text_method), c.send(value_method), c.send(filter_method) ]
      end

      dependent_select_js(object_name, object, method, choices_with_filter, 
        filter_method, options, html_options, extra_options, dependent_field_id)
    end
    
    # returns a collection_select html string and the id of the generated field
    def dependent_collection_select_build_tag(object_name, object, method, collection, value_method, 
      text_method, options, html_options)
      dependent_field_id, it = dependent_select_calculate_field_id_and_it(object_name, 
        object, method, html_options)
      
      tag = it.to_collection_select_tag(collection, value_method, text_method, options, html_options)
      
      return [tag, dependent_field_id]
    end
    
    # returns a select html string and the id of the generated field
    def dependent_select_build_tag(object_name, object, method, choices, options = {}, html_options = {})
      
      dependent_field_id, it = dependent_select_calculate_field_id_and_it(object_name, 
        object, method, html_options)
      
      tag = it.to_select_tag(choices, options, html_options)
      
      return [tag, dependent_field_id]
    end

    # Calculates the dom id of the observed field, usually concatenating object_name and filt. meth.
    # For example, 'employee_province_id'. Exceptions:
    #  * If +extra_options+ has an item with key +:complete_filter_field+, 
    #    it returns the value of that item
    #  * If +extra_options+ has an item with key +:filter_field+,
    #    it uses its value instead of +method+
    def dependent_select_calculate_observed_field_id(object_name, object, method, 
      html_options, extra_options)
      
      return extra_options[:complete_filter_field] if extra_options.has_key? :complete_filter_field
      method = extra_options[:filter_field] if extra_options.has_key? :filter_field

      return dependent_select_calculate_field_id(object_name, object, method, html_options)
    end
    
    # calculates the id of a generated field
    def dependent_select_calculate_field_id(object_name, object, method, html_options)
      field_id, it = dependent_select_calculate_field_id_and_it(object_name, object, method, html_options)
      return field_id
    end
    
    # ugly hack used to obtain the generated id from a form_helper
    # uses the method ActionView::Helpers::InstanceTag.add_default_name_and_id,
    # ...which is a private method of an internal class of rails. filty.
    def dependent_select_calculate_field_id_and_it(object_name, object, method, html_options)
      it = ActionView::Helpers::InstanceTag.new(object_name, method, self, object)
      html_options = html_options.stringify_keys
      it.send :add_default_name_and_id, html_options #use send since add_default... is private
      return [ html_options['id'], it]
    end
    
    # Returns the collection that will be used when the dependent_select is first displayed
    # (before even the first update_dependent_select call is done)
    # The collection is obained by taking all the elements in collection whose value
    # equals to +initial_value+. For example if we are editing an employee with city_id=4,
    # we should put here all the cities with id=4 (there could be more than one)
    def dependent_select_initial_collection(object, method, collection, value_method)
      initial_value = dependent_select_initial_value(object, method)
      return collection.select { |c| c.send(value_method) == initial_value }
    end

    # this is +dependent_select+'s version of +dependent_select_initial_collection+ 
    def dependent_select_initial_choices(object, method, choices_with_filter)
      initial_value = dependent_select_initial_value(object, method)
      return choices_with_filter.select { |c| c[1] == initial_value }
    end

    # The value that the dependend select will have when first rendered. It could be different from
    # nil, if we are editing. Example: if we are editing an employee with city_id=4, then 4 should be
    # the initial value.
    def dependent_select_initial_value(object, method)
      return object.send(method) || "" if object
      return ""
    end


end

# Helper method for form builders
module ActionView
  module Helpers
    class FormBuilder
      def dependent_select( method, choices_with_filter, filter_method, 
        options = {}, html_options = {}
      )
        @template.dependent_select(@object_name, method, choices_with_filter, 
          filter_method, options.merge(:object => @object), html_options)
      end
      
      def dependent_collection_select( method, collection, value_method, 
        text_method, filter_method, options = {}, html_options = {}
      )
        @template.dependent_collection_select(@object_name, method, collection, 
          value_method, text_method, filter_method,
          options.merge(:object => @object), html_options)
      end
    end
  end
end
