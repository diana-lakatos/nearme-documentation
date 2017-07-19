# frozen_string_literal: true
require 'jira-ruby'
require 'chronic'

module JiraWrapper
  class Releaser
    JIRA_FORMAT = /^\A[a-zA-Z]{2,4}[\s-]\d{1,5}/
    attr_reader :projects

    def initialize
      @client = JiraWrapper::Client.new.client
    end

    def release(major: true)
      @version = git_helper.next_tag(major: major)
      @description = major ? 'Regular Release' : 'Hotfix'

      print_commit_info
      print_pre_release_message
      assign_fix_version
    end

    def prepare
      projects.each {|project| project.prepare }
    end

    def release_version!(version)
      projects.each {|project| project.release_version!(version) }
      puts 'Versions released'
    end

    private
    def commits
      @commits ||= git_helper.commits_between_revisions(
        (ENV['BASED_TAG'].presence || git_helper.last_tag),
        (ENV['HEAD_TAG'].presence || 'HEAD')
      )
    end

    def projects
      @projects ||= find_projects
    end

    def git_helper
      @git_helper ||= GitHelper.new
    end

    def print_commit_info
      puts "\nAll commits: "
      commits.each {|c| puts c }
      puts "\n"
    end

    def jira_commits
      @jira_commits ||= commits.select { |c| c =~ JIRA_FORMAT }
    end

    def issues_keys
      @issues_keys ||= jira_commits.map { |jira_commit| to_jira_number([jira_commit]).first.tr(' ', '-') }.uniq
    end

    def projects_keys_with_grouped_issues_keys
      @projects_keys_with_grouped_issues_keys ||= issues_keys.group_by {|i| i.split('-')[0] }
    end

    def to_jira_number(array)
      array.map { |a| a.scan(JIRA_FORMAT).first }
    end

    def find_projects
      projects = []
      projects_keys_with_grouped_issues_keys.each do |project_key, issues_keys|
        projects << JiraWrapper::Project.new(@client, project_key, issues_keys)
      end
      projects
    end

    def print_pre_release_message
      @printer = JiraWrapper::CardPrinter.new

      @total_issues_count = 0
      projects.each do |project|
        puts "\n#{project.issues_count} Issues for project #{project.name}\n"
        @total_issues_count += project.issues_count
        project.issues.each do |issue|
          begin
            @printer.print(issue.to_hash)
          rescue => e
            puts "Error for card: #{issue.key}. #{e} - can't check if fixVersion already assigned"
          end
        end
      end
      puts "\nTotal number of jira issues to process: #{@total_issues_count}"
      puts "\nFix version #{@version} will be assigned to all projects and issues.\n"
      puts 'Do you want to proceed? [y]'

      user_input = STDIN.gets.strip
      if user_input.strip != 'y'
        puts 'ABORT'
        exit
      end
      puts 'Ok, time to update JIRA'
    end

    def issues_count
      @count || issues.count
    end

    def assign_fix_version
      puts "Updating all issues with fix version #{@version}"
      projects.each do |project|
        puts "Processing project: #{project.name}"
        project.assign_version(@version, @description)
      end
    end
  end
end
