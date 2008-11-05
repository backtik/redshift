require '../redshift.red'

Document.ready? do
  container = Document['#container']
  blue      = Document['#blue']
  green     = Document['#green']

  container.insert(green,  :inside)
  container.insert(blue,   :before)

  pink      = Element.new(:div)
  Document.body.insert(pink)
  
  pink.classes << :foo
  pink.set_styles({:margin => '10px 5px'})
  puts pink.styles[:marginLeft]
  
end
