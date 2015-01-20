require 'pathname'

namespace :instance_views do

  desc "Update Instance View"
  task :populate => [:environment] do

    Dir.glob(Rails.root.join('tmp_views', '**', '*')).select{|f| File.file?(f)}.map{|f| Pathname.new(f)}.each do |pathname|
      iv_attrs               = {}
      iv_attrs[:instance_id] = pathname.relative_path_from(Rails.root.join('tmp_views')).to_s.to_i
      iv_attrs[:body]        = pathname.read
      iv_attrs[:path]        = pathname.relative_path_from(Rails.root.join('tmp_views', iv_attrs[:instance_id].to_s)).to_s.split('.').first
      iv_attrs[:locale]      = 'en'
      iv_attrs[:format]      = 'html'
      iv_attrs[:handler]     = 'haml'
      iv_attrs[:partial]     = pathname.basename.to_s.start_with? '_'

      # Remove the leading underscore from the filename if the file is a partial
      if iv_attrs[:partial]
        iv_attrs[:path] = iv_attrs[:path].split('/')[0..-2].join('/') + '/' + iv_attrs[:path].split('/').last[1..-1]
      end

      # If the view already exists for that marketplace, delete it
      iv = InstanceView.where(instance_id: iv_attrs[:instance_id], path: iv_attrs[:path]).first
      if iv
        puts 'deleted existing instance view instance_id: #{instance_id} path: #{path}'
        iv.delete
      end

      if InstanceView.create(iv_attrs)
        puts 'created instance view instance_id: #{instance_id} path: #{path}'
      else
        puts 'could not create instance view instance_id: #{instance_id} path: #{path}'
      end
    end
  end
end
