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

Then /^Sees sorting reviews dropdown with selected Left by this seller option$/ do
  page.should have_css('[data-reviews-dropdown]')
  find('[data-reviews-dropdown] span.title').should have_content(I18n.t('user_reviews.reviews_left_by_this_seller'))
end

And /^Review for buyer$/ do
  page.should have_css('.review', count: 1)
  page.should have_content(@review_by_seller.reviewable.owner.first_name)
end

When /^Visitor clicks on Left by this buyer option$/ do
  find('[data-reviews-dropdown]').click
  all('[data-reviews-dropdown] li').last.click
end

Then /^List of reviews should be updated$/ do
  page.should have_css('.review', count: 1)
  page.should have_content(@review_by_buyer.reviewable.creator.first_name)
end
