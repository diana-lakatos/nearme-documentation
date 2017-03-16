## Marketplace View Mode

If you need to make a lot of changes in `marketplaces/**/liquid_views` you might want to run your rails server in a *MARKETPLACE_VIEW* mode. 

It will enable prioritization of liquid views placed in a directory you have passed to it over their equivalents in database.


### Example:

```sh
⇒ pwd
/Users/DNM/desksnearme
```

```sh
MARKETPLACE_VIEW=marketplaces/csn/liquid_views rails s
```

### Notes

This works only for `liquid_views` at this moment.
It will not work for content_holders, pages, mailers.
