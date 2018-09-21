require "nokogiri"
require "json"

# Default location for output data if no path provided
DATA_DIR    = File.join(__dir__, "..", "data")
FIXTURE_DIR = File.join(__dir__, "..", "fixtures")


Dir.mkdir(DATA_DIR) if ARGV.empty? && !File.exist?(DATA_DIR)

def read_fixture(dir, name)
  file = File.join(FIXTURE_DIR, dir, "#{name}.html")
  Nokogiri::HTML(File.read(file))
end

def all_fixtures_from(dir)
  files = Dir[File.join(FIXTURE_DIR, dir, "*")]
  files.map { |file| Nokogiri::HTML(File.read(file)) }
end

def write_json(data, default_name = "undefined")
  file_path = ARGV.first || File.join(DATA_DIR, default_name + ".json")
  File.write(file_path, JSON.pretty_generate(data))
end


