require 'javascripts/browser.red'
require 'javascripts/element.red'
require 'javascripts/selectors.red'
require 'javascripts/document.red'

Document.ready? do
  container = Document['#container']
  blue      = Document['#blue']
  green     = Document['#green']
  container.insert(green,  :inside)
  container.insert(blue,   :before)
end
