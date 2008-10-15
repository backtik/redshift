require('javascripts/browser.red')
# require('javascripts/window.red')
require('javascripts/document.red')
require('javascripts/element.red')

Document.ready? do
  one = Document['#a']
  puts one.inspect
end

