require "#{Rails.root}/lib/columns_observer.rb"
ActiveRecord::Base.send :include, ColumnsObserver
