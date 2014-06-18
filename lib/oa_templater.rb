#!/usr/bin/env ruby
# encoding: UTF-8

$:.unshift File.join(File.dirname(__FILE__), "oa_templater")

require "nkf"
require "fileutils"
require "date"
require "docx_templater"
require "yaml"

require "oa_templater/oa_templater" unless defined? OaTemplater

module OaTemplater
    CITATIONS_FILE = File.join(File.dirname(__FILE__), "oa_templater", "citations.yml")

    def finish
      File.open(@outputfile, 'wb') { |f| f.write(@buffer.string) }
    end

    def scan
      parse_mailing_date
      parse_examiner
      parse_app_no
      parse_drafted
      parse_our_lawyer
      parse_see_list
      parse_final_oa
      parse_satei_previous_oa
      parse_articles
      parse_currently_known
      parse_citations
      parse_ipc

      @buffer = @doc.replace_file_with_content(@template, @props)
      return @buffer
    end
end

