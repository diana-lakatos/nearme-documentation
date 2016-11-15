# sendle client

## configuration

you can set credentials either by setting enviromental variables

    ENV['SENDLE_ID'] =
    ENV['SENDLE_API_KEY'] =

or by passing data to a client contructor:

    client = SendleApi.new sendle_id: 'SENDLE_ID', sendle_api_key: 'SENDLE_API_KEY'


### http client debugging

    ENV['HTTP_LOGGER_LEVEL'] = 'debug' || nil

## usage

### ping

    client = SendleApi.new

    response = client.ping
    response.success? # => true
