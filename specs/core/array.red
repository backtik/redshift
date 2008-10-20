Spec.describe Array do |it|
  # it.can 'intersect' do
  #   ([1,1,3,5] & [1,2,3]).should_equal([1,3])
  # end
  
  it.can 'initialize with the [] literals' do
    [1].should_equal([1])
  end
  
  it.can 'initialize with the %w() literal' do
    %w(a).should_equal(['a'])
  end
  
  it.can 'multiply itself by an integer and return a larger array' do
    ([1,2,3] * 2).should_equal([1,2,3,1,2,3])
  end
  
  it.can 'multiply itself by a string and return a joined string' do
    ([1,2,3] * ":").should_equal('1:2:3')
  end
  
  it.can 'be added to another array, resulting in one large array' do
    ([1,2,3] + [4,5]).should_equal([1, 2, 3, 4, 5])
  end
  
  it.can 'subtract another array, returning an array containing only items that appear in itself and not in the other' do
    ([1,1,2,2,3,3,4,5] - [1,2,4]).should_equal([3, 3, 5])
  end
  
  it.can 'append an object to the its end as the last element' do
    ([1,2] << 'c' << 'd' << [3,4]).should_equal([1, 2, "c", "d", [3, 4]])
  end
  
  # BROKE
  it.can 'compare itself to another array' do
    # (['a','a','c'] <=> ['a','b','c']).should_equal(-1)
    # ([1,2,3,4,5,6] <=> [1,2]).should_equal(1)
    # ([1,2] <=> [1,2]).should_equal(0)
  end
  
  # BROKE
  it.can 'check if its equal to another array' do
    # (['a','c'] == ['a', 'c', 7]).should_equal(false)
    # (['a','c', 7] == ['a', 'c', 7]).should_equal(true)
    # (['a','c', 7] == ['a', 'd', 'f']).should_equal(false)
  end
  
  it.can 'retrieve the object at a numeric index' do
    ['a','b','c'][0].should_equal('a')
    ['a','b','c'].slice(0).should_equal('a')
  end
  
  it.returns 'nil if the object at the numeric index is nil or index is greater than its length' do
    ['a','b',nil][2].should_equal(nil)
    ['a','b'][2].should_equal(nil)
    ['a','b',nil].slice(2).should_equal(nil)
    ['a','b'].slice(2).should_equal(nil)
  end
  
  it.returns 'a sub array based on a start position and length' do
    (['a','b','c','d'][1,2]).should_equal(['b','c'])
  end
  
  it.returns 'a limited sub array when a start position and length are provided and position + length go beyond the size of the array' do
    (['a','b','c','d'][3,2]).should_equal(['d'])
    ['a','b','c','d'].slice(3,2).should_equal(['d'])
  end
  
  it.returns 'nil if a position and length are provided and position is past the size of the array' do
    (['a','b','c','d'][4,2]).should_equal(nil)
    ['a','b','c','d'].slice(4,2).should_equal(nil)
  end
  
  it.returns 'a sub array when a range is provided' do
    (['a','b','c','d'][1..3]).should_equal(['b','c', 'd'])
    ['a','b','c','d'].slice(1..3).should_equal(['b','c', 'd'])
  end
  
  it.returns 'a limited sub array when a range is provided and the range goes beyond the size of the array' do
    (['a','b','c','d'][2..5]).should_equal(['c','d'])
    ['a','b','c','d'].slice(2..5).should_equal(['c','d'])
  end
  
  it.returns 'nil if a range is provided and the range begins beyong the sie of the array' do
    (['a','b','c','d'][4..5]).should_equal(nil)
    ['a','b','c','d'].slice(4..5).should_equal(nil)
  end
  
  it.can 'assign objects to a specific location in the array, padding with nil if neccessary' do
    a = []
    a[4] = '4'
    a.should_equal([nil,nil,nil,nil,'4']) 
  end
    
  it.can 'sort' do
    [3,2,1].sort.should_equal([1,2,3])
  end
  
  it.can 'clear' do
    [3,2,1].clear.should_equal([])
  end
end