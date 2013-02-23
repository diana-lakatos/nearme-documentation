web: bundle exec rails server thin -p $PORT -e $RACK_ENV
resque: bundle exec env QUEUE=* rake environment resque:work
delayed_job: bundle exec rake jobs:work
