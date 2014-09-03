require 'thor'
require 'nearme'

module NearMe
  class CLI < Thor
    include Thor::Actions

    desc "deploy", "deploy NearMe application to AWS OpsWorks"
    long_desc <<DESC
    deploy NearMe application to AWS OpsWorks

    for example:

    nearme deploy -r my-little-staging -e nm-staging --migrate --comment "deploy pls"

    will deploy branch my-little-staging to nm-staging AWS OpsWorks stack
DESC
    method_option "branch", required: true, type: :string,
      aliases: :r, desc: "git branch to deploy"
    method_option "stack", required: true, type: :string,
      aliases: :e, desc: "AWS OpsWorks stack name"
    method_option "migrate", required: false, type: :boolean,
      default: true, desc: "Trigger migration"
    method_option "comment", required: false, type: :string,
      desc: "deploy comment"
    def deploy
      puts "Deploying..."
      result = NearMe::Deploy.new(options).start!
      puts "RESULT: #{result.data}"
    end

    desc "sync_assets", "synchronize assets with S3 bucket"
    long_desc <<DESC
    sync NearMe application assets to S3
    for example:

    nearme sync_assets -r my-branch -b near-me-assets-staging-2

    will compile assets and sync it to S3 bucket
DESC
    method_option "branch", required: true, type: :string,
      aliases: :r, desc: "git branch to synch"
    method_option "bucket", required: false, type: :string,
      aliases: :b, desc: "S3 bucket name"
    def sync_assets
      puts "Assets sync..."
      result = NearMe::SyncAssets.new(options).start!
      puts "Assets sync done."
    end
  end
end
