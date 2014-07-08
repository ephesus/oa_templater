#!/usr/bin/env ruby
# encoding: UTF-8

$:.unshift File.join(File.dirname(__FILE__), "oa_templater")

require "nkf"
require "fileutils"
require "date"
require "docx_templater"
require "yaml"

require "oa_templater/oa_templater" unless defined? OaTemplater::OA

module OaTemplater
    CITATIONS_FILE = File.join(File.dirname(__FILE__), "oa_templater", "citations.yml")
end

