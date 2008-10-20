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
end