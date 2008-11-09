require '../redshift.red'

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
    
   puts green.size.inspect
   puts green.scroll.inspect
   puts container.scrolls.inspect
   puts green.scroll_size.inspect
   
   puts container.scroll_to(100,40).inspect
   puts green.offset_parent.inspect
   puts green.offsets.inspect
   puts green.position_at(40,200).inspect
   puts green.styles.inspect
   puts green.position.inspect
   
   puts Document.height
   puts Document.width
   puts Document.scroll_top
   puts Document.scroll_left
   puts Document.scroll_height
   puts Document.scroll_width
   puts Document.top
   puts Document.left
   
   puts Document.size.inspect
   puts Document.scroll.inspect
   puts Document.scroll_size.inspect
   puts Document.position.inspect
   puts Document.coordinates.inspect
     
   
   puts Window.height
   puts Window.width
   puts Window.scroll_top
   puts Window.scroll_left
   puts Window.scroll_height
   puts Window.scroll_width
   puts Window.top
   puts Window.left
   
   puts Window.size.inspect
   puts Window.scroll.inspect
   puts Window.scroll_size.inspect
   puts Window.position.inspect
   puts Window.coordinates.inspect
end
