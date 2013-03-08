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


## Merging Pull Requests
We follow a pull request strategy to ensure every change gets a second pair of
eyes on both the code and the functionality before being deployed to staging.

Here is the process I follow when merging a pull request:

1. Pull the code down, and make it up to date with master (either by rebase or
   merge)
2. Run rake
3. Do a smoke test: run happy/sad paths, resize the browser to phone/tablet
   sizes, etc. Keep an eye out for behavior that seems odd or visual anomolies.
4. Do a code review: look for missing tests, duplication, complexity, etc.
5. If you feel the feature is worth merging
   * Merge into master with a commit that states [delivers#tracker-number]
   * Merge into staging, using --ff-only
   * Release staging to the staging environment
6. If you do *not* feel the feature is worth merging, close the ticket
   with a comment explaining why.

## Review Design
Before merging front-end changes into master, have [Harold](mail:toharold@desksnear.me) review the UI & UX. Make sure you are testing your changes on mobile > tablet > desktop before your design review.


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

## Introducing new tools/gems/frameworks/etc.

The preference is to use existing tools/gems/frameworks, where possible. Check
the Gemfile to see what we're already using.

If you feel a new tool is required, discuss with the team to gain a consensus on
the whether it is required, appropriate, and the preferred option.

#### Useful links:
* [Rollback last deploy](https://github.com/mdyd-dev/desksnearme/wiki/Engine-Yard-Cheat-Sheet#wiki-3)
