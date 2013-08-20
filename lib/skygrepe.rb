require "skygrepe/version"
require "sqlite3"

require "time"

class Skygrepe

  def initialize(config)
    @config = config
  end

  def run(keyword)
    db = Database.new(@config["main_db_path"])
    formatter = Formatter.new({"time_format" => @config["time_format"]})
    db.grep(keyword).map{|row| formatter.format(row) }
  end

  class Database
    def initialize(path)
      @impl ||= SQLite3::Database.new(path)
    end

    def grep(keyword)
      raise ArgumentError, "keyword is empty" if keyword.nil? || keyword.empty?
      sql = "SELECT m.id, m.timestamp, c.displayname, m.author, substr(m.body_xml, 1, 50) FROM Messages as m inner join Conversations as c on m.convo_id = c.id  WHERE body_xml like '%#{keyword}%';"
      @impl.execute(sql)
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
