require_relative "./shared"

urls = fetch_html("https://azurlane.koumakan.jp/List_of_Ships")
  .css(".mw-parser-output .wikitable tr")
  .reject { |row| row.at("th") }
  .map { |row| "https://azurlane.koumakan.jp#{row.at("a")["href"]}" }

urls.each do |url|
  html = fetch_html(url)
  write_fixture("ships_long", url.split("/").last, html)
end
