# frozen_string_literal: true
require 'jira-ruby'
require 'chronic'

class JiraWrapper
  NM_PROJECT_ID = 10_000

  def initialize
    @client = JIRA::Client.new(username: 'jira-api', password: 'j1r44p1$%', context_path: '', site: 'https://near-me.atlassian.net', rest_base_path: '/rest/api/2', auth_type: :basic, read_timeout: 120)
  end

  def ensure_version_present!(name:, description:)
    puts "Ensuring version exists: #{name}"
    unless version(name).present?

      splitted_version = name.split('.')
      if splitted_version.last == '0'
        previous_version = [splitted_version[0], splitted_version[1].to_i - 1, 0].join('.')
        old_version = version(previous_version)
        raise 'Previous version was not found!!!' if old_version.nil?
        user_start_date = old_version.userReleaseDate
      else
        user_start_date = Time.current.strftime('%-d/%b/%y')
      end
      user_released_date = Time.current.strftime('%-d/%b/%y')

      hash = {
        description: description,
        name: name,
        projectId: NM_PROJECT_ID,
        userStartDate: user_start_date,
        userReleaseDate: user_released_date
      }
      puts "\tDoes not exists, creating: #{hash.inspect}"
      current_version = @client.Version.build
      current_version.save(hash)
      @versions << current_version
    end
    current_version
  end

  def issues(jql)
    @issues ||= @client.Issue.jql(jql, max_results: 500)
  end

  def find_issue(number)
    @issues.try(:detect) { |i| i.key == number } || @client.Issue.find(number)
  rescue
    nil
  end

  def epic_hash
    unless @epics
      @epics = {}
      cards = @client.Issue.jql("project = \"Near Me\" AND type = 'Epic'", max_results: 500)
      cards.each do |card|
        @epics[card.key] ||= card.summary
      end
    end
    @epics
  end

  def issue_hash_for_number
    issue_hash(find_issue(number))
  end

  def issue_hash(issue)
    return nil if issue.nil?
    {
      name: issue.key + ' ' + issue.summary,
      fixVersions: issue.fixVersions.map(&:name).join(', '),
      status: issue.status.name,
      assignee: issue.assignee.displayName,
      sprint: issue.customfield_10007.try(:map) { |s| s.split('name=')[1].split(':')[0] }.try(:join, ', '),
      epic: epic_for_issue(issue)
    }
  end

  def epic_for_issue(issue)
    epic_hash[issue.customfield_10008]
  end

  def assign_version(issue, fixVersion)
    issue.save(fields: { fixVersions: [{ name: fixVersion }] })
  end

  def version(tag)
    versions.detect { |v| v.name == tag }
  end

  def release_notes(tag)
    v = version(tag)
    "https://near-me.atlassian.net/secure/ReleaseNote.jspa?projectId=#{NM_PROJECT_ID}&version=#{v.id}"
  end

  def project
    @project ||= @client.Project.find(NM_PROJECT_ID)
  end

  def versions
    @versions ||= project.versions
  end

  def next_tag(number_position)
    return @next_tag if @next_tag.present?
    arr = last_tag.split('.')
    arr[number_position] = arr[number_position].to_i + 1
    arr[2] = 0 if number_position == 1
    @next_tag = arr.join('.')
  end

  def last_tag
    `git describe`.split('-')[0]
  end

  def release_version!(version)
    version(version).save(released: true)
  end
end
