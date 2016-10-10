class IntelFakerService
  DESCRIPTION = 'Quisque euismod orci sed nisi malesuada porta. In non molestie purus. Sed ut maximus nibh, eu ultrices massa. Quisque euismod orci sed nisi malesuada porta. In non molestie purus. Sed ut maximus nibh, eu ultrices massa.'
  NAMES = ['Josh B.', 'Patrica D.', 'Sara H.', 'Charles X.', 'Craig C.', 'Curtis S.', 'Mike M.', 'Margaret M.', 'Leo A.']
  JOB_TITLES = ['Community Manager', 'Senior UX Designer', 'Node JS Developer', 'Front-end Developer', 'Ruby Developer', 'Enterprise Sales']
  PROJECT_TITLES = ['Intel System Studio', 'Intel RealSense', 'Intel IoT Developer Kit', 'Connected Wheelchair Project']
  FEED_ITEM_DESCRIPTION = ['Just updated their profile', 'Created a new blog post', 'Posted a comment in #android', 'Posted a new discussion', 'Was added as a collaborator to #iOS']

  def self.feed_items(number = 5)
    (1..number).inject([]) { |result, _n| result << OpenStruct.new(display_name: name, description: feed_item_description, date: "#{Random.rand(1..60)} min ago", avatar_path: "community/silhouette_#{Random.rand(1..7)}.png") }.sort { |a, b| a[:date].to_i <=> b[:date].to_i }
  end

  def self.projects(number = 4)
    (1..number).inject([]) { |result, _n| result << OpenStruct.new(title: project_title, date: 'April 18th, 2015', description: DESCRIPTION, collaborators: Random.rand(5..15), followers: Random.rand(50..500), comments: Random.rand(25..180)) }
  end

  def self.people(number = 10)
    (1..number).inject([]) { |result, _n| result << OpenStruct.new(name: name, title: job_title) }
  end

  private

  def self.name
    NAMES.sample
  end

  def self.job_title
    JOB_TITLES.sample
  end

  def self.project_title
    PROJECT_TITLES.sample
  end

  def self.feed_item_description
    FEED_ITEM_DESCRIPTION.sample
  end
end
