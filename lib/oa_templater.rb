#!/usr/bin/env ruby
# encoding: UTF-8

require "iconv"
require "nkf"
require "fileutils"
require "date"
require "docx_templater"
require "yaml"

class OaTemplater
	attr_accessor :outputfile
  attr_reader :props

  CITATIONS_FILE = File.join(File.dirname(__FILE__), "citations.yml")

	def initialize(sourcefile, casenumber = "11110")
    @sourcefile = sourcefile
    @casenumber = casenumber
    read_oa_data
    init_instance_vars
	end

  #require template files, not included because of NDA
  def set_templates(r, s)
    @kyozetsuriyu_template = r
    @kyozetsusatei_template = s
    pick_template
  end

  #require reason file, not included because of NDA
  def set_reasons_file(r)
    @reasons_file = r
    @reasons = YAML.load_file(@reasons_file)
  end

	def finish
		@buffer = @doc.replace_file_with_content(@template, @props)
		File.open(@outputfile, 'wb') { |f| f.write(@buffer.string) }
	end

  def parse_drafted
    capture_the(:drafted, /起案日\p{Z}+\p{Z}*(?:平成)*\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/)  #year/month/day
    return if @scrapes[:drafted].nil?

    @props[:drafted] = format_date("%04u/%02u/%02u", @scrapes[:drafted])
  end

  def parse_mailing_date
    capture_the(:mailing_date, /発送日\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/) 
    return if @scrapes[:mailing_date].nil?

    @outputfile = "#{Dir.pwd}/ALP#{@casenumber}.#{@template_name}.#{format_date("%04u%02u%02u", @scrapes[:mailing_date])}.docx"

    @props[:mailing_date] = format_date("%04u/%02u/%02u", @scrapes[:mailing_date])
    
  end

  def parse_satei_previous_oa
    capture_the(:satei_previous_oa, /この出願については、\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)日付け拒絶理由通知書に記載/) 
    return if @scrapes[:satei_previous_oa].nil?

    @props[:satei_previous_oa] = format_date("%04u/%02u/%02u", @scrapes[:satei_previous_oa])

    #set "and Amendments"
    if @data =~ /なお、意見書及び手続補正書の内容を検討しましたが/
      @props[:and_amendments] = "and Amendments"
    else
      @props[:and_amendments] = ""
    end
  end


  def parse_app_no
    capture_the(:app_no, /特許出願の番号\p{Z}+特願(\p{N}+)\S(\p{N}+)/) 
    return if @scrapes[:app_no].nil?

    @props[:app_no] = NKF.nkf('-m0Z1 -w', @scrapes[:app_no][1]) + "-" + NKF.nkf('-m0Z1 -w', @scrapes[:app_no][2])
  end


  def parse_examiner
    capture_the(:taro, /特許庁審査官\p{Zs}+(\S+?)\p{Zs}(\S+?)\p{Zs}+(\p{N}+)\p{Zs}+(\S+)/) #1, 2
    capture_the(:code, /特許庁審査官\p{Zs}+(\S+?)\p{Zs}(\S+?)\p{Zs}+(\p{N}+)\p{Zs}+(\S+)/) #3, 4
    return if @scrapes[:taro].nil?

    @props[:taro] = @scrapes[:taro][1] + " " + @scrapes[:taro][2]
    @props[:code] = NKF.nkf('-m0Z1 -w', @scrapes[:taro][3]) + " " + NKF.nkf('-m0Z1 -w', @scrapes[:taro][4])
  end

  def parse_final_oa
    capture_the(:final_oa, /＜＜＜＜　　最　　後　　＞＞＞＞/)
    return if @scrapes[:final_oa].nil?
    @props[:final_oa] = "\r\n<<<<    FINAL    >>>>\r\n \r\n"
  end

  def parse_see_list
    if @data.match(/引用文献等については引用文献等一覧参照/)
      @props[:see_list] = "\r\n(See the List of Citations for the cited publications)\r\n \r\n"
    else
      @props[:see_list] = ""
    end
  end

  def parse_our_lawyer
    capture_the(:our_lawyer, /[特許出願人]*代理人\p{Zs}+(\S+?)\p{Zs}(\S+?)（/) 
    return if @scrapes[:our_lawyer].nil?

    #only check last name
    case @scrapes[:our_lawyer][1] 
    when "村山" 
      @props[:our_lawyer] = "Yasuhiko MURAYAMA"
    when "志賀"
      @props[:our_lawyer] = "Masatake SHIGA"
    when "佐伯"
      @props[:our_lawyer] = "Yoshifumi SAEKI"
    else
      @props[:our_lawyer] = "Taro TOKYO"
    end
  end

  def parse_currently_known
    if @data =~ /＜拒絶の理由を発見しない請求項＞/
      @props[:currently_known] = "<Claims for which no reasons for rejection have been found>\r\nNo reasons for rejection are currently known for the claims which were not indicated in this Notice of Reasons for Rejection.  The applicant will be notified of new reasons for rejection if such reasons for rejection are found."
    else
      @props[:currently_known] = ""
    end
  end

  def parse_ipc
    ipc_text = ""

    if m = @data.match(/先行技術文献(?:等{0,1})調査結果(.*?)..先行技術文献/m)
      data = m[1]
      if m = data.match(/(Ｉ|I)(Ｐ|P)(Ｃ|C)/)
        data = data[m.begin(0)..-2] 
        ipc_text = NKF.nkf('-m0Z1 -w', data).gsub('IPC', 'IPC:')
      end
    end

    @props[:ipc_list] = ipc_text
  end

  def parse_references

    ref_text = ""

    if m = @data.match(/先行技術文献(?:等{0,1})調査結果.*?先行技術文献(.*?)先行技術文献調査結果/m)
      data = m[1]
      if m = data.match(//)
        data = data[m.begin(0)..-2] 
      end
    end

    @props[:ref_list] = ref_text
  end

  def parse_citations
    citation_text = ""

    if m = @data.match(/(引　用　文　献　等　一　覧|引用文献)\s+\p{N}+?(?:\.|．)/)
      cits ||= YAML.load_file(CITATIONS_FILE)
      count = 0
      data = @data[m.end(0)-2..-1] #end minus "1."

      catch :done_scanning do 
        data.scan(/\p{N}+((?:\.|．).*?)(?:(?:\p{N}+(?:\.|．))|(?:$)|(?:－－－+))/m) do |line|
          tex = line[0]
          throw :done_scanning if line[0][0..1].eql?("\r\n") or line[0][0..2].eql?("－－－")

          count += 1

          old_citation_text = citation_text
          cits.each do |n,a|
            if m = tex.match(a['japanese'])
              if m.length == 2
                pub = a["english"].gsub('CIT_NO', NKF.nkf('-m0Z1 -w',m[1]))
              elsif m.length == 3
                pub = a["english"].gsub('CIT_NO', (NKF.nkf('-m0Z1 -w',m[1]) + "/" + NKF.nkf('-m0Z1 -w',m[2])))
              elsif m.length == 4 or m.length == 5
                pub_no = ""
                if m[2] == "平"
                  pub_no += 'H' + sprintf("%02u", NKF.nkf('-m0Z1 -w',m[3])) + "-" + NKF.nkf('-m0Z1 -w',m[4])
                elsif m[2] == "昭"
                  pub_no += 'S' + sprintf("%02u", NKF.nkf('-m0Z1 -w',m[3])) + "-" + NKF.nkf('-m0Z1 -w',m[4])
                else
                  pub_no += NKF.nkf('-m0Z1 -w',m[3]) + "-" + NKF.nkf('-m0Z1 -w',m[4])
                end
                pub = a["english"].gsub('CIT_NO', pub_no)
              end

              citation_text += "#{count}'.  #{pub}\r\n[#{count}'.  ]\r\n"
            end
          end #cits
            
            #if no match was found, just copy the japanese, skip first character (it's a period from the regex)
            citation_text += "#{count}'.  #{line[0][1..-1]}" if old_citation_text == citation_text
        end
      end
    end

    @props[:citation_list] = citation_text
  end

  def parse_articles
    data = @data
    count = 1
    articles_text = ""
    reasons_for_text = ""

    @reasons.each do |r,a|
      if data =~ /#{a['japanese']}.*?理　由/m
        #skip tab on first reason
        articles_text += "\t" unless articles_text.length < 1
        #only add short text once
        articles_text += a["short"] + "\r\n" unless articles_text.match(/#{a["short"]}/)

        reasons_for_text += "#{count}.\t#{a['english']}\r\n\r\n"
        count += 1
      end
    end

    @props[:articles] = articles_text
    @props[:reasons_for] = reasons_for_text.length > 3 ? reasons_for_text[0..-2] : reasons_for_text
  end

  #the @props hash is passed to 
  def set_prop(prop, value)
    @props[prop] = value 
  end

  private

  def init_instance_vars
		@doc = DocxTemplater.new
    @props = Hash.new
    @scrapes = Hash.new
    @props[:citaton_list] = ""
    capture_the(:mailing_no, /発送番号\p{Z}+(\S+)/)
    capture_the(:ref_no, /整理番号\p{Z}+(\S+)/)
    capture_the(:ipc_list, /調査した分野$/)
  end

  def read_oa_data
    #read in OA data
    @datafile = File.open(@sourcefile, "r")
    
    #convert SHIFT_JIS encoded HTML file (Japanese) to UTF-8
    @data = Iconv.iconv("UTF-8","SHIFT_JIS",@datafile.read).join
    @datafile.close
  end

  def capture_the(prop, reg, offset = 0)
    matches = @data.match(reg, offset)
    @scrapes[prop] = matches ? matches : nil
    @props[prop] = matches ? matches[1] : ""
  end

  def format_date(format, date)
    y = (NKF.nkf('-m0Z1 -w',date[1]).to_i + 1988).to_s
    m = (NKF.nkf('-m0Z1 -w',date[2]).to_i).to_s 
    d = (NKF.nkf('-m0Z1 -w',date[3]).to_i).to_s 
    return sprintf(format, y, m, d)
  end

  def pick_template
    if @kyozetsusatei_template.nil? or @kyozetsuriyu_template.nil?
      puts "templates required"
      exit
    end

    if @data.match(/<TITLE>拒絶理由通知書<\/TITLE>/)
      @template = @kyozetsuriyu_template
      @template_name = "拒絶理由"
    elsif @data.match(/<TITLE>拒絶査定<\/TITLE>/)
      @template = @kyozetsusatei_template
      @template_name = "拒絶査定"
    else
      #not satei or riyu, default to riyu
      @template = @kyozetsuriyu_template
      @template_name = "拒絶理由"
    end
  end
end

