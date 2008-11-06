module Window
  `this.__native__ = window`
  
  def self.window
    self
  end
  
  def self.document
    ::Document
  end
end