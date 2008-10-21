Spec.describe Hash do |it|
  it.can 'initialize itself with { } literals' do
    {'a' => 'b'}.should_equal({'a' => 'b'})
  end
  
  it.can 'initialize itself with through the Hash.new' do
    Hash.new.should_equal({})
  end
  
  # TODO: BROKE
  it.can 'take a default value to return if accessing a missing key' do
    # h = Hash.new('unknown key')
    # h[:not_there].should_equal('unknown key')
  end
  
  # TODO: BROKE
  it.can 'alter the default key by accessing an unknow key and changing it' do
    # h = Hash.new('unknown key')
    # h[:not_there].upcase
    # h[:not_anywhere].should_equal('UNKNOWN KEY')
  end
    
  it.does_not 'store values from the defaults in the hash' do
    h = Hash.new('unknown key')
    h[:a] = 1
    h[:b] = 2
    h.keys.should_equal([:a, :b])
  end
  
  it.can 'determine whether its contents are equal to the contents of another hash' do
    ({'a' => 'b'} == {'a' => 'b'}).should_be_true
    ({'d' => 'b'} == {'a' => 'b'}).should_be_false
  end
  
  it.can 'retrive and element by its key' do
    {:a => 'b'}[:a].should_equal('b')
  end
  
  it.returns 'nil when attempting to retrieve an element with a non-existent key' do
    {:a => 'b'}['n'].should_equal(nil)
  end
  
  it.can 'store an element to be accessed by the provided key' do
    h1 = {}
    (h1['a'] = 'stored').should_equal('stored')
    h1.should_equal({'a' => 'stored'})
    
    h2 = {}
    h2.store('a', 'stored').should_equal('stored')
    
    h2.should_equal({'a' => 'stored'})
  end
  
  it.can 'clear itself' do
    {'a' => 1, 'b' => 2}.clear.should_equal({})
  end
  
  it.can 'default'
  it.can 'default='
  it.can 'default_proc='
  
  it.can 'delete elements' do
    h = {:a => 100, :b => 200}
    h.delete(:a).should_equal(100)
    h.should_equal({:b => 200})
  end
  
  it.can 'delete elements based on a block' do
    h = {:a => 100, :b => 200, :c => 300 }
    h.delete_if {|k,v| v >= 200 }
    h.should_equal({:a => 100})
  end
  
  it.can 'loop' do
    h = {:a => 100, :b => 200, :c => 300 }
    h.each {|k,v| v += 10}
    h.should_equal({:a => 110, :b => 220, :c => 300 })
  end
  
  it.can 'loop through each key'
  it.can 'loop through each value'
  it.can 'be checked for emptiness'
  it.can 'fetch'
  
  it.can 'tell if it includes a key'
  it.can 'tell if it includes a key'
  
  it.can 'return the key for a given value'
  it.returns 'nil if there is no key for a given value'
  
  it.can 'format an inspectable string of itself' do
    h = Hash[:a,100,:b,200].inspect.should_equal("{:a => 100, :b => 200}")
  end
  
  it.can 'return a new hash with keys and values inverted' do
    {:n => 100, :m => 100, :y => 300, :d => 200, :a => 0 }.invert.should_equal({100 => :m, 300 => :y, 200 => :d, 0 => :a})
  end
  
  it.can 'provide an array of its keys' do
    {:a => 100, :b => 200}.keys.should_equal([:a,:b])
  end
  
  it.can 'give its length as a number' do
    h = {:a => 100, :b => 200}
    h.size.should_equal(2)
    h.length.should_equal(2)
  end
  
  it.can 'merge with another hash, retuning a new hash' do
    a = {:a => 100, :b => 200}
    b = a.merge({:a => 150, :c => 300})
    b.should_equal({:a => 150, :b => 200, :c => 300})
    a.should_not_equal(b)
  end
  
  it.can 'merge with another hash altering itself' do
    a = {:a => 100, :b => 200}
    b = a.merge!({:a => 150, :c => 300})
    b.should_equal({:a => 150, :b => 200, :c => 300})
    a.should_equal(b)
  end
  
  it.can 'reject certain elements based on a block and return a new hash'
  it.can 'reject certain elements based on a block and alter its own contents'
  it.can 'replace its contents with the contents of another hash'
  it.can 'select'
  it.can 'remove a key-value pair from itself and return a two-item array [key, value]'
  it.returns 'its default value when attempting to remove a key-value pair from itself and the hash is nil'
  
  it.can 'sort and return an array of nested [key,value] arrays, sorted'
  it.can 'convert to an array of nested [key,value] arrays'
  
  it.can 'convert to a string'
  it.can 'tell if it has a value'
  it.can 'return an array of its values'
  it.can 'return an array of values stored at one or more key location'
end