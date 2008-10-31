require 'javascripts/browser.red'
require 'javascripts/window.red'
require 'javascripts/document.red'
require 'javascripts/element.red'
require 'javascripts/accessors.red'
require 'javascripts/situated.red'
require 'javascripts/selectors.red'

Document.ready? do
  container = Document['#container']
  blue      = Document['#blue']
  green     = Document['#green']
  
  puts green.height
  puts green.width
  puts green.scroll_top
  puts green.scroll_left
  puts green.scroll_height
  puts green.scroll_width
  puts green.top
  puts green.left
  #
  puts green.size
  puts green.scroll
  puts green.scrolls
  puts green.scroll_size
  # puts green.scroll_to(x,y)
  # puts green.offset_parents
  puts green.offsets
  # puts green.position_at(x,y)
  # puts green.calculate_position
  puts green.position
  # 
  # 
  puts Document.height
  puts Document.width
  puts Document.scroll_top
  puts Document.scroll_left
  puts Document.scroll_height
  puts Document.scroll_width
  puts Document.top
  puts Document.left
  
  puts Document.size
  puts Document.scroll
  puts Document.scroll_size
  puts Document.position
  puts Document.coordinates.inspect
  
  
  puts Window.height
  puts Window.width
  puts Window.scroll_top
  puts Window.scroll_left
  puts Window.scroll_height
  puts Window.scroll_width
  puts Window.top
  puts Window.left
  
  puts Window.size
  puts Window.scroll
  puts Window.scroll_size
  puts Window.position
  puts Window.coordinates.inspect
end
