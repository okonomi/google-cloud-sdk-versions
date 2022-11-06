require "rubygems"
require "bundler/setup"

Bundler.require(:default)


page_count = ARGV[0].to_i
page = ARGV[1].to_i
next_page = page + 1

json = $stdin.read

feed = JSON.parse(json, symbolize_names: true)
feed[:items] = feed[:items].slice(30 * page, 30)
if next_page < page_count
  feed[:next_url] = "https://okonomi.github.io/google-cloud-sdk-release-notes-feed/feeds/#{next_page}.json"
end

puts feed.to_json
