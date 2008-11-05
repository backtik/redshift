require 'javascripts/redshift.red'

Document.ready? do
  UserEvents.define(:alt_meta_shift_click, :base => 'click', :condition => proc {|element,event| event.alt? && event.meta? && event.shift? })
  UserEvents.define(:m_key, :base => 'keypress', :condition => proc {|element,event| event.key == :m })
  puts UserEvents::DEFINED_EVENTS.inspect
  elem = Document['#blue']
  text = Document['#text']
  elem.listen(:alt_meta_shift_click) { puts 'Alt+Meta+Shift+Click' }
  elem.listen(:mouse_wheel) { |element,event| puts event.base_type.inspect; puts 'Wheeling' }
  elem.listen(:mouse_enter) { |element,event| puts (element.inspect == event.target.inspect) }
  elem.listen(:mouse_leave) { puts 'Out' }
  text.listen(:m_key)       { puts 'M Key'}
  text.listen(:keypress)    { |element,event| puts event.key.inspect }
end
