#!/usr/bin/env ruby
# encoding: UTF-8

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'oa_templater')

require 'nkf'
require 'fileutils'
require 'date'
require 'docx_templater'
require 'yaml'

require 'oa_templater/oa_templater' unless defined? OaTemplater::OA

module OaTemplater
  CITATIONS_FILE = File.join(File.dirname(__FILE__), 'oa_templater', 'citations.yml')
end

class Bignum
  def commas
    to_s =~ /([^\.]*)(\..*)?/
    int, dec = Regexp.last_match[1].reverse, Regexp.last_match[2] ? Regexp.last_match[2] : ''
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end
end

class Float
  def commas
    to_s =~ /([^\.]*)(\..*)?/
    int, dec = Regexp.last_match[1].reverse, Regexp.last_match[2] ? Regexp.last_match[2] : ''
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end
end

class Fixnum
  def commas
    to_s =~ /([^\.]*)(\..*)?/
    int, dec = Regexp.last_match[1].reverse, Regexp.last_match[2] ? Regexp.last_match[2] : ''
    while int.gsub!(/(,|\.|^)(\d{3})(\d)/, '\1\2,\3')
    end
    int.reverse + dec
  end
end
