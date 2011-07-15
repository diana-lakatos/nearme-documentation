dep 'bootstrap' do
  requires 'bundled'
end

dep 'bundled' do
  requires 'bundler'

  met? { false }
  meet {
    log_shell 'Installing gems',  'bundle install'
    met? { true }
  }
end

dep 'bundler' do
  met? { which 'bundle' }
  meet { shell 'gem install bundler' }
end
