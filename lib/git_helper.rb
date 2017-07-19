class GitHelper
  def next_tag(major: true)
    number_position = major ? 1 : 2
    return @next_tag if @next_tag.present?
    arr = last_tag.split('.')
    arr[number_position] = arr[number_position].to_i + 1
    arr[2] = 0 if number_position == 1
    @next_tag = arr.join('.')
  end

  def last_tag
    `git describe`.split('-')[0]
  end

  def commits_between_revisions(base_revision, new_revision)
    @commits ||= `git log #{base_revision}..#{new_revision} --no-merges`.split("\n").select { |c| c.include?('    ') }.map(&:strip)
  end
end
