require "skygrepe/version"
require "sqlite3"

require "time"

module Skygrepe

  class Context
    def initialize(keyword, config)
      raise ArgumentError, "keyword is empty" if keyword.nil? || keyword.empty?
      @config = config
      @condition = Condition.new(keyword)
      @offset = 0
      @limit = 30
      @quit = false
    end

    def quit?
      @quit
    end

    def db
      @db ||= SQLite3::Database.new(@config["main_db_path"])
    end

    def run
      formatter = Formatter.new({"time_format" => @config["time_format"]})
      options = { limit: @limit, offset: @offset }
      sql = @condition.grep_sql(options)
      rows = db.execute(sql).map{|row| formatter.format(row) }
      @quit = true
      rows
    end
  end

  class Condition
    def initialize(keyword)
      @keyword = keyword
    end

    def grep_sql(options = {})
      options = {
        limit: 30,
        offset: 0,
      }
      sql = "SELECT m.id, m.timestamp, c.displayname, m.author, substr(m.body_xml, 1, 50) FROM Messages as m inner join Conversations as c on m.convo_id = c.id"
      sql << " WHERE body_xml like '%#{@keyword}%'"
      sql << " ORDER BY m.timestamp"
      sql << " LIMIT #{options[:limit]} OFFSET #{options[:offset]}"
      sql << ';'
    end
  end

  class Formatter
    def initialize(config)
      @time_format = config["time_format"] || "%Y-%m-%d %H:%M"
    end

    def format(row)
      row[1] = Time.at(row[1]).strftime(@time_format)
      row[4] = (row[4] || '').gsub(/[\n\r]/m, '')
      row
    end
  end
end
