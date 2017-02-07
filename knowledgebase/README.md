# Lets keep here list of usefull howtos.

## How to use it?
1. It is markdown
2. Start every topic with h2 (##)
3. Use lists


## Payments with **Paid Link**

1. Go to listing page: https://staging.near-me.com/locations/qa-san-francisco-ca-usa-14090/qa-25295 and "Book"
2. Pay and choose **Bank of America**
  * username:  plaid_test
  * password:  plaid_good
  * "You say tomato, I say ?": tomato


## Capture backup from production

1. Use `bin/nearme capture`
2. Otherwise
  * login to production ssh nm-app-1
  * and run `sudo -H -u deploy bash -c 'cd /srv/www/nearme/current && AWS_ACCESS_KEY_ID=123  AWS_SECRET_ACCESS_KEY=123  RAILS_ENV=production bundle exec rake backup:capture`


## Ssh to staging/production

1. Copy https://gist.githubusercontent.com/godot/128ea15d74e2308d0f21fe5464b0f220/raw/3e1f633e456c5d29d31929abac840046414d01a4/.ssh--config into `~/.ssh/config`
2. Change NM-USERNAME in `~/.ssh/config`, usually first and last name
3. Test it `ssh nm-staging-app-1`
