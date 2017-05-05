# Lets keep here list of usefull howtos.

## How to use it?
1. It is markdown
2. Start every topic with h2 (##)
3. Use lists

## Capture backup from production

1. Use `bin/nearme capture`
2. Otherwise
  * login to production ssh nm-app-1
  * and run `sudo -H -u deploy bash -c 'cd /srv/www/nearme/current && AWS_ACCESS_KEY_ID=123  AWS_SECRET_ACCESS_KEY=123  RAILS_ENV=production bundle exec rake backup:capture`


## Ssh to staging/production

1. `bin/nearme update_ssh_config` will append updated settings to USER_HOME/.ssh/config file
2. test it `ssh nm-production-california-app-2`
3. use bash|zsh with enabled autocomplete for quicker hostname access

## MPBuilder

Load changed config for particular marketplace

    bin/rake mpbuilder:run source=marketplaces/hallmark


## Mails

In order to test mailers just use `mailcatcher` in development.
