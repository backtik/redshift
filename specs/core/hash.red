Spec.describe Hash do |it|
  it.can 'delete an item' do
    {:a => '1', :b => 2}.delete(:a) == {:b => 2}
  end
end