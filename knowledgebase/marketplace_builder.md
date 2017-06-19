# Marketplace Builder 1.0
The file describes new Marketplace Builder functionalities.

## Supported parts of application
- [ ] marketplace details
- [x] transactable types
- [x] instance profile types
- [ ] reservation types
- [ ] topics
- [ ] categories
- [x] pages
- [x] content holders
- [ ] mailers
- [ ] SMS
- [x] liquid views
- [x] translations
- [x] workflows
- [x] custom model types
- [x] graph queries
- [x] custom themes and assets
- [ ] rating system
- [x] form configuration

## What if I want to export/import part that is not supported?
You can still use old marketplace import and export command or collaborate to new MP builder.

## Installation
1. Go to `desksnearme/vendor/gems/nearme-marketplace`
2. `bundle install` # installs dependencies
3. `rake install` # installs marketplace builder

## Configuration
1. Go to marketplace folder you are working on
2. Ensure `marketplace_builder` directory exists
3. Ensure `marketplace_builder/.endpoints.example` exists, otherwise copy it from this doc.
4. `cp marketplace_builder/.endpoints.example marketplace_builder/.endpoints`
5. Open the `.endpoints` file

```json
    {
      "user_key": "your_user_key",
      "local": {
        "url": "http://`project_domain`.lvh.me:3000/",
        "api_key": "xxx"
      },
      "staging": {
        "url": "https://`project_domain`.staging.near-me.com/",
        "api_key": "xxx"
      },
      "production": {
        "url": "https://`project_domain`.near-me.com/",
        "api_key": "xxx"
      }
    }
```

6. Replace `your_user_key` with your user `authentication_token`:
- Open rails console in the platform directory: `rails c`
- `User.find_by(email: 'your@email').authentication_token`

7. Replace `api_key` with instance API key (available in MP Admin).
http://`project_domain`.lvh.me:3000/instance_admin/settings/api_keys

## Commands

All commands should be run in the marketplace directory (ie. `marketplace-mycsn/`)

    nearme-marketplace pull

Pulls files from database and saves them in the filesystem

    nearme-marketplace deploy

Updates local database using the filesystem as a source

    env ENDPOINT=production nearme-marketplace deploy

Deploys to production environment

    env ENDPOINT=staging nearme-marketplace deploy

Deploys to staging environment

    nearme-marketplace sync

Enables sync mode - saves changes made in the filesystem to the database

## Options

TODO: Replace with proper `nearme-marketplace clear-cache` command

In `desksnearme/` directory open `rails console`

    Instance.find(`instance_id`).marketplace_builder_settings.update! manifest: {}

### Force mode for deploy command
To skip MD5 checking and deploy every file use force mode (-f -force).
```
nearme-marketplace deploy -force
