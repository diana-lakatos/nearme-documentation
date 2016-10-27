Given /^Visitor goes to the user page$/ do
  visit user_path(@user, tab: 'reviews')
end

Given /^User exists$/ do
  @user = FactoryGirl.create(:user)
end

Given /^Rating systems exists$/ do
  @rs_for_products = FactoryGirl.create(:rating_system, subject: RatingConstants::TRANSACTABLE)
  @rs_for_buyer = FactoryGirl.create(:rating_system, subject: RatingConstants::GUEST)
  @rs_for_seller = FactoryGirl.create(:rating_system, subject: RatingConstants::HOST)
end

When /^Goes to reviews tab$/ do
  find('.reviews-tab').click
end

Then /^Sees no reviews blank state$/ do
  page.should have_content(I18n.t('user_profile.labels.visitor.no_reviews', name: @user.first_name))
end

Given /^Reviews about the seller exist$/ do
  @listing = FactoryGirl.create(:transactable)
  @reservation = FactoryGirl.create(:reservation, transactable: @listing)
  @user = @listing.creator

  FactoryGirl.create(:review, rating_system: @rs_for_seller, user: @reservation.owner, reviewable: @reservation)
  FactoryGirl.create(:review, rating_system: @rs_for_buyer, user: @reservation.creator, reviewable: @reservation)
end

Then /^Sees one seller reviews$/ do
  page.should have_css('#reviews', count: 1)
  page.should have_content(@user.first_name)
end

Given /^Reviews left by the user exist$/ do
  @reviewable = FactoryGirl.create(:reservation)
  @review_by_buyer = FactoryGirl.create(:review, rating_system: @rs_for_seller, user: @reviewable.owner, reviewable: @reviewable)
  @user = @reviewable.owner
end

And /^seller respond to review$/ do
  @reviewable ||= FactoryGirl.create(:reservation)
  @review_by_seller = FactoryGirl.create(:review, rating_system: @rs_for_buyer, user: @reviewable.creator, reviewable: @reviewable)
  @user = @reviewable.owner
end

Given /^TransactableType has show_reviews_if_both_completed field set to (.*)$/ do |value|
  TransactableType.first.update_column :show_reviews_if_both_completed, value == 'true'
end

Then /^Sees sorting reviews dropdown with selected Left by this seller option$/ do
  page.should have_css('[data-reviews-dropdown]')
  find('[data-reviews-dropdown] span.title').should have_content(I18n.t('user_reviews.reviews_left_by_this_seller', first_name: @user.first_name))
end

And /^Review for buyer$/ do
  page.should have_css('.review', count: 1)
  page.should have_content(@review_by_seller.reviewable.owner.first_name)
end

And /^should not see Review for buyer$/ do
  page.should_not have_css('.review')
  page.should_not have_content(@review_by_seller.reviewable.owner.first_name)
end

When /^Visitor clicks on Left by this buyer option$/ do
  find('[data-reviews-dropdown]').click
  all('[data-reviews-dropdown] li').last.click
end

Then /^List of reviews should be updated$/ do
  page.should have_css('.review', count: 1)
  page.should have_content(@review_by_buyer.reviewable.creator.first_name)
end

Given /^Reviews left by the user exist for pagination$/ do
  10.times do
    @reservation = FactoryGirl.create(:reservation)
    @review_by_seller = FactoryGirl.create(:review, rating_system: @rs_for_seller, user: @reservation.creator, reviewable: @reservation)
    @review_by_buyer = FactoryGirl.create(:review, rating_system: @rs_for_buyer, user: @reservation.owner, reviewable: @reservation)
  end
  @user = @reservation.owner
end

And /^Pagination with active first page$/ do
  page.should have_css('.reviews .pagination')
  page.should have_css('.reviews .pagination a.active', text: '1')
end

When /^Visitor clicks on next page$/ do
  find('.reviews .pagination .next_page').click
end

Then /^Sees second page$/ do
  page.should have_css('.reviews .pagination a.active', text: '2')
end
