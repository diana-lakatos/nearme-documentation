Given /a blog instance exists for this instance/ do
  @instance = Instance.first
  @blog_instance = FactoryGirl.create(:blog_instance, owner: @instance)
end

Given /I am logged in as blog admin for this blog instance/ do
  @role = FactoryGirl.create(:instance_admin_role_blog, instance_id: @instance.id)
  @user = FactoryGirl.create(:user)
  @instance_admin = FactoryGirl.create(:instance_admin, :user_id => @user.id, :instance_id => @instance.id)
  @instance_admin.update_attribute(:instance_owner, false)
  @instance_admin.update_attribute(:instance_admin_role_id, @role.id)
  login @user
end

Then(/^I can manage blog posts$/) do
  visit '/instance_admin/manage_blog/posts'
  click_link 'New post'
  fill_in 'Title', with: 'Great title!'
  fill_in 'Content', with: 'Content'
  click_button 'Save'
  page.should have_content('New blog post has been added. ')
  @blog_instance.blog_posts.last.title.should == 'Great title!'

  find('//a[title=Edit]').click
  fill_in 'Title', with: 'Another title.'
  click_button 'Save'
  page.should have_content('Blog post has been updated.')
  @blog_instance.blog_posts.last.title.should == 'Another title.'

  find('//a[title=Delete]').click
  page.should have_content('Blog post has been deleted.')
  @blog_instance.blog_posts.reload.should be_empty
end

And(/^I can manage tags for posts/) do
  visit '/instance_admin/manage_blog/posts'
  click_link 'New post'
  fill_in 'Title', with: 'Great title!'
  fill_in 'Content', with: 'Content'
  fill_in 'Tag list', with: 'tag1,tag2'
  
  assert_difference 'Tagging.count', 2 do
    click_button 'Save'
  end
end

Then(/^I can manage settings for a blog$/) do
  visit '/instance_admin/manage_blog/settings/edit'

  fill_in 'Name', with: 'Desks Near Me blog'
  click_button 'Hidden submit'

  page.should have_content('Blog settings were updated.')
  @blog_instance.reload.name.should == 'Desks Near Me blog'
end

Given(/^I am at blog mainpage$/) do
  @user = FactoryGirl.create(:user)
  @blog_post = FactoryGirl.create(:blog_post,
                                   blog_instance: @blog_instance,
                                   published_at: 2.days.ago,
                                   user: @user)
  @next_blog_post = FactoryGirl.create(:blog_post,
                                        blog_instance: @blog_instance,
                                        published_at: 1.day.ago,
                                        user: @user)
  @another_blog_post = FactoryGirl.create(:blog_post, user: @user)

  visit '/blog/'

  page.should have_content(@blog_post.title)
  page.should have_content(@next_blog_post.title)
  page.should_not have_content(@another_blog_post.title)
end

Then(/^I can visit post page$/) do
  click_link(@blog_post.title)

  page.should have_content(@blog_post.title)
  page.should_not have_content(@next_blog_post.title)
end

Then(/^I can go to another post page$/) do
  page.should_not have_content('LAST STORY')
  click_link('NEXT STORY')

  page.should have_content(@next_blog_post.title)
  page.should_not have_content(@blog_post.title)
end

Given /user blogging is enabled for this instance/ do
  @instance.update_attribute :user_blogs_enabled, true
end

And(/^we have some user blog posts$/) do
  @user = FactoryGirl.create(:user)
  @user.create_blog
  FactoryGirl.create(:published_user_blog_post, user: @user, title: 'This blog post is going to be promoted')
end

Then(/^I can promote one user blog post$/) do
  visit '/instance_admin/manage_blog/user_posts'

  find('//a[title=Edit]').click
  find('//input[id=user_blog_post_highlighted]').set true
  click_button 'Hidden submit'
  page.should have_content('Blog post has been updated.')
  @user.published_blogs.first.highlighted.should be_true
end

Then(/^a visitor should see promoted blog post in main blog$/) do
  visit '/blog/'
  page.should have_content('This blog post is going to be promoted')
end

Given(/^that I am on blog's homepage$/) do
  visit '/blog/'
end

And(/^it has two posts$/) do
  2.times { FactoryGirl.create(:blog_post, blog_instance: @blog_instance) }
end

And(/^I click on RSS Feed button$/) do
  page.find('.rss-feed-button').click
end

Then(/^the feed xml should have (\d+) node(.*)$/) do |amount, plural|
  doc = Nokogiri::XML.parse(page.html)
  assert_equal amount.to_i, doc.xpath('//item').count
end

And(/^the latest has tag "(.*?)" associated$/) do |tag_name|
  blog_post = BlogPost.last
  blog_post.tag_list = tag_name
  blog_post.save!
end

And(/^I filter for a tag$/) do
  page.all('.tag-filter-link a').first.click
end

Then(/^I should see "(.*?)" in it's content$/) do |tag_name|
  assert page.text.downcase.include?(tag_name)
end

