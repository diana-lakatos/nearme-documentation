# stop ES
sudo service elasticsearch stop

# start custom ES instance
docker-compose -f ci/docker-compose.ci.yml up -d es

# install gems
bundle install --deployment --path ~/.semaphore_cache/bundle --without=development

# prepare DB
RAILS_ENV=test bundle exec rake db:create db:schema:load
