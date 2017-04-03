wget https://gist.githubusercontent.com/mimimalizam/27959bbc653de3965bb40955f4bc43df/raw/pg-downgrade-semaphore.sh && bash pg-downgrade-semaphore.sh

# stop ES
sudo service elasticsearch stop

# start custom ES instance
docker-compose -f ci/docker-compose.ci.yml up -d es

# install gems
# use more than 1 core
number_of_cores=`cat /proc/cpuinfo | grep processor | wc -l`
bundle config --global jobs `expr $number_of_cores - 1`

bundle check || time bundle install --deployment --path vendor/bundle --without=development

# prepare DB
RAILS_ENV=test bundle exec rake db:create db:schema:load
