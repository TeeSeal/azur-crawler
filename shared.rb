require "nokogiri"
require "rest-client"
require "json"

# Default location for output data if no path provided
DATA_DIR = File.join(__dir__, "data")
Dir.mkdir(DATA_DIR) if ARGV.empty? && !File.exist?(DATA_DIR)

def write_json(data, default_name = "undefined")
  file_path = ARGV.first || File.join(DATA_DIR, default_name + ".json")
  File.write(file_path, JSON.pretty_generate(data))
end

def fetch_html(url)
  Nokogiri::HTML(RestClient.get(url))
end
