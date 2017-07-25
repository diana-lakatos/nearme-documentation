# frozen_string_literal: true

require 'thor'
require 'nearme'
require 'slack-notifier'
require_relative '../../../../../lib/raygun_deploy_notifier.rb'
require_relative '../../../../../lib/git_helper.rb'
require_relative '../../../../../lib/jira_wrapper/releaser.rb'
require_relative '../../../../../lib/jira_wrapper/client.rb'
require_relative '../../../../../lib/jira_wrapper/project.rb'
require_relative '../../../../../lib/jira_wrapper/issue.rb'


module NearMe
  class CLI < Thor
    include Thor::Actions

    desc 'info', 'currect opsworks stack info'
    long_desc <<DESC
    get info about the current opsworks stacks
    for example:

    nearme info

    will show you the current stacks and some assorted info
DESC

    def info
      puts 'Retrieving opsworks stack info...'
      NearMe::Info.new(options).status
    end

    desc 'deploy', 'deploy NearMe application to AWS OpsWorks'
    long_desc <<DESC
    deploy NearMe application to AWS OpsWorks

    for example:

    nearme deploy -r my-little-staging -e nm-staging --comment "deploy pls" -a nearme

    will deploy branch my-little-staging to nm-staging AWS OpsWorks stack
DESC
    method_option 'branch', required: true, type: :string,
                            aliases: :r, desc: 'git branch to deploy'
    method_option 'stack', required: true, type: :string,
                           aliases: :e, desc: 'AWS OpsWorks stack name'
    method_option 'environment', required: false, type: :string,
                                 aliases: :v, desc: 'Rails environtment'
    method_option 'app_name', required: false, type: :string,
                              aliases: :a, desc: 'Application name to be deployed'
    method_option 'migrate', required: false, type: :boolean,
                             default: true, desc: 'Trigger migration'
    method_option 'comment', required: false, type: :string,
                             desc: 'deploy comment'
    method_option 'watch', required: false, type: :boolean,
                           default: true, desc: 'wait until deploy is finished and print report'

    def deploy
      deployment_check

      puts 'Deploying...'
      deploy = NearMe::Deploy.new(options)
      result = deploy.start!
      deployment_id = result.data[:deployment_id]
      puts "Deploy started with ID: #{deployment_id}"

      notifier.ping(":airplane_departure: Deploy started by #{ENV['AWS_USER']}: #{options[:branch]} -> #{options[:stack]} (id: #{deployment_id})", icon_emoji: ':passenger_ship:')
      if @production_deploy.present?
        production_notifier = Slack::Notifier.new('https://hooks.slack.com/services/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')
        releaser = JiraWrapper::Releaser.new
        releaser.release_version!(@production_deploy)
        production_release_notes = releaser.release_notes(@production_deploy)
        production_notifier.ping("Production release started #{options[:branch]} -> #{options[:stack]}. You can <a href='#{production_release_notes}'>Check Release Notes</a>. Details in #eng-deploys", icon_emoji: ':see_no_evil:')
        RaygunDeployNotifier.send!
      end
      if options[:watch]
        puts 'Waiting until deploy is done.'
        result_hash = deploy.watch!(deployment_id)
        message = begin
                    if result_hash.any? { |arr| arr[:status] != 'successful' }
                      m = ":sos: WHOOOPSE!!!\n"
                      m += result_hash.map do |arr|
                        icon = arr[:status] == 'successful' ? ':white_check_mark:' : ':x:'
                        status = "#{arr[:name]}: #{arr[:status]}"
                        log_url = arr[:status] == 'successful' ? nil : "[check log](#{arr[:log_url]})"
                        [icon, status, log_url].compact.join(' ')
                      end.join("\n")
                    else
                      ':white_check_mark: All good.'
                    end
                  end
        notifier.ping(":airplane_arriving: Deploy finished: #{ENV['AWS_USER']} #{options[:branch]} -> #{options[:stack]} (id: #{deployment_id})\n#{message}", icon_emoji: ':passenger_ship:')
      end
    end

    desc 'capture', 'capture db dump to S3'
    long_desc <<DESC
    dump stack database to S3
    for example:

    nearme capture -e nm-production

    will dump the nm-production stack db and store it in S3
DESC
    method_option 'stack', required: true, type: :string,
                           aliases: :e, default: 'nm-production', desc: 'AWS OpsWorks stack name'
    method_option 'host', required: false, type: :string,
                          aliases: :h, desc: 'AWS OpsWorks host name'
    method_option 'environment', required: false, type: :string,
                                 aliases: :v, desc: 'Rails environtment'

    def capture
      puts 'Capturing db to S3...'
      NearMe::Backup.new(options).capture!
      puts 'Capture done.'
    end

    desc 'restore', 'restore db from S3'
    long_desc <<DESC
    restore stack database from S3
    for example:

    nearme restore -e nm-qa-1

    will restore the qa-1 stack db from the captured dump in S3
DESC
    method_option 'stack', required: true, type: :string,
                           aliases: :e, desc: 'AWS OpsWorks stack name'
    method_option 'host', required: false, type: :string,
                          aliases: :h, desc: 'AWS OpsWorks host name'
    method_option 'environment', required: false, type: :string,
                                 aliases: :v, desc: 'Rails environtment'

    def restore
      deployment_check

      puts 'Restoring db from S3...'
      NearMe::Backup.new(options).restore!
      puts 'Restore done.'
    end


    desc 'update_ssh_config', 'update ~/.ssh/config'
    def update_ssh_config
      puts 'Updating ssh config file'
      NearMe::SshConfig.new.update
      puts 'done.'
    end

    no_commands do
      def deployment_check
        stack = options[:stack]
        environment = options[:environment].to_s

        return true unless stack.include?('production') || stack == 'nm-oregon' || stack == 'nm-sydney'

        if !environment.empty? && environment != 'production'
          puts 'ERROR: You cannot use this environment for production stack'
          exit 1
        end

        banner = <<'BANNER'
                           _            _   _
                          | |          | | (_)
       _ __  _ __ ___   __| |_   _  ___| |_ _  ___  _ __
      | '_ \| '__/ _ \ / _` | | | |/ __| __| |/ _ \| '_ \
      | |_) | | | (_) | (_| | |_| | (__| |_| | (_) | | | |
      | .__/|_|  \___/ \__,_|\__,_|\___|\__|_|\___/|_| |_|
      | |
      |_|

BANNER

        info = ''
        info += "Branch: #{options[:branch]}\n" if options.key?('branch')
        info += "Application: #{options[:app_name]}\n" if options.key?('app_name')
        info += "Environment: #{options[:environment]}\n" if options.key?('environment')
        info += "Migrate: #{options[:migrate]}\n" if options.key?('migrate')
        info += "Watch: #{options[:watch]}\n" if options.key?('watch')
        info += "Host: #{options[:host]}\n" if options.key?('host')
        info += "Comment: #{options[:comment]}\n" if options.key?('comment')

        banner += info

        banner.each_line do |line|
          line.each_char do |ch|
            print ch
            sleep 0.002
          end
        end

        answer = ask "\nAre you sure you want to perform this action on production? Type 'production' if so. BTW: Have you created git tag?"

        if answer != 'production'
          puts 'Nope!'
          exit 1
        end

        @production_deploy = `git describe`.split('-')[0].strip
      end

      def notifier
        @notifier ||= Slack::Notifier.new('https://hooks.slack.com/services/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')
      end
    end
  end
end
