# Desks Near Me

### Setup

Desks Near Me is a standard rails application. Setup is just:

```bash
bundle
rake db:setup
RACK_ENV=development foreman start
```

### Running tests

We use guard + spork to run our tests for us. After bundling just type `guard`
and you're in!

To run tests with spork outside of guard you must have a spork server running
by typing `spork minitest` or `spork cucumber`. Then run
`cucumber --drb feature/file.feature` and `testdrb test/file\_test.rb`

### Documents to get started:
* [Get your environment ready](https://github.com/mdyd-dev/desksnearme/wiki/Getting-Started)
* [Development cycle](https://github.com/mdyd-dev/desksnearme/wiki/Development-Cycle)
* [Testing tools](https://github.com/mdyd-dev/desksnearme/wiki/Testing-Tools)


## Releasing


### Hotfixes

There will be times when we must hotfix production. To do so:

1. Commit the change to master (Preferably via pull request)
5. Cherry-pick the change from master branch into production branch
6. Deploy production branches recipes to staging
6. Deploy production branch to staging
6. Smoke test
6. Tag the production branch
7. Deploy the tag to production
