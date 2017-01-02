# Desks Near Me

All documentation is set out on the [GitHub Wiki](https://github.com/mdyd-dev/desksnearme/wiki).

### Code documentation guidelines

For drops:

* Use "see" as much as possible (@return (see ...))
* Use @return as much as possible and descriptions as little as possible (if no params, and no other info besides the return value is needed)
* If the see is linking to an attribute, add description above see
* If see is not linking to an attribute, add the description to the @return of the target (after adding a @return on the target)
* If not using see (non-linkable), add the description after @return

### Cheatsheet to get started

```
brew install redis postgresql elasticsearch imagemagick qt55 icu4c node
brew linkapps qt55
brew link --force qt55
bundle
npm install -g yarn
yarn install
gulp build
```

### Credentials setup

Add to bash, for example ~/.bash_profile :

    export AWS_ACCESS_KEY_ID=yourkeyid
    export AWS_SECRET_ACCESS_KEY=youraccesskey
    export AWS_USER=yourname
    export AWS_OPSWORKS_REGION=us-east-1

### Get Database Backup

After you configure database.yml and create database with `rake db:create`, get backup to fill it with the current
data using `rake backup:restore` in your console.

### ElasticSearch on local

To make ES search work locally you have to enable scripting queries in your local ES instance. to do so please edit ES config file in ES installation path (for example /usr/local/Cellar/elasticsearch/2.4.0/libexec/config/elasticsearch.yml) and add:

    script.engine.groovy.inline.search: on
    script.inline: on
    script.indexed: on
    script.disable_dynamic: false

After installing ES you load need to create indecies

    rake elastic:indices:create_all
    rake "elastic:indices:rebuild:all_for_instance[1]"

### Assets on local

You have to install gulp on local - use

    brew install node
    npm install -g gulp

Then in project directory:

    yarn install

And last thing:

    gulp build:development

Note - if you want to run cucumber tests on local, please compile assets for test environment:

    gulp build:test

If you are directly working with assets, to avoiding having to compile assets after each change, just use:

    gulp serve

### Payments Configuration

Go to the Payments Settings in instance_admin in your Application `/instance_admin/settings/payments` and edit
"Stripe" Payment Gateway. In 'Sandbox settings > Login' set `sk_test_lpr4WQXQdncpXjjX6IJx01W7`.

If there is no "Stripe" Payment Gateway, just create it.

For payments use any Security Code (CVV), Expiration date that is in future and card numbers from: `https://stripe.com/docs/testing#cards`

### Different Instances (Market Places [MP])

In Rails Console run:

    Domain.find_each { |d| d.update_column(:name, d.name.gsub('near-me.com', 'lvh.me')) }

To access the Instance you need locally, find its domain with the 'lvh.me' part and use instead of 'localhost'.

For easy find, use: `Domain.where('name like ?', "%lvh.me").pluck(:name)`

Remember about port in url address: `<mp>.lvh.me:3000`

### DEPLOY Procedure

The code approved by QA is inside staging branch. Go ahead and make sure that you have newest code:

    git fetch --all
    git checkout master
    git merge origin/staging

Then just invoked:

    rake jira:release_sprint

Once you are done, add manually proper tag. To save work, you can check the latest tag via:

    git describe

And invoke command ( of course replace x., y+1, z with proper numbers based on latest tag ):

    git tag -a x.y+1.z -m 'Sprint ... and other description'
    git push --tags

Make sure you have pushed master as well: `git push origin master` and proceed with deploy:

    bin/nearme deploy -r master -e nm-production
    bin/nearme deploy -r master -e nm-oregon

Last thing: Merge code -> master to staging, current_sprint to staging, staging to current_sprint etc

### Troubleshooting

#### Capybara & qt
If you can't install capybara gem, try following:
```
gem uninstall capybara-webkit
gem uninstall capybara
brew remove qt5 qt55
brew install qt55
brew linkapps qt55
brew link --force qt55
bundle install
```

If you have xcode 8.0+ and get an error:

    Project ERROR: Xcode not set up properly. You may need to confirm the license agreement by running /usr/bin/xcodebuild.

Look into this solution [https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#xcode-80](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#xcode-80)

If you have Sierra, you wont be able to install Qt55 normally, to work around this look into this solution: [https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#macos-sierra-1012](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit#macos-sierra-1012)

More on [capybara-webkit troubleshooting.](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit)

#### charlock_holmes (0.7.3) and new icu4c (57.1) on OSX

`charlock_holmes` in 0.7.3 does not work with `icu4c` in 57.1

Quick solution is to switch icu4c to previous working version:

    brew switch icu4c 56.1
