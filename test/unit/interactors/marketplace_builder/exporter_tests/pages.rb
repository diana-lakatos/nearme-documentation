module MarketplaceBuilder
  module ExporterTests
    class ShouldExportPages < Basic
      def initialize(instance)
        @instance = instance
      end

      def seed!
        authorization_policy = AuthorizationPolicy.create!(instance_id: @instance.id,
                                                           name: 'page_policy',
                                                           content: '{% if current_user.first_name == \'Maciek\'%}true{% endif %}')
        page = Page.create!(instance_id: @instance.id, slug: 'about-us', content: 'Hello from page', path: 'about-us', theme: @instance.theme)
        page.update_attribute(:authorization_policy_ids, [authorization_policy.id])
      end

      def execute!
        liquid_content = read_exported_file('pages/about-us.liquid', :liquid)
        assert_equal liquid_content.body, 'Hello from page'
        assert_equal liquid_content.slug, 'about-us'
        assert_equal liquid_content.authorization_policies, %w(page_policy)
      end
    end
  end
end
