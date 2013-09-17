require 'skygrepe'

module Skygrepe
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
end
