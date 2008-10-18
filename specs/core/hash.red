Spec.describe Hash do |it|
  it.can 'delete an item' do
    a = {:a => '1', :b => 2}
    a.delete(:a) 
    a == {:b => 2}
  end
  
  it.returns 'the deleted object when deleting by key' do
    {:a => 1, :b => 2}.delete(:a) == 2
  end
end