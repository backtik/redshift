describe Array do
  self.it 'intersects' do
    ([1,1,3,5] & [1,2,3]).should_equal([1, 3])
  end
  
  self.it 'sets values with bracket notation' do
    a = []
    a[0] = 1
    a.should_equal([1])
  end
end
