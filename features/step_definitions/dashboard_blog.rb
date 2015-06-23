Given /I visit blog section of dashboard/ do
  visit dashboard_blog_path
end

Given /user blogging is enabled for my instance/ do
  @user = model!('user')
  @user.instance.update_attribute :user_blogs_enabled, true
end

Then(/^I should be able to enable my blog$/) do
  @user.instance.user_blogs_enabled.should be_true
  visit edit_dashboard_blog_path
  find_by_id('user_blog_enabled').set true
  find_by_id('user_blog_name').set 'Super cool blog'
  click_button 'Save'
  page.should have_content('Blog settings have been saved.')
  @user.blog.enabled.should be_true
end
