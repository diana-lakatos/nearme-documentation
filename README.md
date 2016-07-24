# Desks Near Me

All documentation is set out on the [GitHub Wiki](https://github.com/mdyd-dev/desksnearme/wiki).

### Get Database Backup
  
After you configure database.yml and create database with ``` rake db:create ```, get backup to fill it with the current 
data using ``` rake backup:restore ``` in your console. 
  
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
  
For easy find, use: ```  Domain.where(‘name like ?’, “%lvh.me”).pluck(:name) ```
 
Remember about port in url address: ``` <mp>.lvh.me:3000 ```
