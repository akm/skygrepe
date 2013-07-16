require "skygrepe/version"
require "sqlite3"

module Skygrepe

  class Database
    def initialize(path)
      @impl ||= SQLite3::Database.new(path)
    end

    def grep(keyword)
      sql = "SELECT m.timestamp, c.displayname, m.author, m.body_xml FROM Messages as m inner join Conversations as c on m.convo_id = c.id  WHERE body_xml like '%#{keyword}%';"
      rows = @impl.execute(sql)
    end
  end
end
