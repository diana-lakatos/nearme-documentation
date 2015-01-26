require 'pathname'

namespace :instance_views do

  desc "Update Instance View"
  task :populate => [:environment] do

    Dir.glob(Rails.root.join('tmp_views', '**', '*')).select{|f| File.file?(f)}.map{|f| Pathname.new(f)}.each do |pathname|
      iv_attrs               = {}
      iv_attrs[:instance_id] = pathname.relative_path_from(Rails.root.join('tmp_views')).to_s.to_i
      iv_attrs[:body]        = pathname.read
      iv_attrs[:path]        = pathname.relative_path_from(Rails.root.join('tmp_views', iv_attrs[:instance_id].to_s)).dirname.to_s + '/' + pathname.basename.to_s.gsub(/^_/ , '').split('.').first
      iv_attrs[:locale]      = 'en'
      iv_attrs[:format]      = 'html'
      iv_attrs[:handler]     = pathname.extname.gsub(/^./, '')
      iv_attrs[:partial]     = pathname.basename.to_s.start_with? '_'

      instance_view = InstanceView.find_or_create_by(instance_id: iv_attrs[:instance_id], path: iv_attrs[:path])
      new_record = instance_view.new_record?
      if instance_view.update_attributes(iv_attrs)
        puts "#{new_record ? 'CREATED' : 'UPDATED'} instance_view id: #{instance_view.id} instance_id: #{instance_view.instance_id} path: #{instance_view.path}"
      else
        puts "ERROR: could not create instance_view id: #{instance_view.id} instance_id: #{instance_view.instance_id} path: #{instance_view.path}"
        puts "  #{instance_view.errors.full_messages.to_sentence}"
      end
    end
  end
end
