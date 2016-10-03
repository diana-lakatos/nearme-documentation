namespace :jira do
  desc "Populate new foreign keys and flags"
  task :release_sprint, [:sprint_number] => [:environment] do |t, args|
    @jira_wrapper = JiraWrapper.new
    @jira_helper = JiraHelper.new
    puts @jira_helper.commit_parser.to_s

    issues = @jira_wrapper.issues(args[:sprint_number])

    tickets_assigned_to_sprint = issues.map { |i| [i.key, i.summary].join(' ') }
    puts "All tickets assigned to sprint #{args[:sprint_number]} - total count #{tickets_assigned_to_sprint.count}"
    puts "*******************"
    puts ""
    puts tickets_assigned_to_sprint.join("\n")

    issues_not_included_in_sprint = @jira_helper.to_jira_number(@jira_helper.jira_commits) - @jira_helper.to_jira_number(tickets_assigned_to_sprint)
    puts ""
    puts "Cards assigned to WRONG sprint"
    puts "*******************"
    @cards_to_be_added_to_sprint = []

    @printer = JiraCardPrinter.new
    issues_not_included_in_sprint.each do |number|
      begin
        issue_hash = @jira_wrapper.issue_hash(number)
        @printer.print(@jira_helper.full_names([number], @jira_helper.jira_commits)[0], issue_hash)
        @cards_to_be_added_to_sprint << number
        puts "\tadding to sprint"
      rescue => e
        puts "Error for card: #{number}. #{e} - can't check if fixVersion already assigned"
      end
    end

    issues_without_code = @jira_helper.to_jira_number(tickets_assigned_to_sprint) - @jira_helper.to_jira_number(@jira_helper.jira_commits)
    puts ""
    puts "Cards that have not relevant code"
    puts "*******************"
    @remember_decision_for_epic = {}
    issues_without_code.each do |number|
      issue_hash = @jira_wrapper.issue_hash(number)
      @printer.print(@jira_helper.full_names([number], tickets_assigned_to_sprint)[0], issue_hash)

      puts '[y]/[n]/[o]'
      if issue_hash[:epic].present?
        puts "[Y]/[N] for all cards in this epic"
      end

      if @remember_decision_for_epic[issue_hash[:epic]]
        case @remember_decision_for_epic[issue_hash[:epic]]
        when "y"
          @cards_to_be_added_to_sprint << number
          puts "\t\tautomatically adding "
        when "n"
          puts "\t\tautomatically skipping"
        end
      else
        if ["IN QA", "Ready for Test Server", "Ready for Production"].include?(issue_hash[:status])
          if issue_hash[:fixVersions].present?
            puts "\tSkipping - fixVersion already assigned"
            next
          end
          user_input = STDIN.gets.strip
          while(!%w(Y y N n).include?(user_input)) do
            if user_input == 'o'
              `launchy https://near-me.atlassian.net/browse/#{number}`
            else
              puts "\tinvalid input"
            end
            user_input = STDIN.gets.strip
          end
          case user_input
          when "y"
            @cards_to_be_added_to_sprint << number
            puts "\tadding to sprint"
          when "Y"
            @cards_to_be_added_to_sprint << number
            puts "\t\tall cards from epic #{issue_hash[:epic]} will be added"
            @remember_decision_for_epic[issue_hash[:epic]] = "y"
          when "N"
            puts "\t\tall cards from epic #{issue_hash[:epic]} will be skipped"
            @remember_decision_for_epic[issue_hash[:epic]] = "n"
          when "n"
            puts "\t\tskipping"
          end
        else
          puts "Not in QA and not Ready for Production -> will be moved automatically"
        end
      end
    end

    cards_in_commits = @jira_helper.to_jira_number(@jira_helper.jira_commits) & @jira_helper.to_jira_number(tickets_assigned_to_sprint)

    puts "Ok, time to update JIRA"

    next_tag = @jira_helper.next_tag(1)
    total_count = (@cards_to_be_added_to_sprint + cards_in_commits).count
    i = 0
    (@cards_to_be_added_to_sprint + cards_in_commits).each do |card_in_sprint|
      i += 1
      @jira_wrapper.update_issue(card_in_sprint, tag: [{ name: next_tag }], sprint_number: args[:sprint_number].to_i)
      if i % 10 == 0
        puts "Updated #{i}/#{total_count}"
      end
    end

    puts ""
    puts "FINAL LIST OF CARDS RELEASED: "
    puts "*******************"
    puts ""
    puts @jira_helper.full_names(cards_in_commits, @jira_helper.jira_commits).join("\n")
    puts @jira_helper.full_names(@cards_to_be_added_to_sprint, @jira_helper.jira_commits + tickets_assigned_to_sprint).join("\n")
    puts @jira_helper.non_jira_commits.compact.join("\n")
  end

  task :release_hotfix do
    @jira_helper = JiraHelper.new
    @jira_wrapper= JiraWrapper.new

    @commits_for_hotfix = []

    (@jira_helper.jira_commits + @jira_helper.non_jira_commits).each do |commit|
      puts commit
      puts "Include this commit in the hotfix? [y]/[n]"

      user_input = STDIN.gets.strip
      while(!%w(y n).include?(user_input)) do
        puts "\tinvalid input"
        user_input = STDIN.gets.strip
      end
      case user_input
      when "y"
        @commits_for_hotfix << commit
        puts "\tadding to hotfix"
      when "n"
        puts "\tskipping"
      end
    end

    next_tag = @jira_helper.next_tag(2)
    @commits_for_hotfix.each do |commit_for_hotfix|
      if commit_for_hotfix.match(/^NM-/)
        card_number = @jira_helper.to_jira_number([commit_for_hotfix]).first
        @jira_wrapper.update_issue(card_number, tag: [{ name: next_tag }], sprint_number: nil)
      end
    end

    puts "Commits included in hotfix:"
    puts @commits_for_hotfix.join("\n")
  end
end

class JiraHelper
  extend Forwardable
  attr_accessor :commit_parser, :client

  class GitCommitParser
    attr_reader :base_revision, :new_revision

    def initialize(base_revision, new_revision)
      @base_revision = base_revision
      @new_revision = new_revision
    end

    def commits_between_revisions
      @commits ||= `git log #{base_revision}..#{new_revision} --no-merges`.split("\n").select { |c| c.include?("    ") }.map(&:strip)
    end

    def jira_commits
      @jira_commits ||= commits_between_revisions.select { |c| c =~ /^NM-\d{4}/ }
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

  def next_tag(number_position)
    arr = last_tag.split('.')
    arr[number_position] = arr[number_position].to_i + 1
    if number_position == 1
      arr[2] = 0
    end
    @next_tag = arr.join('.')
  end

  def last_tag
    `git describe`.split('-')[0]
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
    array.map { |a| a[0..6] }
  end

  def full_names(numbers, array)
    numbers.map { |n| array.find { |a| a.include?(n) } }
  end

  def jira_client
    @jira_wrapper = JiraWrapper.new
  end

end

class JiraCardPrinter

  def initialize
  end

  def print(name, issue_hash)
    puts %Q{
Is this issue part of the sprint:

  Number: #{name}
  fixVersions: #{issue_hash[:fixVersions]}
  status: #{issue_hash[:status]}
  assignee: #{issue_hash[:assignee]}
  epic: #{issue_hash[:epic]}
  sprint: #{issue_hash[:sprint]}
    }
  end
end
