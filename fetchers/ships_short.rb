require_relative "./shared"

html = fetch_html("https://azurlane.koumakan.jp/List_of_Ships")
write_fixture("ships_short", "list_of_ships", html)
