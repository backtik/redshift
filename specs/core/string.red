Spec.describe String do |it|
  it.can 'initialze with the " " literals' do
    'red'.should_equal(String.new('red'))
  end
  
  it.can 'format itself using sprintf notation' do
    ("%05d" % 123).should_equal('00123')
  end
  
  it.can 'multiply by a number' do
    ('abc ' * 3).should_equal('abc abc abc ')
  end
  
  it.can 'be added to another string' do
    ('abc' + 'def').should_equal('abcdef')
  end
  
  it.can 'have new characters added to its end' do
    ('abc' << 'def').should_equal('abcdef')
    'abc'.concat('def').should_equal('abcdef')
  end
  
  it.can 'have new numbers added to its end, which become characters if between 0 and 255' do
    ('a' << 103 << 104).should_equal('agh')
    ('a'.concat(103).concat(104)).should_equal('agh')
  end
  
  it.can 'compare itself to other strings' do
    ('abcdef' <=> 'abcde'  ).should_equal(1)
    ('abcdef' <=> 'abcdef' ).should_equal(0)
    ('abcdef' <=> 'abcdefg').should_equal(-1)
    ('abcdef' <=> 'ABCDEF' ).should_equal(1)
  end
  
  # TODO: BROKE
  it.can 'check if it is equal to another string' do
    # ('abc' == 'abc').should_equal(true)
    # ('abc' == 'ac').should_equal(false)
  end
  
  it.can 'return a capitalized version of itself' do
    a = 'abcdef'
    b = a.capitalize
    b.should_equal('Abcdef')
    a.should_equal('abcdef')
    
    a = 'ABCDEF'
    b = a.capitalize
    b.should_equal('Abcdef')
    a.should_equal('ABCDEF')
    
    a = '123ABC'
    b = a.capitalize
    b.should_equal('123abc')
    a.should_equal('123ABC')
  end
  
  it.can 'capitalize itself' do
    a = 'abcdef'
    b = a.capitalize!
    b.should_equal('Abcdef')
    a.should_equal('Abcdef')
    
    a = 'ABCDEF'
    b = a.capitalize!
    b.should_equal('Abcdef')
    a.should_equal('Abcdef')
    
    a = '123ABC'
    b = a.capitalize!
    b.should_equal('123abc')
    a.should_equal('123abc')
  end
end