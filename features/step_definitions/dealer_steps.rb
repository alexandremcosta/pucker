Given /^a dealer$/ do
  @dealer = Pucker::Dealer.new
end

When /^I receive (\d+) cards$/ do |n|
  @cards = []
  n.to_i.times do
    @cards << @dealer.deal
  end
end

Then /^they should be different$/ do
  @cards.uniq.length.should == @cards.length
end

