Given /^Visitor goes to the user page$/ do
  visit user_path(@user)
end

Given /^User exists$/ do
  @user = FactoryGirl.create(:user)
end

When /^Goes to reviews tab$/ do
  find('[data-reviews-count]').click
end

Then /^Sees no reviews blank state$/ do
  page.should have_content(I18n.t('user_profile.labels.visitor.no_reviews', name: @user.name))
end

Given /^Reviews about the seller exist$/ do
  @user = FactoryGirl.create(:user)
  @reservation = FactoryGirl.create(:reservation)
  @reservation.update_column(:creator_id, @user.id)
  @order = FactoryGirl.create(:order_with_line_items, line_items_count: 1)
  line_item = @order.line_items.first
  variant = line_item.variant
  product = variant.product.update(user: @user)
  review_for_reservation = FactoryGirl.create(:review, object: 'seller', user: @reservation.owner, reviewable: @reservation)
  review_for_order = FactoryGirl.create(:review, object: 'seller', user: @order.user, reviewable: line_item)
end

Then /^Sees two seller reviews$/ do
  page.should have_css('.review', count: 2)
  page.should have_content(@reservation.owner.first_name)
  page.should have_content(@order.user.first_name)
end

Given /^Reviews left by the user exist$/ do
  @review_by_seller = FactoryGirl.create(:review, object: 'buyer', user: @user)
  @review_by_buyer = FactoryGirl.create(:review, object: 'seller', user: @user)
end

And /^seller respond to review$/ do
  FactoryGirl.create(:review, object: 'seller', reviewable: @user.reviews.for_buyer.first.reviewable)
end

Given /^TransactableType has show_reviews_if_both_completed field set to (.*)$/ do |value|
  TransactableType.first.update_column :show_reviews_if_both_completed, value == "true"
end

Then /^Sees sorting reviews dropdown with selected Left by this seller option$/ do
  page.should have_css('[data-reviews-dropdown]')
  find('[data-reviews-dropdown] span.title').should have_content(I18n.t('user_reviews.reviews_left_by_this_seller'))
end

And /^Review for buyer$/ do
  page.should have_css('.review', count: 1)
  page.should have_content(@review_by_seller.reviewable.owner.first_name)
end

And /^should not see Review for buyer$/ do
  page.should_not have_css('.review', count: 1)
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
  @review_by_seller = FactoryGirl.create_list(:review, 10, object: 'buyer', user: @user)
  @review_by_buyer = FactoryGirl.create_list(:review, 10, object: 'seller', user: @user)
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
