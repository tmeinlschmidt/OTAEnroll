# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require "dummy/config/environment"
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

def read_fixture(file, mode = "rb")
  File.open("#{File.dirname(__FILE__)}/fixtures/#{file}", mode) {|fd| fd.read}
end

def raw_post(action, params, body)
  @request.env['RAW_POST_DATA'] = body
  response = post(action, params)
  @request.env.delete('RAW_POST_DATA')
  response
end
