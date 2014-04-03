require 'test_helper'

class InstanceViewsSeederTest < ActiveSupport::TestCase

  setup do
    @seeder = Utils::InstanceViewsSeeder.new
  end

  context 'create_instance_view_for_path' do

    should 'create instance view' do
      assert_difference 'InstanceView.count' do 
        2.times do
          @seeder.create_instance_view_for_path('public/index.html.haml', 'content')
        end
      end
      instance_view = InstanceView.last
      assert_equal 'content',  instance_view.body
      assert_equal 'public/index',  instance_view.path
      assert_equal 'en',  instance_view.locale
      assert_equal 'html', instance_view.format 
      assert_equal 'haml',  instance_view.handler
      refute instance_view.partial
    end

    should 'create instance view for public/_index.html.haml with partial true' do
      @seeder.create_instance_view_for_path('public/_index.html.haml', 'content')
      instance_view = InstanceView.last
      assert instance_view.partial
    end
    
    should 'create instance view for deeply nested files' do
      @seeder.create_instance_view_for_path('public/a/b_b/c_c/d_d/e_e/f/g/index.html.haml', 'content')
      instance_view = InstanceView.last
      assert_equal 'public/a/b_b/c_c/d_d/e_e/f/g/index',  instance_view.path
    end

    should 'create instance view with correct locale if specified' do
      I18n.stubs(:available_locales).returns(['en', 'pl'])
      InstanceView.expects(:create).with(body: 'content', path: 'public/index', locale: 'pl', format: 'html', handler: 'haml', partial: false)
      @seeder.create_instance_view_for_path('public/index.pl.html.haml', 'content')
    end

  end

end
