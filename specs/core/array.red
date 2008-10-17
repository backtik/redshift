Spec.describe Array do |it|
  it.can 'intersect' do
    ([1,1,3,5] & [1,2,3]) == ([1, 3])
  end
  
  it.can 'sort' do
    [3,2,1].sort == [1,2,3]
  end
end