# Marketplace Builder 1.0
The file describes new Marketplace Builder functionalities.

## Supported parts of application
- [ ] marketplace details
- [x] transactable types
- [ ] instance profile types
- [ ] reservation types
- [ ] topics
- [ ] categories
- [x] pages
- [ ] content holders
- [ ] mailers
- [ ] SMS
- [x] liquid views
- [x] translations
- [x] workflows
- [ ] custom model types
- [ ] graph queries
- [x] custom themes and assets
- [ ] rating system
- [ ] form configuration

## What if I want to export/import part that is not supported?
You can stil use old marketplace import and export command or collaborate to new MP builder.

## Installation
1. Go to `desksnearme/vendor/gems/nearme-marketplace`
2. Run `rake install`

## Configuration
1. Go to marketplace folder you are working on
2. `cp marketplace_builder/.endpoints.example marketplace_builder/.endpoints`
3. Open the .endpoints file

```
{
  "user_key": "your_user_key",
  "local": {
    "url": "http://roost.oregon.lvh.me:3000/",
    "api_key": "xxx"
  },
  "staging": {
    "url": "https://roost.oregon-staging.near-me.com/",
    "api_key": "xxx"
  },
  "production": {
    "url": "https://roost.oregon.near-me.com/",
    "api_key": "xxx"
  }
}
```
4. Replace your_user_key with user auth key:
```
rails c
User.find_by(email: 'michal@near-me.com').authentication_token
```

5. Replace api_key with instance API key (availble in MP Admin).
http://roost.oregon.lvh.me:3000/instance_admin/settings/api_keys

## Commands

`nearme-marketplace pull`

Pulls the version from DB to the files.

`nearme-marketplace deploy`

Deploys the files to DB.

`nearme-marketplace sync`

Enables sync mode (auto syncing changes in the files)
