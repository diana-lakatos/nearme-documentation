module NearMe
  class SyncAssets
    attr_accessor :branch, :bucket, :stack, :prefix
    def initialize(options = {})
      @branch = options[:branch]
      @bucket = options[:bucket] || stack_mapping[options[:stack]] || 'near-me-assets-staging'
      @prefix = options[:prefix] || prefix_mapping[options[:stack]]
      if @bucket.to_s.empty?
        puts "Invalid bucket. Can't find mapping. Provide it manually."
        exit 5
      end
    end

    def stack_mapping
      {
        'nm-production' => 'near-me-assets',
      }
    end

    def prefix_mapping
      {
        'nm-production' => '/assets',
        'nm-staging' => '/staging/assets',
        'nm-staging-2' => '/staging/assets-2',
      }
    end

    def start!
      check_branch
      check_clean_tree
      puts "Compiling..."
      if not Kernel.system('bundle exec rake assets:precompile')
        puts "precompile failed :("
        exit 6
      end
      puts "Sync..."
      if not Kernel.system("ASSETS_PREFIX=#{@prefix} FOG_DIR=#{@bucket} bundle exec rake assets:sync")
        puts "sync failed :("
        exit 7
      end
    end

    def check_clean_tree
      status = `git status -s`.strip
      if not status.empty?
        puts "Warning: tree is not clean."
      end
    end

    def current_branch
      @current_branch ||= `git rev-parse --abbrev-ref HEAD`.strip
    end

    def check_branch
      if @branch != current_branch
        puts "Invalid branch. Checkout synchronized branch and try again."
        exit 3
      end
    end
  end
end
