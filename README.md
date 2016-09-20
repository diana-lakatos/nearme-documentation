# Desks Near Me

All documentation is set out on the [GitHub Wiki](https://github.com/mdyd-dev/desksnearme/wiki).

### Credentials setup

Add to bash, for example ~/.bash_profile :

```
export AWS_ACCESS_KEY_ID=yourkeyid
export AWS_SECRET_ACCESS_KEY=youraccesskey
export AWS_USER=yourname
export AWS_OPSWORKS_REGION=us-east-1
```


### Get Database Backup

After you configure database.yml and create database with ``` rake db:create ```, get backup to fill it with the current
data using ``` rake backup:restore ``` in your console.

### Pre-requisites

```
brew install qt5
brew linkapps qt5
brew link --force qt5
brew install icu4c
```


### ElasticSearch on local

to make ES search work locally you have to enable scripting queries in your local ES instance. to do so please edit ES config file in ES installation path (elasticsearch.yml) and add:
```
script.engine.groovy.inline.search: on
script.inline: on
script.indexed: on
script.disable_dynamic: false
```

### Troubleshooting

If you can't install capybara gem, try following:

gem uninstall capybara-webkit
gem uninstall capybara
brew remove qt
brew remove qt5
brew install qt5
brew linkapps qt5
brew link --force qt5
bundle install

### Assets on local

You have to install gulp on local - use
```
brew install node
npm install -g gulp
```

Then in project directory:
```
npm install
```

And last thing:

```gulp build:development```

Note - if you want to run cucumber tests on local, please compile assets for test environment:
```
gulp build:test
```

If you are directly working with assets, to avoiding having to compile assets after each change, just use:
```
gulp serve
```

### Payments Configuration

Go to the Payments Settings in instance_admin in your Application ``` /instance_admin/settings/payments ``` and edit
"Stripe" Payment Gateway. In 'Sandbox settings > Login' set ```sk_test_lpr4WQXQdncpXjjX6IJx01W7```.

If there is no "Stripe" Payment Gateway, just create it.

For payments use any Security Code (CCV), Expiration date that is in future and card numbers from:
``` https://stripe.com/docs/testing#cards ```

### Different Instances (Market Places [MP])

In Rails Console run:

``` Domain.find_each { |d| d.update_attribute(:name, d.name.gsub('near-me.com', 'lvh.me')) } ```

To access the Instance you need locally, find its domain with the 'lvh.me' part and use instead of 'localhost'.

For easy find, use: ```  Domain.where('name like ?', "%lvh.me").pluck(:name) ```

Remember about port in url address: ``` <mp>.lvh.me:3000 ```

### DEPLOY Procedure

The code approved by QA is inside staging branch. Go ahead and make sure that you have newest code:
```
git fetch --all
git checkout master
git merge origin/staging
```
Then check what's the last tag:
```
git describe
```
It will return version in a format x.y.z. If you release hotfix, you should increment z, otherwise 99% of cases you want to increment y. If release introduced some breaking changes or is a very big initiative, like Spree Removal or upgrade Rails version, increment x (not supported via rake task described below though).

Make sure that proper next version is added in jira: https://near-me.atlassian.net/projects/NM?selectedItem=com.atlassian.jira.jira-projects-plugin%3Arelease-page&status=all .
If it is regular deploy, the next thing to do is to run this command [ for hotfix just use release_hotfix without argument ]:
```
rake jira:release_sprint[X] # for example rake jira:release_sprint[50] to release sprint with ID 50
```
where X is ID of a sprint - you can check what's the ID for example while searching - https://near-me.atlassian.net/issues/ - just type in `Sprint = "NM Sprint ..." where ... is the sprint number, and when you click on autocomplete it will transform sprint name into ID.

The script will first check if all commits have corresponding jira card, and if so, if the jira card is assigned to proper sprint. That's why it's so important to start each commit with NM-XXX, where XXX is a proper number. Then, it will fetch list of all cards assigned to sprint from jira and will ask you question whether it is part of a sprint or not. If not, you will be able to choose whether to move it to the next sprint or not.

Once you are done, add manually proper tag via
```
git tag -a x.y+1.z -m 'Sprint ... and other description'
git push --tags
```
Make sure you have pushed master as well: `git push origin master` and proceed with deploy:
```
bin/nearme deploy -r master -e nm-production
bin/nearme deploy -r master -e nm-oregon
```
Go to jira and:
1) Mark version as released
2) Go to Boards -> View all boards -> choose 'Configure' on current -> update quick filters
3) merge code -> master to staging, current_sprint to staging, staging to current_sprint etc
