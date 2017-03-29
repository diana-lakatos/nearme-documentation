#freeze node version because of gulp
# nvm use 6.9.5

#rm -rf ./node_modules

# do not update lockfile on CI -- do it locally and commit
time yarn --force --frozen-lockfile

# run linter tests
time ./node_modules/coffeelint/bin/coffeelint ./app/frontend/javascripts
time node ./node_modules/eslint/bin/eslint.js ./app/frontend/javascripts

time bundle exec pronto run -c staging -f github_pr github_status --exit-code

# build assets
time node ./node_modules/gulp/bin/gulp.js build:test

# run e2e tests
RAILS_ENV=test time bundle exec rake cucumber:verbose
