require "rubygems"
require "bundler/setup"

Bundler.require(:default)


class SdkRelease
  attr_accessor :id, :title, :published_at, :contents

  def initialize(id:, title:)
    self.id = id
    self.title = title
    self.published_at = DateTime.parse(SdkRelease.parseTitle(title))
    self.contents = []
  end

  def to_feed_item
    {
      id: self.id,
      url: "https://cloud.google.com/sdk/docs/release-notes##{self.id}",
      title: self.title,
      content_html: self.content_html,
      date_published: self.date_published
    }
  end

  def content_html
    contents.map do |content|
      next if content.content.empty?

      content.to_html
    end.join
  end

  def date_published
    published_at.to_s
  end

  private

  def self.parseTitle(title)
    # ex.) 160.0.0 (2017-06-21)
    m = /(\d+\.\d+\.\d+) \((\d{4}-\d{1,2}-\d{1,2})/.match(title)
    m[2]
  end
end


html = $stdin.read
doc = Nokogiri.HTML(html)

releases = doc.css("article.devsite-article h2").map do |elem|
  release = SdkRelease.new(id: elem["id"], title: elem.content)

  loop do
    elem = elem.next_element
    break if elem.nil? || elem.name == "h2"

    release.contents << elem
  end

  release
end

feed = {
  version: "https://jsonfeed.org/version/1.1",
  title: "Google Cloud SDK Release Notes",
  home_page_url: "https://okonomi.github.io/google-cloud-sdk-release-notes-feed/",
  feed_url: "https://okonomi.github.io/google-cloud-sdk-release-notes-feed/feed.json",
  items: releases.map(&:to_feed_item)
}

puts feed.to_json
