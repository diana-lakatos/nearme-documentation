class RegenerateUploaderVersionsJob < Job

  include Job::LongRunning

  def after_initialize(uploader)
    @uploader = uploader
  end

  def perform
    case @uploader
    when 'PhotoUploader'
      Photo.find_each do |photo|
        photo.image.delayed_processing = true
        photo.image.recreate_versions! rescue nil
        photo.skip_activity_feed_event = true
        photo.image_versions_generated_at = Time.now.utc
        photo.save(validate: false) rescue nil

        if photo.listing.present?
          photo.listing_populate_photos_metadata! rescue nil
        end
      end

      Spree::Image.find_each do |image|
        image.image.delayed_processing = true
        image.image.recreate_versions! rescue nil
        image.image_versions_generated_at = Time.now.utc
        image.save(validate: false) rescue nil
      end
    when 'AvatarUploader'
      User.find_each do |user|
        user.avatar.delayed_processing = true
        user.avatar.recreate_versions! rescue nil
        user.avatar_versions_generated_at = Time.now.utc
        user.save(validate: false) rescue nil
      end
    when 'AuthorAvatarUploader'
      UserBlogPost.find_each do |user_blog_post|
        user_blog_post.author_avatar_img.recreate_versions! rescue nil
        user_blog_post.author_avatar_img_versions_generated_at = Time.now.utc
        user_blog_post.save(validate: false) rescue nil
      end
    when 'CkeditorPictureUploader'
      Ckeditor::Picture.find_each do |picture|
        picture.data.recreate_versions! rescue nil
        picture.data_versions_generated_at = Time.now.utc
        picture.save(validate: false) rescue nil
      end
    when 'GroupCoverImageUploader'
      Group.find_each do |group|
        group.cover_image.recreate_versions! rescue nil
        group.cover_image_versions_generated_at = Time.now.utc
        group.save(validate: false) rescue nil
      end
    when 'LinkImageUploader'
      Link.find_each do |link|
        link.image.recreate_versions! rescue nil
        link.skip_activity_feed_event = true
        link.image_versions_generated_at = Time.now.utc
        link.save(validate: false) rescue nil
      end
    when 'SimpleAvatarUploader'
      BlogPost.find_each do |blog_post|
        blog_post.author_avatar.recreate_versions! rescue nil
        blog_post.author_avatar_versions_generated_at = Time.now.utc
        blog_post.save(validate: false) rescue nil
      end
    when 'TopicCoverImageUploader'
      Topic.find_each do |topic|
        topic.cover_image.recreate_versions! rescue nil
        topic.cover_image_versions_generated_at = Time.now.utc
        topic.save(validate: false) rescue nil
      end
    when 'TopicImageUploader'
      Topic.find_each do |topic|
        topic.image.recreate_versions! rescue nil
        topic.image_versions_generated_at = Time.now.utc
        topic.save(validate: false) rescue nil
      end
    end
  end

  def after(job)
    PlatformContext.current.instance.scheduled_uploaders_regenerations.where(photo_uploader: @uploader).destroy_all

    super
  end

  def max_attempts; 1; end

end
