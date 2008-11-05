require '../redshift'

Document.ready? do
  e = Tween.new(Document['#black'])
  e.start(:background_color, '#000', '#f00')
  
  e = Tween.new(Document['#blue'])
  e.start(:height, 220)
  # 
  # e = Tween.new(Document['#green'])
  # e.start(:background_color, '#fff')
  
end
