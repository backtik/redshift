require 'javascripts/browser.red'
require 'javascripts/selectors.red'
require 'javascripts/element.red'
require 'javascripts/document.red'

Document.ready? do
  # puts Document['#c_element'].has_class?('boo')
  # puts Document['#c_element'].previous_element.inspect
  # puts Document['#c_element'].previous_elements.inspect
  # puts Document['#b_element'].next_element.inspect
  # puts Document['#b_element'].next_elements.inspect  
  # puts Document['#container'].first_child.inspect
  # puts Document['#container'].last_child.inspect
  # puts Document['#c_element'].parent.inspect
  # puts Document['#b_inner_element'].parents.inspect
  # puts Document['#container'].children.inspect
  puts Document['#container']['#b_inner_element'].inspect
  puts Document['#container']['div'].inspect
  puts Document['#query_string_form']['input, textarea'].inspect
end
