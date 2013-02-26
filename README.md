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


### Hotfix

There will be times when we must hotfix production. To do so:

1. Branch from master with prefix `HOT-`
2. Make necessary changes. Run tests. Push to GitHub.
3. Create pull request for branch to master and go through an expedited review (have someone on hand to do it immediately)
4. Once change is accepted and on master, checkout production and cherry-pick the commit:
  * `git cherry-pick <commit ref 8..40>`
5. Push to GitHub and deploy to staging with the production branch.
  * `ey deploy -e dnme_staging -r production`
6. Smoke test on staging.
7. All good? Tag the production branch.
  * `git tag -a <X.Y.Z> -m 'HOTFIX deploy to production. <insert meaningful message>'`
8. Push and deploy the new tag to production.
  * `ey deploy -e dnme_production -r <X.Y.Z>`
9. Smoke test on production. And breathe...

#### Useful links:
* [Rollback last deploy](https://github.com/mdyd-dev/desksnearme/wiki/Engine-Yard-Cheat-Sheet#wiki-3)
