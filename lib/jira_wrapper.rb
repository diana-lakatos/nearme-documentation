require 'jira-ruby'
require 'chronic'

class JiraWrapper
  NM_PROJECT_ID = 10_000

  def initialize
    @client = JIRA::Client.new(username: 'jira-api', password: 'N#arM3123adam', context_path: '', site: 'https://near-me.atlassian.net', rest_base_path: '/rest/api/2', auth_type: :basic, read_timeout: 120)
  end

  def initiate_current_sprint!
    monday = Time.now.monday? ? Date.current : Chronic.parse('last monday')
    sprint = @client.Sprint.find(monday.strftime('%Y-%m-%d'))['issues'].first['fields']['customfield_10007'].last
    current_sprint_id = sprint.split('id=')[1].split(',')[0].to_i
    sprint_name = sprint.split('name=')[1].split(',')[0]
    start_date = sprint.split('startDate=')[1].split(',')[0]
    end_date = sprint.split('endDate=')[1].split(',')[0]
    ensure_version_present!(name: next_tag(1), description: sprint_name, user_released_data: end_date, user_start_date: start_date, start_date: start_date)
    current_sprint_id
  end

  def initiate_hotfix!(description = 'Hotfix')
    tag = next_tag(2)
    ensure_version_present!(name: tag, description: description, user_released_data: Time.now.to_s, user_start_date: Time.now.to_s, start_date: Time.now.to_s)
    tag
  end

  def ensure_version_present!(name:, start_date:, user_released_data:, user_start_date:, description:)
    unless version(name).present?
      current_version = @client.Version.build
      current_version.save(description: description,
                           name: name,
                           projectId: NM_PROJECT_ID,
                           userStartDate: Chronic.parse(user_start_date).strftime('%-d/%b/%y'),
                           userReleaseDate: Chronic.parse(user_released_data).strftime('%-d/%b/%y'))
      @versions << current_version
    end
    current_version
  end

  def issues(sprint)
    @issues ||= @client.Issue.jql("project = \"Near Me\" AND sprint = #{sprint.to_i} AND status != Closed", max_results: 500)
  end

  def find_issue(number)
    @issues.try(:detect) { |i| i.key == number } || @client.Issue.find(number)
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

  def issue_hash(number)
    issue = find_issue(number)
    {
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

  def update_issue(number, options)
    issue = find_issue(number)
    issue.save(fields: { fixVersions: options[:tag] })
    issue.save(fields: { customfield_10007: options[:sprint_number] })
  rescue => e
    puts "Error for card: #{card_in_sprint}. #{e}"
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
