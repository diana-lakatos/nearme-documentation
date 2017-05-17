## Reecrypting Protected Attributes

In case when you need to access protected data from one datacenter(or env) in another,
you need to decrypt data with SECRET_KEY from that datacenter and encrypt it again
with the one assigned to new datacenter.
SECRET_KEY is stored in ENV VAR called 'RAILS_SECRET_TOKEN'.
It can be found in Opsworks > (Some stack) > Apps > Details

### Use Case Example
Moving data of some marketplaces from California datacenter to Sydney datacenter.


### Example:

```sh
⇒ RAILS_ENV=env OLD_KEY='some_key' INSTANCE_ID='some id' bin/rake reencrypt:all_data
```


### Notes

INSTANCE_ID parameter is optional. If not provided, rake will do all Instances
