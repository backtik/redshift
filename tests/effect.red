require 'javascripts/browser.red'
require 'javascripts/transform.red'
require 'javascripts/transforms/css.red'
require 'javascripts/transforms/tween.red'
require 'javascripts/user_events.red'
require 'javascripts/code_events.red'
require 'javascripts/element.red'
require 'javascripts/accessors.red'
require 'javascripts/selectors.red'
require 'javascripts/document.red'

Document.ready? do
  # e = Transform.new
  # e.start(400,100)
  e = Tween.new(Document['#black'])
  e.start(:background_color, '#000', '#f00')
  
  e = Tween.new(Document['#blue'])
  e.start(:height, 220)
  
  e = Tween.new(Document['#green'])
  e.start(:background_color, '#fff')
end
