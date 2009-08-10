
function update_dependent_select( dependent_id, observed_id, values_array, // mandatory
  initial_value, include_blank, collapse_spaces, first_run ) {             // optional
  
  // parse the optional parameters ....
  initial_value = initial_value || '';
  include_blank = include_blank || false;
  collapse_spaces = collapse_spaces || false;
  first_run = first_run || false;

  // select DOM node whose options are modified
  var dependent_field = $(dependent_id);

  // select DOM node whose changes trigger this
  var observed_field = $(observed_id);

  // value chosen on observed_select, used for filtering dependent_select
  var filter = observed_field.value;

  // the first time the update_func is executed (on edit) the value the select has
  // comes directly from the model. From them on, it will only use the client's input
  var previous_value = first_run ? initial_value : dependent_field.value;

  // removes all options from dependent_field
  dependent_field.childElements().each( function(o) { o.remove(); } );

  // adds a blank option, only if specified on options
  if(include_blank) {
    dependent_field.appendChild(new Element('option', {selected: !previous_value})); // it will be selected if previous_value is nil
  }

  // this fills the dependent select
  values_array.each (function (e) {
    if (e[2]==filter) {                                        // only include options with the right filter field
      var opt = new Element('option', {value: e[1]});          // create one <option> element...
      if(collapse_spaces) { opt.text= e[0];}                   // assign the text (spaces are automatically collapsed)
      else { opt.text = e[0].replace(/ /g, '\240'); }          // replacing spaces with &nbsp; if requested
      if(opt.value == previous_value) { opt.selected=true; }   // mark it as selected if appropiate
      dependent_field.options[dependent_field.options.length]=opt; // attach to depentent_select.. could not use "add"
    }
  });

  // launch a custom event (Prototype doesn't allow launcthing "change") to support dependencies of dependencies
  dependent_field.fire('DependentSelectFormBuilder:change');
}