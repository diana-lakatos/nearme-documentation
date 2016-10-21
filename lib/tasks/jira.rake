require 'chronic'
require_relative '../jira_wrapper.rb'

namespace :jira do
  desc 'Populate new foreign keys and flags'
  task release_sprint: :environment do
    description = 'Sprint 40 and bit of 41'
    epics_wip = ['"The Volte"', '"LitVault"'].join(', ')
    jira_wrapper = JiraWrapper.new
    jql = "Sprint IN (61, 62) and status IN (\"Ready for Production\", \"IN QA\", \"Tests Failed\") AND (\"Epic Link\" NOT IN (#{epics_wip}) OR \"Epic Link\" = NULL AND fixVersion IS NULL)"
    puts jql
    issues = jira_wrapper.issues(jql)

    jira_wrapper.ensure_version_present!(
      name: jira_wrapper.next_tag(1),
      description: description,
      user_released_data: 'today',
      user_start_date: 'last week monday',
      start_date: 'last week monday'
    )
    JiraReleaser.new(issues).release(jira_wrapper.next_tag(1))
  end

  task :release_hotfix do
    @jira_helper = JiraHelper.new
    @jira_wrapper = JiraWrapper.new

    @commits_for_hotfix = []

    (@jira_helper.jira_commits + @jira_helper.non_jira_commits).each do |commit|
      puts commit
      @commits_for_hotfix << commit
    end

    issues = []
    @jira_helper.jira_commits.each do |commit_for_hotfix|
      issues << @jira_wrapper.find_issue(@jira_helper.to_jira_number([commit_for_hotfix]).first)
    end

    @jira_wrapper.ensure_version_present!(
      name: @jira_wrapper.next_tag(2),
      description: 'Hotfix',
      user_released_data: 'today',
      user_start_date: 'today',
      start_date: 'today'
    )
    JiraReleaser.new(issues).release(@jira_wrapper.next_tag(2))
  end
end

class JiraHelper
  JIRA_FORMAT = /^\A[a-zA-Z]{2,4}[\s-]\d{2,5}/
  extend Forwardable
  attr_accessor :commit_parser, :client

  class GitCommitParser
    attr_reader :base_revision, :new_revision

    def initialize(base_revision, new_revision)
      @base_revision = base_revision
      @new_revision = new_revision
    end

    def commits_between_revisions
      @commits ||= `git log #{base_revision}..#{new_revision} --no-merges`.split("\n").select { |c| c.include?('    ') }.map(&:strip)
    end

    def jira_commits
      @jira_commits ||= commits_between_revisions.select { |c| c =~ JiraHelper::JIRA_FORMAT }
    end

    def non_jira_commits
      commits_between_revisions - jira_commits
    end

    def to_s
      puts "Commits between #{base_revision} .. #{new_revision}"
    end
  end

  def initialize(git_commit_parser = nil)
    @commit_parser = git_commit_parser || JiraHelper::GitCommitParser.new((ENV['BASED_TAG'].presence || `git describe`.split('-')[0]),  (ENV['HEAD_TAG'].presence || 'HEAD'))
  end

  def commits_between_revisions
    @commit_parser.commits_between_revisions
  end

  def jira_commits
    @commit_parser.jira_commits
  end

  def non_jira_commits
    @commit_parser.non_jira_commits
  end

  def to_jira_number(array)
    array.map { |a| a.scan(JiraHelper::JIRA_FORMAT).first }
  end

  def full_names(numbers, array)
    numbers.map { |n| array.find { |a| a.include?(n) } }
  end

  def jira_client
    @jira_wrapper = JiraWrapper.new
  end
end

class JiraReleaser

  def initialize(issues)
    @issues = issues
  end

  def release(fixVersion)
    @jira_wrapper = JiraWrapper.new
    @jira_helper = JiraHelper.new


    @printer = JiraCardPrinter.new
    total_count = @issues.count
    @issues.each do |issue|
      begin
        issue_hash = @jira_wrapper.issue_hash(issue)
        @printer.print(issue_hash)
      rescue => e
        puts "Error for card: #{number}. #{e} - can't check if fixVersion already assigned"
      end
    end
    puts "\nTotal number of issues: #{total_count}\n"

    puts 'Do you want to proceed? [y]'
    user_input = STDIN.gets.strip
    if user_input.strip != 'y'
      puts 'ABORT'
      exit
    end
    puts 'Ok, time to update JIRA'

    i = 0
    @issues.each do |issue|
      i += 1
      @jira_wrapper.assign_version(issue, fixVersion)
      puts "Version assigned to #{i}/#{total_count}" if (i % 10).zero?
    end
  end
end

class JiraCardPrinter
  def initialize
  end

  def print(issue_hash)
    puts %(
  Number: #{issue_hash[:name]}
  \tfixVersions: #{issue_hash[:fixVersions]}
  \tstatus: #{issue_hash[:status]}
  \tassignee: #{issue_hash[:assignee]}
  \tepic: #{issue_hash[:epic]}
  \tsprint: #{issue_hash[:sprint]}
        )
  end
end
