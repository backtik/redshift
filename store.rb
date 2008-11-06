# Classes mixing in <tt>Store</tt> gain the ability to store
# properties related to DOM objects without causing memory-sapping circular
# references.
# 
module Store
  `#{Store}.__table__={}`
  
  # call-seq:
  #   obj.delete(sym) -> obj
  # 
  # Deletes the property _sym_, then returns _obj_.
  # 
  def delete(property)
    `var stringId=''+this.__id__`
    storage = `#{Store}.__table__[stringId]`
    storage = `#{Store}.__table__[stringId]=#{{}}` unless storage
    value = storage[property]
    value = nil if `value==null`
    `delete storage.__contents__[property.m$hash()]`
    return value
  end
  
  # call-seq:
  #   obj.retrieve(sym, default = nil) -> object or default
  # 
  # Returns the property _sym_, or _default_ if the property is not defined.
  # 
  def fetch(property, deflt = nil)
    `var stringId=''+this.__id__`
    storage = `#{Store}.__table__[stringId]`
    storage = `#{Store}.__table__[stringId]=#{{}}` unless storage
    value   = storage[property.to_sym]
    value   = storage[property.to_sym] = deflt unless `$T(value)||value==false`
    return value
  end
  
  # call-seq:
  #   obj.store(hash) -> object
  # 
  # Stores the key-value pairs as properties of _obj_, then returns _obj_.
  # 
  def store(hash)
    `var stringId=''+this.__id__`
    storage = `#{Store}.__table__[stringId]`
    storage = `#{Store}.__table__[stringId]=#{{}}` unless storage
    hash.each {|property,value| storage[property.to_sym] = value }
  end
end
