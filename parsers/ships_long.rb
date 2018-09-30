require_relative "./shared"

def extract_names(html)
  title = html.at("span").text.strip.gsub(/^[A-Z]{3,4} /, "")

  {
    names: {
      en: title[/^[^\(]+/].strip,
      cn: title[/(?<=cn: )[^;]+/].strip,
      jp: title[/(?<=jp: )[^\)]+/].strip
    }
  }
end

def extract_base_data(html)
  rows = html.css("tr").first(6).map { |row| row.at("td").text.strip }
  data = [:construction_time, :rarity, :class, :id, :nationality, :type].zip(rows).to_h

  data[:rarity] = parse_rarity(html.css("tr")[1].at("img")["alt"])
  data
end

def extract_stats(html)
  tds = html.at("[title*='Base Stats']").css("tr")[-3..-1].map { |td| td.text.strip }
  reinforcement_value = tds[1].scan(/\d+/).map(&:to_i)
  scrap_income        = tds[2].scan(/\d+/).map(&:to_i)

  {
    base:                parse_stats_table(html.at("[title*='Base Stats']")),
    max:                 parse_stats_table(html.at("[title*='Level 100']")),
    max20:               parse_stats_table(html.at("[title*='Level 120']")),
    speed:               tds[0][/\d+/].to_i,
    reinforcement_value: [:firepower, :tropedo, :air_power, :reload].zip(reinforcement_value).to_h,
    scrap_income:        [:coin, :oil, :medal].zip(scrap_income).to_h
  }
end

def parse_stats_table(table)
  data = table.css("td").first(10).map do |td|
    text = td.text.strip
    text = text[/\d+/].to_i if text.match?(/\d/)
    text
  end

  keys = [
    :health, :armor, :reload, :firepower, :torpedo,
    :speed, :anti_air, :air_power, :oil_usage, :anti_sub
  ]

  keys.zip(data).to_h
end

def extract_equipment_data(html)
  table = html.css("table").detect { |table| table.at("th:contains('Equipment')") }
  equipment = table.css("tr")[-3..-1].map do |row|
    tds = row.css("td").drop(1).map { |td| td.text.strip }
    [:efficiency, :equippable].zip(tds).to_h
  end

  { equipment: equipment }
end

def extract_pictures(html)
  skins = html.css("div.shiparttabbernew .tabbertab").map do |tab|
    img_path = tab.at("img")["srcset"].split[-2]
    { name: tab["title"], url: build_url(img_path) }
  end

  {
    images: skins,
    icon:   (build_url(html.at("img")["src"]) rescue ""),
    chibi:  (build_url(html.at("#talkingchibi img")["src"]) rescue "")
  }
end

def extract_drop_locations(html)
  chapters = html.at(".nodesktop table").css("tr").drop(6)

  drop_locations = chapters.map.with_index do |row, chapter_index|
    stages        = row.css("td").map { |td| td["style"].include?("Green") }
    stage_indexes = stages.each_index.select { |i| stages[i] }
    stage_indexes.map { |i| "#{chapter_index + 1}-#{i + 1}" }
  end.flatten

  { drop_locations: drop_locations }
end

def parse_rarity(string)
  case string
  when "Rarity Normal.png" then "Normal"
  when "Rare.png"          then "Rare"
  when "Elite.png"         then "Elite"
  when "SuperRare.png"     then "Super Rare"
  when "Legendary.png"     then "Legendary"
  when "Priority.png"      then "Priority"
  else string
  end
end

data = all_fixtures_from("ships_long").map do |html|
  hash = { page_url: html.at("meta[property='og:url']")["content"] }

  html = html.at(".mw-parser-output")
  [
    hash,
    extract_names(html),
    extract_base_data(html),
    extract_stats(html),
    extract_equipment_data(html),
    extract_pictures(html),
    extract_drop_locations(html)
  ].reduce(:merge)
end.sort_by { |ship| ship[:id] }

write_json(data, "ships_long")
