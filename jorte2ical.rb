#!/usr/bin/env ruby
# Export Jorte csv to icalendar.
# Licensed under GPLv3

require 'icalendar'
require 'date'
require 'csv'

if ARGV.length != 1
	puts "Usage: jorte2ical.rb schedule_data.csv > events.ics"
	exit 0
end

def to_ical(dtstart, dtend, tmstart, tmend, zone)
	dtstart0 = DateTime.parse("#{dtstart} #{tmstart} #{zone}")
	dtend0 = DateTime.parse("#{dtend} #{tmend} #{zone}")

	if tmstart.nil? and tmend.nil?
	# If not tmstart and not tmend use Date
		ical_dtstart = Icalendar::Values::Date.new(dtstart0)
		ical_dtend = Icalendar::Values::Date.new(dtend0)
	else
		dtstart0 = dtstart0.to_time
		dtend0 = dtend0.to_time
		if ! tmstart.nil? and tmend.nil?
			# If tmstart but not tmend, tmend = tmstart + 1h
			dtend0 = dtstart0 + 3600
		end
		# If tmstart and tmend use both
		ical_dtstart = Icalendar::Values::DateTime.new(dtstart0)
		ical_dtend = Icalendar::Values::DateTime.new(dtend0)
	end

	return ical_dtstart, ical_dtend
end


file_in = File.read(ARGV[0])
jorte_csv = CSV.new(file_in, { :headers => :first_row })
cal = Icalendar::Calendar.new


jorte_csv.each do |row|
	dtstart=row.values_at[0]
	dtend = row.values_at[1]
	tmstart=row.values_at[2]
	tmend=row.values_at[3]
	title=row.values_at[4]
	rrule=row.values_at[9]
	content=row.values_at[11]

	zone = Time.now.zone

	ical_dtstart, ical_dtend = to_ical(dtstart, dtend, tmstart, tmend, zone)

	cal.event do |e|
		e.dtstart=ical_dtstart
		e.dtend=ical_dtend
		e.summary = title
		e.description = content
		e.rrule = rrule unless rrule.nil?
	end
end

puts cal.to_ical
