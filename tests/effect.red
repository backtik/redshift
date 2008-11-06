require '../redshift'

Document.ready? do
  black = Document['#black']
  e = Tween.new(black)
  black.listen :click do |element,event|
    e.start(:background_color, '#000', '#F00')
  end
  
  blue = Document['#blue']
  f = Tween.new(blue)
  
  blue.listen :click do |element,event|
    f.start(:height, 0)
  end
  
  g = Tween.new(Document['#green'])
  g.start(:background_color, '#001212','#fff')
end
