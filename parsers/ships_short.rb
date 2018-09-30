require_relative "./shared"

rows = read_fixture("ships_short", "list_of_ships")
  .css(".mw-parser-output .wikitable tr")
  .reject { |row| row.at("th") }

thumbnails = read_fixture("ships_short", "thumbnails")

data = rows.map do |row|
  tds            = row.css("td").map(&:text)
  img            = thumbnails.at("a[title='#{tds[1]}'] img")
  thumbnail_path = img ? (img["srcset"] || img["src"]).split.first : nil

  {
    id:          tds[0],
    name:        tds[1],
    rarity:      tds[2],
    type:        tds[3],
    affiliation: tds[4],
    stats:       {
      firepower: tds[5],
      health:    tds[6],
      antiAir:   tds[7],
      speed:     tds[8],
      airPower:  tds[9],
      torpedo:   tds[10]
    },
    url: build_url(row.at("a")["href"]),
    thumbnail: thumbnail_path.nil? ? nil : build_url(thumbnail_path)
  }
end

write_json(data, "ships_short")
