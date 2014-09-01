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
  end
end
