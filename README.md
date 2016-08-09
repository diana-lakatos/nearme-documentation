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
"Stripe" Payment Gateway. In 'Sandbox settings > Login' set ``` sk_test_lpr4WQXQdncpXjjX6IJx01W7 ```.

If there is no "Stripe" Payment Gateway, just create it.

For payments use any Security Code (CCV), Expiration date that is in future and card numbers from:
``` https://stripe.com/docs/testing#cards ```

### Different Instances (Market Places [MP])

In Rails Console run:

``` Domain.find_each { |d| d.update_attribute(:name, d.name.gsub('near-me.com', 'lvh.me')) } ```

To access the Instance you need locally, find its domain with the 'lvh.me' part and use instead of 'localhost'.

For easy find, use: ```  Domain.where('name like ?', "%lvh.me").pluck(:name) ```

Remember about port in url address: ``` <mp>.lvh.me:3000 ```
