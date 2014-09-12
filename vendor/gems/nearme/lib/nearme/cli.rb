require 'thor'
require 'nearme'

module NearMe
  class CLI < Thor
    include Thor::Actions

    desc "deploy", "deploy NearMe application to AWS OpsWorks"
    long_desc <<DESC
    deploy NearMe application to AWS OpsWorks

    for example:

    nearme deploy -r my-little-staging -e nm-staging --comment "deploy pls"

    will deploy branch my-little-staging to nm-staging AWS OpsWorks stack
DESC
    method_option "branch", required: true, type: :string,
      aliases: :r, desc: "git branch to deploy"
    method_option "stack", required: true, type: :string,
      aliases: :e, desc: "AWS OpsWorks stack name"
    method_option "environment", required: false, type: :string,
      aliases: :env, desc: "Rails environtment"
    method_option "migrate", required: false, type: :boolean,
      default: true, desc: "Trigger migration"
    method_option "assets", required: false, type: :boolean,
      default: true, desc: "Sync assets"
    method_option "bucket", required: false, type: :string,
      aliases: :b, desc: "S3 bucket name"
    method_option "comment", required: false, type: :string,
      desc: "deploy comment"
    method_option "watch", required: false, type: :boolean,
      default: true, desc: "wait until deploy is finished and print report"
    def deploy
      if options[:assets]
        puts "Assets sync..."
        result = NearMe::SyncAssets.new(options).start!
        puts "Assets sync done."
      end
      puts "Deploying..."
      deploy = NearMe::Deploy.new(options)
      result = deploy.start!
      deployment_id = result.data[:deployment_id]
      puts "Deployed started with ID: #{deployment_id}"
      if options[:watch]
        puts "Waiting unless deploy is done."
        deploy.watch!(deployment_id)
      end
    end

    desc "sync_assets", "synchronize assets with S3 bucket"
    long_desc <<DESC
    sync NearMe application assets to S3
    for example:

    nearme sync_assets -r my-branch -b near-me-assets-staging-2
    nearme sync_assets -r my-branch -e nm-staging-2

    will compile assets and sync it to S3 bucket
DESC
    method_option "branch", required: true, type: :string,
      aliases: :r, desc: "git branch to synch"
    method_option "bucket", required: false, type: :string,
      aliases: :b, desc: "S3 bucket name"
    method_option "stack", required: true, type: :string,
      aliases: :e, desc: "AWS OpsWorks stack name"
    method_option "environment", required: false, type: :string,
      aliases: :env, desc: "Rails environtment"
    def sync_assets
      puts "Assets sync..."
      result = NearMe::SyncAssets.new(options).start!
      puts "Assets sync done."
    end
  end
end
