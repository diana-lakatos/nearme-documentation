class CkeditorToolbarCreator
  def initialize(params)
    @instance = PlatformContext.current.instance
    @params = params
  end

  def toolbar
    base_toolbar = [
      ['Cut','Copy','Paste',], ['Undo','Redo'],
      ['Bold','Italic','Underline','Strike'], 
      ['NumberedList','BulletedList','-','Outdent','Indent','Blockquote'],
      ['Link','Unlink'],
      ['Image']
    ];

    toolbar = base_toolbar

    if @params[:controller] == "instance_admin/manage_blog/posts"
      if @instance.blog_instance.allow_video_embeds?
        toolbar << ['Iframe']
      end
    end

    toolbar
  end
 end

