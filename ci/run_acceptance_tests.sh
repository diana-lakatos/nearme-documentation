#freeze node version because of gulp
# nvm use 6.9.5

#rm -rf ./node_modules

# do not update lockfile on CI -- do it locally and commit
yarn --force --frozen-lockfile

# Make sure staging is in git refs
git fetch origin staging
bundle exec pronto run -f github_pr github_status --exit-code -r rails_best_practices brakeman eslint fasterer reek rubocop -c origin/staging

# build assets
node ./node_modules/gulp/bin/gulp.js build:test

# run e2e tests
RAILS_ENV=test bundle exec rake cucumber:verbose
