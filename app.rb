require 'sinatra'
require 'open-uri'
require 'icalendar'
require 'logger'

enable :logging

before do
  logger.level = Logger::DEBUG
end

get '/' do
  erb :index
end

get '/cal' do
  unless params['url'] =~ /\Ahttps:\/\/ext\.todoist\.com\/Export\/icalTodoist\?/
    status 404
    return
  end
  cal_file = open(params['url'])
  cals = Icalendar::Calendar.parse(cal_file)
  cal = cals.first
  cal.events.each_with_index do |event, i|
    begin
      if m = event.summary.match(/\/P(.*?)\//)
        event.location = m[1]
        event.summary.gsub!("/P#{m[1]}/", "")
      end
      if m = event.summary.match(/\/H([0-9]+)hours\//)
        event.dtend = event.dtstart + (m[1].to_i / 24.0)
        event.summary.gsub!("/H#{m[1]}hours/", "")
      end
      if m = event.summary.match(/\/D([0-9]+)days\//)
        event.dtend = event.dtstart + m[1].to_i
        event.summary.gsub!("/D#{m[1]}days/", "")
      end
    rescue
    end
    cal.events[i] = event
  end
  content_type 'text/calendar'
  cal.to_ical
end