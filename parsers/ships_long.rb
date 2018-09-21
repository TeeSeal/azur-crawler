require_relative "./shared"

def extract_names(title)
  title = title.gsub(/^[A-Z]{3,4} /, "")
  {
    en: title[/^[^\(]+/].strip,
    cn: title[/(?<=cn: )[^;]+/].strip,
    jp: title[/(?<=jp: )[^\)]+/].strip
  }.compact
end

data = all_fixtures_from("ships_long").map do |html|
  title = html.at("span").text.strip
  names = extract_names(title)
  puts title
  puts names
  puts "-----"
end
