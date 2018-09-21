require "rest-client"

FIXTURE_DIR = File.join(__dir__, "..", "fixtures")
Dir.mkdir(FIXTURE_DIR) unless File.exist?(FIXTURE_DIR)

def fetch_html(url)
  RestClient.get(url)
end

def write_fixture(dir, name, html)
  dir_path = File.join(FIXTURE_DIR, dir)
  Dir.mkdir(dir_path) unless File.exist?(dir_path)
  File.write(File.join(dir_path, "#{name}.html"), html)
end
