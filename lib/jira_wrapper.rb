require 'jira'

class JiraWrapper
  NM_PROJECT_ID = 10000

  def initialize
    @client = JIRA::Client.new({username: 'jira-api', password: 'N#arM3123adam', context_path: '',site: 'https://near-me.atlassian.net', rest_base_path: "/rest/api/2", auth_type: :basic, read_timeout: 120 })
  end

  def issues(sprint)
    @issues ||= @client.Issue.jql("project = \"Near Me\" AND sprint = #{sprint.to_i} AND status != Closed", max_results: 500)
  end

  def find_issue(number)
    @issues.try(:detect) { |i| i.key == number } ||  @client.Issue.find(number)
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
    issue.save({ fields: { fixVersions: options[:tag] } })
    issue.save({ fields: { customfield_10007: options[:sprint]}})
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

end

