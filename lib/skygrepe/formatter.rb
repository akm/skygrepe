require "skygrepe"

require 'cgi/util'
require "time"

module Skygrepe

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
