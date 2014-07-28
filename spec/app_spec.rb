require_relative '../app.rb'
require 'rspec'
require 'rack/test'
require 'sinatra'
# require 'pry'


def is_valid_json?(json)
	begin
		JSON.parse(json)
		return true
	rescue Exception
		return false
	end
end

describe "AppointmentsAPI" do
	include Rack::Test::Methods

	def app
		Sinatra::Application
	end

	it "should allow listing all appointments" do
		get '/appointments'
		last_response.should be_ok
	end

	it "should show the appointments list as valid json" do
		get '/appointments'
		expect(is_valid_json?(last_response.body)).to be true
	end
end
