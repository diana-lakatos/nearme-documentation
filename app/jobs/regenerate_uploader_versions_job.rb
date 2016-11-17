class RegenerateUploaderVersionsJob < Job
  include Job::LongRunning

  def after_initialize(uploader)
    @uploader = uploader
  end

  def perform
    case @uploader
    when 'PhotoUploader'
      Photo.find_each do |photo|
        with_exception_handling do
          photo.image.delayed_processing = true
          photo.image.recreate_versions!
          photo.skip_activity_feed_event = true
          photo.image_versions_generated_at = Time.current
          photo.save(validate: false)
          photo.listing_populate_photos_metadata! if photo.listing.present?
        end
      end

    when 'AvatarUploader'
      User.find_each do |user|
        with_exception_handling do
          user.avatar.delayed_processing = true
          user.avatar.recreate_versions!
          user.avatar_versions_generated_at = Time.current
          user.save(validate: false)
        end
      end
    when 'AuthorAvatarUploader'
      UserBlogPost.find_each do |user_blog_post|
        with_exception_handling do
          user_blog_post.author_avatar_img.recreate_versions!
          user_blog_post.author_avatar_img_versions_generated_at = Time.current
          user_blog_post.save(validate: false)
        end
      end
    when 'CkeditorPictureUploader'
      Ckeditor::Picture.find_each do |picture|
        with_exception_handling do
          picture.data.recreate_versions!
          picture.data_versions_generated_at = Time.current
          picture.save(validate: false)
        end
      end
    when 'GroupCoverImageUploader'
      Group.find_each do |group|
        with_exception_handling do
          group.cover_image.recreate_versions!
          group.cover_image_versions_generated_at = Time.current
          group.save(validate: false)
        end
      end
    when 'LinkImageUploader'
      Link.find_each do |link|
        with_exception_handling do
          link.image.recreate_versions!
          link.skip_activity_feed_event = true
          link.image_versions_generated_at = Time.current
          link.save(validate: false)
        end
      end
    when 'SimpleAvatarUploader'
      BlogPost.find_each do |blog_post|
        with_exception_handling do
          blog_post.author_avatar.recreate_versions!
          blog_post.author_avatar_versions_generated_at = Time.current
          blog_post.save(validate: false)
        end
      end
    when 'TopicCoverImageUploader'
      Topic.find_each do |topic|
        with_exception_handling do
          topic.cover_image.recreate_versions!
          topic.cover_image_versions_generated_at = Time.current
          topic.save(validate: false)
        end
      end
    when 'TopicImageUploader'
      Topic.find_each do |topic|
        with_exception_handling do
          topic.image.recreate_versions!
          topic.image_versions_generated_at = Time.current
          topic.save(validate: false)
        end
      end
    when 'HeroImageUploader'
      UserBlogPost.where.not(hero_image: nil).find_each do |user_blog_post|
        with_exception_handling do
          user_blog_post.hero_image.recreate_versions!
          user_blog_post.hero_image_versions_generated_at = Time.current
          user_blog_post.save(validate: false)
        end
      end
    end

    update_default_images(@uploader)

    PlatformContext.current.instance.scheduled_uploaders_regenerations.where(photo_uploader: @uploader).destroy_all
  end

  def with_exception_handling
    yield
  rescue => e
    raise e if Rails.env.test?
    Rails.logger.debug "Encountered an issue: #{e} #{caller[0]}" if Rails.env.development?
  end

  def update_default_images(uploader_name)
    DefaultImage.where(photo_uploader: uploader_name).find_each do |default_image|
      with_exception_handling do
        default_image.photo_uploader_image.recreate_versions!
        default_image.photo_uploader_image_versions_generated_at = Time.current
        default_image.save(validate: false)
      end
    end
  end

  def max_attempts
    1
  end
end
