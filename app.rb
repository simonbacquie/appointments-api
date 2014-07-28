require 'rubygems'
require 'sinatra'
require 'sinatra/activerecord'
require 'mysql'
require 'json'
# require 'pry'
require_relative 'settings.rb'

set :database, $db_string
 
class FutureDateValidator < ActiveModel::Validator
	def validate(record)
		[:start_time, :end_time].each do |field|
			if record.send(field) < Date.today
				record.errors.add(field, "must be a date in the future")
			end
		end
	end
end

class TimeOverlapValidator < ActiveModel::Validator
	def validate(record)
		start_time = DateTime.parse(record.send(:start_time).to_s).to_s(:db)
		end_time = DateTime.parse(record.send(:end_time).to_s).to_s(:db)

		sql = "(end_time IS NULL OR end_time > '#{start_time}') AND (start_time IS NULL OR start_time < '#{end_time}')"

		# if it's an update, we don't want updated row to raise a conflict with itself
		if (!record.id.nil?)
			sql += " AND id != #{record.id}"
		end

		conflicts = Appointment.where(sql)

		if conflicts.any?
			record.errors.add(:start_time, "has a scheduling conflict")
		end
	end
end

class Appointment < ActiveRecord::Base
	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :start_time, presence: true
	validates :end_time, presence: true

	validates_with FutureDateValidator
	validates_with TimeOverlapValidator
end

# LIST
get '/appointments' do
	where = {}
	if !params[:start_time].nil?
		begin
			Date.parse params[:start_time]
		rescue ArgumentError
			status 400
			return {error: "Invalid date"}.to_json
		end

		where['start_time'] = params[:start_time]
	end

	if !params[:end_time].nil?
		begin
			Date.parse params[:end_time]
		rescue ArgumentError
			status 400
			return {error: "Invalid date"}.to_json
		end

		where['end_time'] = params[:end_time]
	end

	if !where.empty?
		return Appointment.where(where).order('start_time').to_json
	end

	return Appointment.all.order('start_time').to_json
end

# VIEW SINGLE
get 'appointments/:id' do
	appointment = Appointment.find(params[:id])
	return status 404 if appointment.nil?
	appointment.to_json
end

# CREATE
post '/appointments' do
	# unwanted fields break saving records, so discard them
	allowed_fields = ['first_name', 'last_name', 'start_time', 'end_time', 'comments']
	attrs = params.select do |key, val|
		allowed_fields.include? key
	end

	appointment = Appointment.new(attrs)
	appointment.save

	if appointment.errors.any?
		status 400
		return appointment.errors.to_json
	end

	status 201
	return appointment.to_json
end

# UPDATE
put '/appointments/:id' do
	allowed_fields = ['id', 'first_name', 'last_name', 'start_time', 'end_time', 'comments']
	attrs = params.select do |key, val|
		allowed_fields.include? key
	end

	appointment = Appointment.find(params[:id])
	return status 404 if appointment.nil?

	appointment.update(attrs)

	if appointment.errors.any?
		status 400
		return appointment.errors.to_json
	end

	status 202
	return appointment.to_json
end

# DELETE
delete '/appointments/:id' do
	appointment = Appointment.find(params[:id])
	return status 404 if appointment.nil?
	appointment.delete
	status 202
end
