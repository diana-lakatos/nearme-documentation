class CkeditorToolbarCreator
  def initialize(params)
    @instance = PlatformContext.current.instance
    @params = params
  end

  def toolbar
    base_toolbar = [
      %w(Cut Copy Paste), %w(Undo Redo),
      %w(Bold Italic Underline Strike),
      ['NumberedList', 'BulletedList', '-', 'Outdent', 'Indent', 'Blockquote'],
      %w(Link Unlink),
      ['Image']
    ]

    toolbar = base_toolbar

    if @params[:controller] == 'instance_admin/manage_blog/posts'
      toolbar << ['Iframe'] if @instance.blog_instance.allow_video_embeds?
    end

    toolbar
  end
 end
