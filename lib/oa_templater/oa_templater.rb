#!/usr/bin/env ruby
# encoding: UTF-8

require "nkf"
require "fileutils"
require "date"
require "docx_templater"
require "yaml"
require "charlock_holmes"

module OaTemplater
  class OA
    attr_accessor :outputfile
    attr_reader :props

    def initialize(sourcefile, casenumber = "11110")
      @sourcefile = sourcefile
      @casenumber = casenumber
      read_oa_data
      set_templates
      init_instance_vars
      set_reasons_file
    end

    #require template files, not included because of NDA
    def set_templates(options = {})
      defaults = {  kyozetsuriyu: File.join(File.dirname(__FILE__), "default_riyu.docx"),
                    kyozetsusatei: File.join(File.dirname(__FILE__), "default_satei.docx"),
                    shinnen: File.join(File.dirname(__FILE__), "default_shinnen.docx")
                  }
      @templates = defaults.merge(options)
      pick_template
    end

    #require reason file, not included because of NDA
    def set_reasons_file(r = File.join(File.dirname(__FILE__), "reasons.yml"))
      @reasons = YAML.load_file(r)
    end

    def parse_appeal_drafted
      capture_the(:appeal_drafted, /作成日p{Z}+\p{Z}*(?:平成)*\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/)  #year/month/day
      return if @scrapes[:appeal_drafted].nil?

      set_prop(:appeal_drafted, format_date("%04u/%02u/%02u", @scrapes[:appeal_drafted]))
    end

    def parse_drafted
      capture_the(:drafted, /起案日\p{Z}+\p{Z}*(?:平成)*\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/)  #year/month/day
      return if @scrapes[:drafted].nil?

      set_prop(:drafted, format_date("%04u/%02u/%02u", @scrapes[:drafted]))
    end

    def parse_mailing_date
      capture_the(:mailing_date, /発送日\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/) 
      return if @scrapes[:mailing_date].nil?

      @outputfile = "ALP#{@casenumber}.#{@template_name}.#{format_date("%04u%02u%02u", @scrapes[:mailing_date])}.docx"

      set_prop(:mailing_date, format_date("%04u/%02u/%02u", @scrapes[:mailing_date]))
    end

    def parse_satei_previous_oa
      capture_the(:satei_previous_oa, /この出願については、\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)日付け拒絶理由通知書に記載/) 
      return if @scrapes[:satei_previous_oa].nil?

      set_prop(:satei_previous_oa, format_date("%04u/%02u/%02u", @scrapes[:satei_previous_oa]))

      #set "and Amendments"
      if @data =~ /なお、意見書.{0,4}?手続補正書の内容を検討しました/
        set_prop(:and_amendments, " and Amendments")
      else
        set_prop(:and_amendments, "")
      end
    end

    def parse_appeal_no
      capture_the(:appeal_no, /番号\p{Zs}*不服(\p{N}+)\S(\p{Zs}*\p{N}+)/) 
      return if @scrapes[:appeal_no].nil?

      set_prop(:appeal_no, NKF.nkf('-m0Z1 -w', @scrapes[:appeal_no][1]) + "-" + NKF.nkf('-m0Z1 -w', @scrapes[:appeal_no][2]))
    end

    def parse_app_no
      capture_the(:app_no, /特許出願の番号\p{Z}+特願(\p{N}+)\S(\p{N}+)/) 
      return if @scrapes[:app_no].nil?

      set_prop(:app_no, NKF.nkf('-m0Z1 -w', @scrapes[:app_no][1]) + "-" + NKF.nkf('-m0Z1 -w', @scrapes[:app_no][2]))
    end

    def parse_examiner
      capture_the(:taro, /特許庁審査官\p{Zs}+(\S+?)\p{Zs}(\S+?)\p{Zs}+(\p{N}+)\p{Zs}+(\S+)/) #1, 2 (codes are #3, 4)
      return if @scrapes[:taro].nil?

      set_prop(:taro, @scrapes[:taro][1] + " " + @scrapes[:taro][2])
      set_prop(:code, NKF.nkf('-m0Z1 -w', @scrapes[:taro][3]) + " " + NKF.nkf('-m0Z1 -w', @scrapes[:taro][4]))
    end

    def parse_appeal_examiner
      capture_the(:appeal_taro, /審判長(?:\p{Z}*)特許庁審判官\p{Z}+(\S+?)\p{Z}(\S+?)\p{Z}*$/) #1, 2
      return if @scrapes[:appeal_taro].nil?

      set_prop(:appeal_taro, @scrapes[:appeal_taro][1] + " " + @scrapes[:appeal_taro][2])
    end

    def parse_final_oa
      capture_the(:final_oa, /＜＜＜＜　　最　　後　　＞＞＞＞/)
      return if @scrapes[:final_oa].nil?
      set_prop(:final_oa, "\r\n<<<<    FINAL    >>>>\r\n \r\n")
    end

    def parse_see_list
      if @data.match(/引用文献等については引用文献等一覧参照/)
        set_prop(:see_list, "\r\n(See the List of Citations for the cited publications)\r\n \r\n")
      else
        set_prop(:see_list, "")
      end
    end

    def parse_our_lawyer
      capture_the(:our_lawyer, /[特許出願人]*代理人[弁理士]*[弁護士]*\p{Zs}+(\S+?)\p{Zs}(\S+?)/) 
      return if @scrapes[:our_lawyer].nil?

      #only check last name
      case @scrapes[:our_lawyer][1] 
      when "村山" 
        set_prop(:our_lawyer, "Yasuhiko MURAYAMA")
      when "志賀"
        set_prop(:our_lawyer, "Masatake SHIGA")
      when "佐伯"
        set_prop(:our_lawyer, "Yoshifumi SAEKI")
      when "棚井"
        set_prop(:our_lawyer, "Sumio TANAI")
      else
        set_prop(:our_lawyer, "Taro TOKYO")
      end
    end

    def parse_currently_known
      if @data =~ /＜拒絶の理由を発見しない請求項＞/
        set_prop(:currently_known, "<Claims for which no reasons for rejection have been found>\r\nNo reasons for rejection are currently known for the claims which were not indicated in this Notice of Reasons for Rejection.  The applicant will be notified of new reasons for rejection if such reasons for rejection are found.")
      else
        set_prop(:currently_known, "")
      end
    end

    def parse_ipc
      ipc_text = ""

      if m = @data.match(/先行技術文献(?:等{0,1})調査結果(.*?)..先行技術文献/m)
        data = m[1]
        ipc_list_end = m.end(0)
        if m = data.match(/(Ｉ|I)(Ｐ|P)(Ｃ|C)/)
          data = data[m.begin(0)..-2] 
          ipc_text = NKF.nkf('-m0Z1 -w', data).gsub('IPC', 'IPC:')
          ipc_text = NKF.nkf('-m0Z1 -w', ipc_text).gsub('DB名', 'DB Name:')
          ipc_text = NKF.nkf('-m0Z1 -w', ipc_text).gsub('^\p{Z}{3,8}', "\t ")
          parse_ipc_references(ipc_list_end)
        end
      end

      set_prop(:ipc_list, ipc_text)
    end

    def parse_ipc_references(ipc_list_end)
      ipc_reference_text = ""
      data = @data[ipc_list_end..-1]

      if m = data.match(/^.*先行技術文献調査結果/)
        @cits ||= YAML.load_file(CITATIONS_FILE)
        data = data[0..m.begin(0)]
        oldmatch = false
        count = 1

        data.each_line do |line|
          match = false
          @cits.each do |n,a|
            if m = line.match(a['japanese'])
              match = true
              ipc_reference_text += "#{count}.  #{convert_pub_no(m, a["english"])}\r\n"
            end
          end #cits.each
            
          #increase count
          count += 1

          if !match
            #if no match, change 全角 to 半角 
            line = NKF.nkf('-m0Z1 -w', line)

            #first line of non-match
            if oldmatch and (!match)
              line.gsub(/^/, "#{count}. ")
            end

            # >1st line of non-match
            if (!oldmatch) and (!match)
              count -= 1
            end

            ipc_reference_text += line 
          end

          oldmatch = match
        end
      end

      set_prop(:ipc_reference_text, ipc_reference_text)
    end

    def parse_citations
      citation_text = ""

      if m = @data.match(/(引　用　文　献　等　一　覧|引用文献)\s+\p{N}+?(?:\.|．)/)
        @cits ||= YAML.load_file(CITATIONS_FILE)
        count = 0
        data = @data[m.end(0)-2..-1] #end minus "1."

        catch :done_scanning do 
          data.scan(/\p{N}+((?:\.|．).*?)(?:(?:\p{N}+(?:\.|．))|(?:$)|(?:－－－+))/m) do |line|
            tex = line[0]
            throw :done_scanning if line[0][0..1].eql?("\r\n") or line[0][0..2].eql?("－－－")

            count += 1

            old_citation_text = citation_text
            @cits.each do |n,a|
              if m = tex.match(a['japanese'])
                citation_text += "#{count}.  #{convert_pub_no(m, a["english"])}\r\n[#{count}'.  ]\r\n"
              end
            end #cits

            #if no match was found, just copy the japanese, skip first character (it's a period from the regex)
            citation_text += "#{count}.  #{NKF.nkf('-m0Z1 -w', line[0][1..-1])}" if old_citation_text == citation_text
          end
        end
      end

      set_prop(:citation_list, citation_text)
    end

    def convert_pub_no(m, eng)
      if m.length == 2
        pub = eng.gsub('CIT_NO', NKF.nkf('-m0Z1 -w',m[1]))
      elsif m.length == 3
        pub = eng.gsub('CIT_NO', (NKF.nkf('-m0Z1 -w',m[1]) + "/" + NKF.nkf('-m0Z1 -w',m[2])))
      elsif m.length == 4 or m.length == 5
        pub_no = ""
        if m[2] == "平"
          pub_no += 'H' + sprintf("%02u", NKF.nkf('-m0Z1 -w',m[3]).to_i(10)) + "-" + NKF.nkf('-m0Z1 -w',m[4])
        elsif m[2] == "昭"
          pub_no += 'S' + sprintf("%02u", NKF.nkf('-m0Z1 -w',m[3]).to_i(10)) + "-" + NKF.nkf('-m0Z1 -w',m[4])
        else
          pub_no += NKF.nkf('-m0Z1 -w',m[3]) + "-" + NKF.nkf('-m0Z1 -w',m[4])
        end
        pub = eng.gsub('CIT_NO', pub_no)
      end

      pub
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

      set_prop(:articles, articles_text)
      set_prop(:reasons_for, reasons_for_text.length > 3 ? reasons_for_text[0..-2] : reasons_for_text)
    end

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
      parse_appeal_examiner
      parse_appeal_drafted
      parse_appeal_no

      @buffer = @doc.replace_file_with_content(@template, @props)
      return @buffer
    end

    private

    #the @props hash is passed to docx_templater gem
    def set_prop(prop, value)
      @props[prop] = value 
    end

    def init_instance_vars
      @doc = DocxTemplater.new
      @props = Hash.new
      @scrapes = Hash.new
      @props[:citaton_list] = ""
      capture_the(:mailing_no, /発送番号\p{Z}+(\S+)/)
      capture_the(:ref_no, /整理番号\p{Z}+(\S+)/)
      capture_the(:ipc_list, /調査した分野$/)
      set_prop(:ipc_reference_text, "")
    end

    def read_oa_data
      #read in OA data
      @data = File.read(@sourcefile)
      
      #convert detected encoding (usually SHIFT_JIS Japanese) to UTF-8
      detection = CharlockHolmes::EncodingDetector.detect(@data)
      @data = CharlockHolmes::Converter.convert @data, detection[:encoding], 'UTF-8'
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
      if @data.match(/<TITLE>拒絶理由通知書<\/TITLE>/i)
        @template = @templates[:kyozetsuriyu]
        @template_name = "拒絶理由"
      elsif @data.match(/<TITLE>拒絶査定<\/TITLE>/i)
        @template = @templates[:kyozetsusatei]
        @template_name = "拒絶査定"
      elsif @data.match(/<TITLE>審尋（審判官）<\/TITLE>/i)
        @template = @templates[:shinnen]
        @template_name = "審尋"
      else
        #not satei or riyu, default to riyu
        @template = @templates[:kyozetsuriyu]
        @template_name = "拒絶理由"
      end
    end
  end
end

