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
