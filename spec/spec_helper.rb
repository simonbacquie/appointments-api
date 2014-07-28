require 'sinatra'
require 'rspec'
require 'rack/test'

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
	config.include Rack::Test::Methods
	config.expect_with :rspec do |c|
		c.syntax = [:should, :expect]
	end
end
