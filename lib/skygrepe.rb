require "skygrepe/version"
require "sqlite3"

module Skygrepe

  class << self
    def database
      user = ENV['SKYPE_USER']
      raise "$SKYPE_USER is required" unless user
      @database ||= SQLite3::Database.new("#{ENV['HOME']}/Library/Application\ Support/Skype/#{user}/main.db")
    end

    def grep(keyword)
      sql = "SELECT m.timestamp, c.displayname, m.author, m.body_xml FROM Messages as m inner join Conversations as c on m.convo_id = c.id  WHERE body_xml like '%#{keyword}%';"
      rows = database.execute(sql)
    end
  end
end
