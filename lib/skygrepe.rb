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
      @count ||= db.execute(@condition.count_sql).flatten.first.to_i
      formatter = Formatter.new({"time_format" => @config["time_format"]})
      sql = @condition.grep_sql(@limit, @offset)
      rows = db.execute(sql).map{|row| formatter.format(row) }
      if @count <= @limit
        @quit = true
      end
      rows
    end

    def next(page = 1)
      @offset += (@limit * page)
    end

    def prev(page = 1)
      self.next( -1 * page)
    end

    def quit
      @quit = true
    end
  end

  class Condition
    def initialize(keyword)
      @keyword = keyword
    end

    def grep_sql(limit, offset)
      sql = "SELECT m.id, m.timestamp, c.displayname, m.author, substr(m.body_xml, 1, 50) FROM Messages as m inner join Conversations as c on m.convo_id = c.id"
      sql << " WHERE body_xml like '%#{@keyword}%'"
      sql << " ORDER BY m.timestamp"
      sql << " LIMIT #{limit} OFFSET #{offset}"
      sql << ';'
    end


    def count_sql
      sql = "SELECT count(*) FROM Messages"
      sql << " WHERE body_xml like '%#{@keyword}%'"
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
