require "skygrepe/version"
require "sqlite3"
require 'cgi/util'

require "time"

module Skygrepe

  class Context
    attr_reader :count, :limit, :current_id

    def initialize(keyword, config)
      raise ArgumentError, "keyword is empty" if keyword.nil? || keyword.empty?
      @keyword = keyword
      @config = config
      @condition = Condition.new(@keyword)
      @offset = 0
      @limit = 30
      @quit = false
      @current_id = nil
    end

    def quit?
      @quit
    end

    def db
      @db ||= SQLite3::Database.new(@config["main_db_path"])
    end

    def formatter
      @formatter ||= Formatter.new(@keyword, {"time_format" => @config["time_format"]})
    end

    def run
      @count ||= db.execute(@condition.count_sql).flatten.first.to_i
      sql = @condition.grep_sql(@limit, @offset)
      rows = db.execute(sql).map{|row| formatter.list(row) }
      unless rows.empty?
        @current_id = rows.first.first.to_i
      end
      # if @count <= @limit
      #   @quit = true
      # end
      rows
    end

    def next_page(page = 1)
      @offset += (@limit * page)
    end

    def prev_page(page = 1)
      self.next_page( -1 * page)
    end

    def detail(id)
      sql = "SELECT m.id, m.timestamp, c.displayname, m.author, m.body_xml FROM Messages as m inner join Conversations as c on m.convo_id = c.id"
      sql << " WHERE m.id = #{id}"
      if d = db.execute(sql).first
        @current_id = d.first.to_i
        formatter.detail(d)
      else
        nil
      end
    end

    def next_detail(d = 1)
      detail(@current_id + d)
    end

    def prev_detail(d = 1)
      self.next_detail( -1 * d)
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
    def initialize(keyword, config)
      @keyword = keyword
      @time_format = config["time_format"] || "%Y-%m-%d %H:%M"
    end

    def list(row)
      row[1] = Time.at(row[1]).strftime(@time_format)
      row[4] = format_message(row[4] || '').gsub(/[\n\r]/m, '')
      row
    end

    def detail(row)
      row[1] = Time.at(row[1]).strftime(@time_format)
      row[4] = format_message(row[4] || '')
      row
    end

    def format_message(msg)
      CGI.unescape_html(msg || '').gsub(/(#{Regexp.escape(@keyword)})/i){ "\e[32m#{$1}\e[0m" }
    end
  end
end
