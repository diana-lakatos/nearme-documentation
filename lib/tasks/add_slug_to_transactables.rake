desc "Add slug to transactables"
task add_slug_to_transactables: :environment do
  Instance.find_each do |i|
    i.set_context!

    # Friendly ID is wired up before_validation, so if a validation fails
    # such as photo validation, we wouldn't have a slug set.
    # Workaround: since #set_slug is private, we use #send and set it manually.
    #

    Transactable.find_each do |t|
      t.slug = t.send(:set_slug)
      t.save(validate: false)
    end

    TransactableType.find_each do |tt|
      tt.slug = tt.send(:set_slug)
      tt.save(validate: false)
    end

    Page.find_each do |p|
      p.slug = p.send(:set_slug)
      p.save(validate: false)
    end
  end

  SitemapGeneratorJob.perform
end