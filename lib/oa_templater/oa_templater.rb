# encoding: UTF-8

require 'support/oa_regexes'
require 'support/formats'

require 'nkf'
require 'fileutils'
require 'date'
require 'sablon'
require 'yaml'
require 'csv'
require 'charlock_holmes'
require 'kakasi'

module OaTemplater
  class OA
    attr_accessor :outputfile
    attr_reader :props

    def initialize(sourcefile, casenumber = '11110')
      @sourcefile = sourcefile
      @casenumber = casenumber
      read_oa_data
      set_templates
      init_instance_vars
      set_reasons_file
      read_templatable_file #chunks of text for swapping
    end

    # require template files, not included because of NDA
    def set_templates(options = {})
      defaults = {  kyozetsuriyu: File.join(File.dirname(__FILE__), 'default_riyu.docx'),
                    shinpankyozetsuriyu: File.join(File.dirname(__FILE__), 'default_shinpankyozetsuriyu.docx'),
                    kyozetsusatei: File.join(File.dirname(__FILE__), 'default_satei.docx'),
                    shinnen: File.join(File.dirname(__FILE__), 'default_shinnen.docx'),
                    shireisho: File.join(File.dirname(__FILE__), 'default_shireisho.docx'),
                    rejectamendments: File.join(File.dirname(__FILE__), 'default_rejectamendments.docx'),
                    examiners: File.join(File.dirname(__FILE__), 'examiners.txt')
                  }
      @templates = defaults.merge(options)
      pick_template
    end

    # require reason file, not included because of NDA
    def set_reasons_file(r = File.join(File.dirname(__FILE__), 'reasons.yml'))
      @reasons = YAML.load_file(r)
    end

    # A bunch of set phrases that can be swapped out
    def read_templatable_file(r = File.join(File.dirname(__FILE__), 'support', 'templatable.yml'))
      @templatables = YAML.load_file(r)
    end

    def parse_appeal_drafted
      capture_the(:appeal_drafted, R_CAPTURE_APPEAL_DRAFTED)  # year/month/day
      return if @scrapes[:appeal_drafted].nil?

      set_prop(:appeal_drafted, format_date('%04u/%02u/%02u', @scrapes[:appeal_drafted]))
    end

    def parse_drafted
      capture_the(:drafted, R_CAPTURE_DRAFTED)  # year/month/day
      return if @scrapes[:drafted].nil?

      set_prop(:drafted, format_date('%04u/%02u/%02u', @scrapes[:drafted]))
    end

    def parse_mailing_date(demarker = '-')
      @outputfile = 'oa_template'
      capture_the(:mailing_date, R_CAPTURE_MAILING_DATE)
      return if @scrapes[:mailing_date].nil?

      @outputfile = "ALP#{@casenumber}#{demarker}#{@template_name}#{demarker}#{format_date('%04u%02u%02u', @scrapes[:mailing_date])}.docx"

      set_prop(:mailing_date, format_date('%04u/%02u/%02u', @scrapes[:mailing_date]))
    end

    def parse_satei_previous_oa
      capture_the(:satei_previous_oa, R_CAPTURE_PREVIOUS_OA)
      return if @scrapes[:satei_previous_oa].nil?

      set_prop(:satei_previous_oa, format_date('%04u/%02u/%02u', @scrapes[:satei_previous_oa]))

      # set "and Amendments"
      set_prop(:and_amendments, R_AND_AMENDMENTS =~ @data ? 'Remarks and Amendments' : 'Remarks')
      
      # set the reason
      # default
      set_prop(:satei_reasons, 'the reasons')
      r = @data.match(R_SATEI_REASONS)
      m = r.nil? ? '理由' : r[1].gsub!(/\s+/, '')
      set_prop(:satei_reasons, m == '理由' ? 'the reasons' : format_headers(m))
    end

    def parse_amendments_date
      capture_the(:amendments_date, R_CAPTURE_AMENDMENTS_DATE)
      return if @scrapes[:amendments_date].nil?

      set_prop(:amendments_date, format_date('%04u/%02u/%02u', @scrapes[:amendments_date]))
    end

    def parse_retroactive
      capture_the(:retroactive, R_CAPTURE_RETROACTIVE)
      return if @scrapes[:retroactive].nil?

      set_prop(:retroactive, format_date("\nFiling Date (Retroactive Date) \t%04u/%02u/%02u\n \n", @scrapes[:retroactive]))
    end

    def parse_appeal_no
      capture_the(:appeal_no, R_CAPTURE_APPEAL_NO)
      return if @scrapes[:appeal_no].nil?

      set_prop(:appeal_no, NKF.nkf('-m0Z1 -w', @scrapes[:appeal_no][1]) + '-' + NKF.nkf('-m0Z1 -w', @scrapes[:appeal_no][2]))
    end

    def parse_shireisho_app
      capture_the(:shireisho_num, R_CAPTURE_SHIREISHO_APP)
      return if @scrapes[:shireisho_num].nil?

      set_prop(:shireisho_num, NKF.nkf('-m0Z1 -w', @scrapes[:shireisho_num][1]) + '-' + NKF.nkf('-m0Z1 -w', @scrapes[:shireisho_num][2]))
    end

    def parse_shireisho_code
      capture_the(:scode, R_CAPTURE_SHIREISHO_CODE)
      return if @scrapes[:scode].nil?

      set_prop(:scode, NKF.nkf('-m0Z1 -w', @scrapes[:scode][1]) + ' ' + NKF.nkf('-m0Z1 -w', @scrapes[:scode][2]))
    end

    def parse_app_no
      capture_the(:app_no, R_CAPTURE_APP_NO)
      if @scrapes[:app_no].nil?
        #try for the appeal format if nothing came up
        capture_the(:app_no, R_CAPTURE_APPEAL_APP_NO)
      end
      return if @scrapes[:app_no].nil?

      set_prop(:app_no, NKF.nkf('-m0Z1 -w', @scrapes[:app_no][1]) + '-' + NKF.nkf('-m0Z1 -w', @scrapes[:app_no][2]))
    end

    # definitely need to fix this up later, haha
    def parse_examiner(do_examiner = false)
      capture_the(:taro, R_CAPTURE_TARO) # 1, 2 (codes are #3, 4)

      #if there was no normal appeal examiner, try an appeal examiner
      if @scrapes[:taro].nil?
        capture_the(:taro, R_CAPTURE_APPEAL_TARO)
      end

      return if @scrapes[:taro].nil?

      found = false

      if do_examiner
        last, first = @scrapes[:taro][1], @scrapes[:taro][2]

        CSV.foreach(@templates[:examiners]) do |r|
          if NKF.nkf('-m0Z1 -w', r[1]).eql? (' ' + last + ' ' + first)
            set_prop(:taro, r[0])
            found = true
            break
          end
        end

        unless found
          found = true
          first, last = Kakasi.kakasi('-Ja', first).capitalize, Kakasi.kakasi('-Ja', last).upcase

          # use kakashi to romajify the Examiner names
          set_prop(:taro, "#{first} #{last} #{@scrapes[:taro][1]} #{@scrapes[:taro][2]}")
        end
      end

      set_prop(:taro, @scrapes[:taro][1] + ' ' + @scrapes[:taro][2]) unless found

      # always set examiners numbers
      set_prop(:code, NKF.nkf('-m0Z1 -w', @scrapes[:taro][3]) + ' ' + NKF.nkf('-m0Z1 -w', @scrapes[:taro][4]))
    end

    def parse_appeal_examiner
      capture_the(:appeal_taro, R_CAPTURE_APPEAL_TARO) # 1, 2
      return if @scrapes[:appeal_taro].nil?

      set_prop(:appeal_taro, @scrapes[:appeal_taro][1] + ' ' + @scrapes[:appeal_taro][2])
    end

    def parse_final_oa
      set_prop(:reason_for_final, '')
      capture_the(:final_oa, /＜＜＜＜\p{Z}+最\p{Z}{0,6}後\p{Z}+＞＞＞＞/)
      return if @scrapes[:final_oa].nil?
      set_prop(:final_oa, "\n<<<<    FINAL    >>>>\n")
      set_prop(:reason_for_final, Sablon.content(:word_ml, FINALWML))
    end

    def parse_see_list
      set_prop(:see_list, /引用文献等については引用文献等一覧参照/ =~ @data ? "  \n(See the List of Citations for the cited publications)  \n" : '')
    end

    def parse_response_period
      set_prop(:response_period, R_RESPONSE_PERIOD =~ @data ? '60 days' : 'three months')
    end

    def parse_our_lawyer
      capture_the(:our_lawyer, /[特許出願人]*代理人[弁理士]*[弁護士]*\p{Zs}+(\S+?)\p{Zs}(\S+?)/)
      return if @scrapes[:our_lawyer].nil?

      # only check last name
      case @scrapes[:our_lawyer][1]
      when '村山'
        set_prop(:our_lawyer, 'Yasuhiko MURAYAMA')
      when '志賀'
        set_prop(:our_lawyer, 'Masatake SHIGA')
      when '佐伯'
        set_prop(:our_lawyer, 'Yoshifumi SAEKI')
      when '渡邊'
        set_prop(:our_lawyer, 'Takashi WATANABE')
      when '実広'
        set_prop(:our_lawyer, 'Shinya JITSUHIRO')
      when '棚井'
        set_prop(:our_lawyer, 'Sumio TANAI')
      else
        set_prop(:our_lawyer, 'Taro TOKKYO')
      end
    end

    def parse_note_to_applicant
      capture_the(:note_to_applicant, /本願出願時に公開されており、/)
      return if @scrapes[:note_to_applicant].nil?

      set_prop(:note_to_applicant, "\t• Request to the Applicant\r\n\tCitation 1 was already published at the time of filing of the present application and has a common applicant or inventor with the present application.  Citation 1 alone would be a bar to the novelty or inventive step of more than one claim of the present application.\r\n\tBased on this type of citation, appropriately evaluating the invention in advance can be thought to be beneficial to the applicant while creating appropriate claims, as well as helpful to the Examiner for an efficient and accurate examination.  We request that the applicant disclose this type of citation that the applicant is already aware of when filing the application or a request for examination, as well as requesting that the applicant evaluates whether or not the invention for which a patent is sought has patentability based on this type of citation. ")
    end

    def parse_currently_known
      case @data
      when /拒絶の理由を発見しない請求項/
        if m = @data.match(R_CAPTURE_NO_REJECT_CLAIMS)
          set_prop(:currently_known, "<Claims for which no reasons for rejection have been found>\r\n \tNo reasons for rejection are currently known for #{format_headers(m[1])}.  The applicant will be notified of new reasons for rejection if such reasons for rejection are found.")
        else
          set_prop(:currently_known, "<Claims for which no reasons for rejection have been found>\r\n \tNo reasons for rejection are currently known for the claims.  The applicant will be notified of new reasons for rejection if such reasons for rejection are found.")
        end
      when /拒絶の理由が通知される/
        set_prop(:currently_known, 'The applicant will be notified of new reasons for rejection if such reasons for rejection are found.')
      else
        set_prop(:currently_known, '')
      end
    end

    def parse_ipc
      ipc_text = ''

      if m = @data.match(/先行技術文献(?:等{0,1})調査結果(.*?)..先行技術文献/m)
        data = m[1]
        ipc_list_end = m.end(0)
        if m = data.match(/(Ｉ|I)(Ｐ|P)(Ｃ|C)/)
          data = data[m.begin(0)..-2]
          ipc_text = NKF.nkf('-m0Z1 -w', data).gsub('IPC', 'IPC:').gsub('DB名', "\tDB Name:").gsub('^\p{Z}{3,8}', "\t ")
          parse_ipc_references(ipc_list_end)
        end
      end

      set_prop(:ipc_list, ipc_text)
    end

    def parse_ipc_references(ipc_list_end)
      ipc_reference_text = ''
      data = @data[ipc_list_end..-1]

      if m = data.match(/(^.*先行技術文献調査結果|この拒絶理由通知の内容)/)
        @cits ||= YAML.load_file(CITATIONS_FILE)
        data = data[0..m.begin(0)]
        oldmatch = false
        count = 1

        data.each_line do |line|
          match = false
          @cits.each do |_n, a|
            if m = line.match(a['japanese'])
              match = true
              ipc_reference_text += "#{count}.  #{convert_pub_no(m, a['english'])}\n"
            end
          end # cits.each

          unless match
            # if no match, change 全角 to 半角
            line = NKF.nkf('-m0Z1 -w', line)

            # first line of non-match
            if oldmatch and (!match)
              line.gsub!(/^/, "#{count}. ") if line.length > 4
            end

            # >1st line of non-match
            if (!oldmatch) and (!match)
              count -= 1 #decrease count to that it stays the same after being increased below
              #remove newlines since it's probably a big english title
              ipc_reference_text.gsub!(/\r\n$/,"\n") if line.length > 4
            end

            line = pad_spaces(line)

            ipc_reference_text += line
          end

          # increase count
          count += 1

          oldmatch = match
        end
      end

      set_prop(:ipc_reference_text, ipc_reference_text)
    end

    def parse_headers(dh)
      oa_headers_text = ''

      if dh and m = @data.match(/(?:理\p{Z}{0,2}由.*^\p{Z}*先行技術文献調査結果の記録|理\p{Z}{0,2}由.*^－－－－－－－－－－－|\p{Z}記\p{Z}.*引\p{Z}?用\p{Z}?文\p{Z}?献\p{Z}?等\p{Z}?一\p{Z}?覧|\p{Z}記\p{Z}.*^－－－－－－－－－－－|理\p{Z}{0,2}由.*引\p{Z}?用\p{Z}?文\p{Z}?献\p{Z}?等\p{Z}?一\p{Z}?覧|理\p{Z}{0,2}由.*最後の拒絶理由通知とする理由|検討しましたが.*|\p{Z}理\p{Z}{0,2}由.*この通知に関するお問い合わせがございましたら)/mi)
        # gsub to strip HTML tags from japanese text
        tdata = @data[m.begin(0)..m.end(0)].gsub(%r{</?[^>]+?>}, '').gsub("\r\n", "\n")
        #
        # matches stuff like this
        # （理由１）
        # ＜請求項１－１１＞
        # ・引用文献１
        # 引用文献１
        # 引用文献：１
        # 備考

        line = ''
        until tdata.nil? do
          m = tdata.match(/^(.*?)\n/)
          break if m.nil?

          line = m[1] =~ /^\s*$/ ? "\n" : m[1] #save a newline if it's empty

          tdata = tdata[m.end(0)..-1]

          if res = check_for_templatable_portion(line, tdata)
            tex, tdata = res
            # added a match against unnecessary IPC lines
            oa_headers_text += tex
          elsif m = line.match(R_HEADER_TYPES)
            tex = m[1]

            oa_headers_text += tex =~ /^\s*$/ ? "\n" : format_headers(tex) + "\n" unless mistaken_header?(tex)
          end
        end

        oa_headers_text.gsub!("\n\n\n", "\n")
        oa_headers_text.gsub!("\n\n\n", "\n")
        oa_headers_text.gsub!("\n\n\n", "\n")

        oa_headers_text.encode!(:xml => :text)
        #replace OAOA_TEMPLATER_TAB with word_ml newline + tab
        oa_headers_text.gsub!(/OAOA_TEMPLATER_TAB/, STOPSTARTTAB) 
        #replace newlines with word_ml newlines
        oa_headers_text.gsub!(/\n/, STOPSTARTP) 


        set_prop(:oa_headers, Sablon.content(:word_ml, sprintf(HEADERS_FMT, oa_headers_text)))
      end
    end

    def check_for_templatable_portion(line, tdata)
      odata = [line, tdata].join.gsub("\n", '') #unshift the first line back to tdata
      @templatables.each do |t, a|
        if line =~ /^.{0,2}#{a['detect']}/
          if m = odata.match(/^.{0,2}#{a['full']}/)
            #this starting offset should actually be m.end(0) - line.length + (the number of newline characters up to the match)
            tdata = [line, "\n", tdata].join
            tdata = tdata[(m.end(0)+1) .. -1]  
            tex = odata[m.begin(0)..m.end(0)]
            tex.gsub!(a['full']) do 
              res = a['text']
              Regexp.last_match.captures.each_with_index do |match, i|
                if match =~ /^請求項[\p{N},～、－及びおよ]+$/
                  res = res.gsub(/\\#{i+1}/, format_headers(match))
                elsif match =~ /^請求項[\p{N},～、－及びおよ]+に係る発明$/
                  res = res.gsub(/\\#{i+1}/, format_invention_according_to(match))
                else
                  res = res.gsub(/\\#{i+1}/, NKF.nkf('-m0Z1 -w', match))
                end
              end
              res
            end
            return  [tex, tdata]
          end
        end
      end

      return nil
    end

    def format_invention_according_to(str)
      res = format_headers(str.gsub('に係る発明','').gsub('請求項', 'the invention according to 請求項'))
      res += res =~ /inventions/ ? ' are' : ' is'
    end

    #is_mistaken_header?
    def mistaken_header?(tex)
      val = false
      val = true if tex =~ /調査/ || /先行技術文/ =~ tex || /注意/ =~ tex and !(/検討しましたが/ =~ tex)
      val = true if (tex =~ /段/) || (tex =~/段/) || (tex =~ /には/) || (tex =~ /が/)
      val = true if (tex =~ /係る発明/) || (tex =~/明らか/)
      val
    end

    def parse_citations
      citation_text = ''

      if m = @data.match(R_CITATIONS_START)
        @cits ||= YAML.load_file(CITATIONS_FILE)
        count = 0
        data = @data[m.end(0) - 2..-1].gsub(%r{</?[^>]+?>}, '') # end minus '1.', gsub to remove html

        catch :done_scanning do
          data.each_line do |line|
            tex = line
            throw :done_scanning if (/^\s*$/ =~ line) || (line[0..2].eql?('－－－'))

            old_citation_text = citation_text
            if /^\p{Z}*\p{N}+((?:\.|．|：)+.*?)/m =~ tex
              count += 1
            end

            @cits.each do |_n, a|
              if m = tex.match(a['japanese'])
                count = 1 if count == 0
                wellknown_text = tex =~ /周知技術/ ? ' (Publication showing well-known technology)' : ''
                newlyadd_text = ((tex =~ /追加した文献）/) || (tex =~ /新たに引/)) ? ' (Newly added publication)' : ''
                if (/United States/ =~ a['english']) or (/United Kingdom/ =~ a['english'])
                  # citation is in English (no prime needed)
                  citation_text += sprintf(CIT_SIMPLE, count, convert_pub_no(m, a['english']) + newlyadd_text + wellknown_text)
                else # normal
                  if /Published Japanese Translation No./ =~ a['english']
                    citation_text += sprintf(CIT_WITH_PRIME_PCT, count, convert_pub_no(m, a['english']) + newlyadd_text + wellknown_text, count)
                  else
                    citation_text += sprintf(CIT_WITH_PRIME, count, convert_pub_no(m, a['english']) + newlyadd_text + wellknown_text, count)
                  end
                end
              end
            end # cits

            if old_citation_text == citation_text
              tex = NKF.nkf('-m0Z1 -w', tex)
              # strip blank dos lines
              tex.gsub!(/\p{Z}*\r\n/, '')
              tex = pad_spaces(tex)

              # if no match was found, just copy the japanese, skip first character (it's a period from the regex)
              # should have the correct number from the actual source (not from count variable)
              tex.encode!(:xml => :text) if tex
              citation_text += sprintf(CIT_MISS, tex)
            end
          end # each line
        end # catch
      end # if citations found

      set_prop(:citation_list, Sablon.content(:word_ml, citation_text))
    end

    def pad_spaces (tex)
      # add space after period, add space after comma, remove year kanji, reduce multiple spaces to 1
      tex.gsub!(/\.(\p{N})/, '. \1')
      tex.gsub!(/\,/, ', ')
      tex.gsub!(/年/, '')
      tex.gsub!(/p{Z}*/, ' ')
      tex.gsub!(/. ,/, '.,')
      tex
    end

    def convert_pub_no(m, eng)
      #m is MatchData object, handle different styles of citations
      #by using the number of captures
      case m.length
      when 2
        pub = (eng =~ /United States Patent No/) ? eng.gsub('CIT_NO', NKF.nkf('-m0Z1 -w', m[1]).to_i.commas) : (eng =~ /European Patent/ ? eng.gsub('CIT_NO', NKF.nkf('-m0Z1 -w', m[1]).to_i.eurostyle) : eng.gsub('CIT_NO', NKF.nkf('-m0Z1 -w', m[1])))
      when 3
        pub = eng.gsub('CIT_NO', (NKF.nkf('-m0Z1 -w', m[1]) + '/' + NKF.nkf('-m0Z1 -w', m[2])))
      when 4, 5
        pub = eng.gsub('CIT_NO', convert_possible_heisei(m[2], m[3], m[4]))
      when 9
        pub = eng.gsub(/CIT_NO /, convert_possible_heisei(m[2], m[3], m[4]) + ' ').gsub('CIT_NO2', convert_possible_heisei(m[6], m[7], m[8]))
      end

      pub
    end

    # matches /([昭|平]*)(\p{N}+?).(?:\p{Z}*)(\p{N}+?)号/
    # convert 平０９－０６０２７４ into H09-060274 or ２００８-００３７４９ into 2008-003748
    def convert_possible_heisei(hs, first, last)
      no = ''
      case hs
      when'平'
        no += 'H' + sprintf('%02u', NKF.nkf('-m0Z1 -w', first).to_i(10)) + '-' + NKF.nkf('-m0Z1 -w', last)
      when '昭'
        no += 'S' + sprintf('%02u', NKF.nkf('-m0Z1 -w', first).to_i(10)) + '-' + NKF.nkf('-m0Z1 -w', last)
      else
        no += NKF.nkf('-m0Z1 -w', first) + '-' + NKF.nkf('-m0Z1 -w', last)
      end

      no
    end

    def parse_articles
      count = 1
      articles_text = '<w:p><w:pPr><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r w:rsidR="006A661C"><w:rPr><w:b/><w:noProof/></w:rPr><w:t>Cited Articles:</w:t><w:tab/><w:tab/><w:tab/>'
      reasons_for_text = '<w:p><w:pPr><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r w:rsidR="006A661C"><w:rPr><w:noProof/></w:rPr>'

      found_articles = []
      original_length = articles_text.length

      m = @data.match(R_ARTICLE_SECTION)
      target_data = m ? m[0] : @data

      line_num = 0

      while (line = target_data.lines[line_num..line_num+1]) do
        #last line+1 will return nil
        if line
          line = line.join.gsub(/\r\n|\r|\n/,'') #merge 2 lines and remove newline
        else
          break
        end

        line_num += 1

        @reasons.each do |_r, a|
          if line =~ a['japanese']
            found_articles << a['short']

            unless /#{Regexp.quote(a["english"])}/m =~ reasons_for_text 
              reasons_for_text += "<w:t>#{count}.</w:t><w:tab/><w:t>#{a['english']}</w:t><w:br/><w:br/>"
              count += 1
            end
          end
        end
      end

      found_articles.uniq.sort.each do |a|
        # skip tab on first reason
        articles_text += "<w:tab/><w:tab/><w:tab/><w:tab/><w:tab/>" unless articles_text.length == original_length
        # only add short text once (36 shows up multiple times)
        articles_text += "<w:t>#{a}</w:t><w:br/>" 
      end

      # remove number if only 1 article listed
      reasons_for_text.gsub!(/<w:t>1.<\/w:t><w:tab\/><w:t>/, '<w:tab\/><w:t>') if count == 2

      #remove final word_ml newline
      reasons_for_text.gsub!(/<w:br\/><w:br\/>$/, '')
      articles_text.gsub!(/<w:br\/>$/, '')

      #close the paragraph
      articles_text += '</w:r></w:p>'
      reasons_for_text += '</w:r></w:p>'

      set_prop(:articles, Sablon.content(:word_ml, articles_text))
      set_prop(:reasons_for, Sablon.content(:word_ml, reasons_for_text))
    end

    def finish(options = {})
      defaults = {  sablon: true
                  }
      options = defaults.merge(options)

      stemplate = Sablon.template(@template)
      stemplate.render_to_file @outputfile, @props
    end

    def scan(options = {})
      defaults = {  do_headers: false,
                    do_dashes: 0,
                    do_examiner: false,
                    sablon: true
                  }
      options = defaults.merge(options)

      parse_mailing_date options[:do_dashes]
      parse_examiner options[:do_examiner]
      parse_app_no
      parse_drafted
      parse_our_lawyer
      parse_response_period
      parse_see_list
      parse_final_oa
      parse_amendments_date
      parse_satei_previous_oa
      parse_articles
      parse_currently_known
      parse_citations
      parse_ipc
      parse_appeal_examiner
      parse_appeal_drafted
      parse_appeal_no
      parse_retroactive
      parse_note_to_applicant
      parse_shireisho_app
      parse_shireisho_code

      parse_headers options[:do_headers]
    end

    private

    def squish!(t)
      t.gsub!(/\A[[:space:]]+/, '')
      t.gsub!(/[[:space:]]+\z/, '')
      t.gsub!(/[[:space:]]+/, ' ')
    end

    def format_headers(tex, options = {})
      defaults = {  replace_toh: false,
                    ignore_toh: true,
                    markdown: false
                  }
      options = defaults.merge(options)

      squish! tex

      # try to handle when Examiners put multiple groups separated by : or /
      # on the same line like 引用文献１：請求項１，２/ bla
      formatted_text = ''
      if R_HEADER_SEPARATOR_DETECT =~ tex
        # super fragile. If regex is changed
        # demarker = NKF.nkf('-m0Z1 -w', '#{$&[1,1]} ')
        demarker = NKF.nkf('-m0Z1 -w', "#{$1} ") #$~ is last matchdata
        tex.split(R_HEADER_SEPARATOR).each do |section|
          formatted_text += demarker unless formatted_text.length == 0

          if section =~ R_JPL_DETECT
            formatted_text += handle_jpl(section)
          else
            #no jpl to handle
            formatted_text += format_headers(section, options)
          end

        end
      else
        #handle special Reason lines
        if /#{R_HEADER_REASONS}/x =~ tex
          if /#{R_OYOBI}/ =~ tex
            tex.split(/#{R_OYOBI}/).each do |section|
              section = format_number_listing(section)

              formatted_text += ' and ' unless formatted_text.length == 0
              formatted_text += "#{replace_common_phrases(section, options)}".gsub('(', ' (') #add space before parenthasis
            end
          else
            if tex =~ R_JPL_DETECT
              formatted_text += handle_jpl(tex)
            else
              #no jpl to handle
              formatted_text = "#{replace_common_phrases(tex, options)}"
            end
          end
          formatted_text.gsub!('Reason(', 'Reason (')
          formatted_text.gsub!(/(\p{N})\(/, '\1 (')
        else
          if tex =~ R_JPL_DETECT
            #note : it cant get here
            formatted_text += handle_jpl(tex)
          else
            #no jpl to handle
            formatted_text = "#{replace_common_phrases(tex, options)}"
          end
        end
      end

      formatted_text
    end

    def replace_common_phrases(tex, options = {})
      defaults = {  replace_toh: false,
                    ignore_toh: true
      }
      options = defaults.merge(options)

      tex = NKF.nkf('-m0Z1 -w', tex)
      tex = swap_words(tex)
      tex.gsub!('等', '') if options[:ignore_toh]
      tex.gsub!('等', ', etc.') if options[:replace_toh]

      # strip abberant \r characters
      tex.gsub!("\r", '')

      tex = format_number_listing(tex)
    end

    def handle_jpl(tex)
      #comes in looking something like "（Ａ）理由１（特許法２９条１項３号）"
      jpl = ''
      tex = NKF.nkf('-m0Z1 -w', tex)
      jpl = tex.gsub(/(.*)特許法第?(\p{N}+)条第?(\p{N}+)項(?:第?(\p{N}+.*)号)*/){ 
        replace_common_phrases(format_number_listing($1)) + "Japanese Patent Law, Article #{$2}, Paragraph #{$3}, Number #{$4}"
      }
      jpl.gsub!(/, Number\p{Z}+\)(?:について)?$/, ')') #if it doesnt have a \4
      jpl.gsub!(')R', ') R')
      jpl.gsub!('Reason(', 'Reason (')
      jpl.gsub!(/(\p{N})\(/, '\1 (')
      jpl
    end

    #do actual swapping of japanese and english words
    def swap_words(tex)
      tex.gsub!('、', ',')
      tex.gsub!('，', ',')
      tex.gsub!('拡大先願', 'Lack of Novelty Due to Secret Prior Art')
      tex.gsub!('ないし', 'to')
      tex.gsub!('について', '')
      tex.gsub!('のいずれか', 'any one of')
      tex.gsub!('及び', ',')
      tex.gsub!('および', ',')
      tex.gsub!('進歩性', 'Inventive Step')
      tex.gsub!('新規事項', 'New Matter')
      tex.gsub!('実施可能要件', 'Enablement Requirements')
      tex.gsub!('産業上の利用可能性', 'Industrial Applicability')
      tex.gsub!('特許請求の範囲の記載に関する委任省令要件', 'Ministerial Ordinance Requirements Regarding Claims')
      tex.gsub!('発明の単一性', 'Unity of Invention')
      tex.gsub!('明確性', 'Clarity')
      tex.gsub!('サポート要件', 'Support Requirements')
      tex.gsub!('新規性', 'Novelty')
      tex.gsub!(/請\p{Z}*求\p{Z}*項/, 'Claim')
      tex.gsub!('引用文献', 'Citation')
      tex.gsub!(/引\p{Z}*用\p{Z}*例/, 'Citation')
      tex.gsub!(/実\p{Z}*施\p{Z}*例/, 'Example')
      tex.gsub!(/理\p{Z}*由/, 'Reason')
      tex.gsub!(/先\p{Z}*願/, 'Prior Application')
      tex.gsub!('－', 'to')
      tex.gsub!('-', 'to')
      tex.gsub!('～', 'to')
      tex.gsub!('乃至', 'to')
      tex.gsub!('理由', 'Reason')

      # match 備考:
      tex.gsub!('備考', 'Notes')

      tex
    end

    # formats a number listing assuming only one list in the string
    # one level up, format_headers breaks single lines into a plurality of these
    # ex: 請求項３，１７，３１，４５
    def format_number_listing(tex)
      tex = NKF.nkf('-m0Z1 -w', tex)

      # if no numbers (like 'Notes:') then do nothing
      if m = tex.match(/(?:...)(.*?)\p{N}/) # skip first two charcters in case it's something like '１．理由１，２について'
        # opening, numbers, close
        op = tex[0..m.end(1) - 1]
        num_start = m.end(1)
        m = tex.match(/\p{N}(?!.*\p{N})/)
        cl = tex[m.end(0)..-1]
        nums = tex[num_start..m.end(0) - 1]

        parsed = nums.split(/((?:～|-)*\p{N}+(?:to\p{N}+)*,*)/).reject(&:empty?)

        # change ['1to2,', '3'] to ['1', '2', '3']
        parsed.each_index do |el|
          if /to\p{N}/ =~ parsed[el]
            parts = parsed[el].split(/to/)
            if parts[0].to_i(10) == (parts[1].to_i(10) - 1)
              parsed[el] = parts[0] + ','
              parsed.insert(el + 1, parts[1])
            end
          end
        end

        if parsed.length > 1
          parsed.insert(-2, 'and')
          parsed[0].gsub!(',', '') if parsed.length == 3
        end

        tex = "#{op} #{parsed.join(' ')}#{cl}"

        if (parsed.length > 2) || (/\p{N}to\p{N}/ =~ tex)
          tex.gsub!('Claim', 'Claims')
          tex.gsub!('Citation', 'Citations')
          tex.gsub!('Example', 'Examples')
          tex.gsub!('Reason', 'Reasons')
          tex.gsub!('invention', 'inventions')
          tex.gsub!('Prior Application', 'Prior Applications')
        end
        tex.gsub!('to', ' to ')

        # remove extra spaces
        tex.gsub!(/\p{Z}+/, ' ')
      end

      # dont feel like trackign this bug down, cludge
      tex.gsub!('( ', ' (')

      tex
    end

    # the @props hash is passed to docx_templater gem
    def set_prop(prop, value)
      @props[prop] = value
    end

    def init_instance_vars
      @props = {}
      @scrapes = {}
      set_prop(:citaton_list, '')
      capture_the(:mailing_no, /発送番号\p{Z}+(\S+)/)
      capture_the(:ref_no, /整理番号\p{Z}+(\S+)/)
      capture_the(:ipc_list, /調査した分野$/)
      set_prop(:ipc_reference_text, '')
    end

    def read_oa_data
      # read in OA data
      begin
        @data = File.read(@sourcefile)
      rescue
        raise 'oa_templater_exception'
      end

      begin
        # convert detected encoding (usually SHIFT_JIS Japanese) to UTF-8
        detection = CharlockHolmes::EncodingDetector.detect(@data)
        @data = CharlockHolmes::Converter.convert @data, detection[:encoding], 'UTF-8'
      rescue
        raise 'oa_templater_exception'
      end
    end

    def capture_the(prop, reg, offset = 0)
      matches = @data.match(reg, offset)
      @scrapes[prop] = matches ? matches : nil
      set_prop(prop, matches ? matches[1] : '')
    end

    def format_date(format, date)
      #date is MatchData object with three captures, the first being Heisei year
      #convert from 全角文字 to normal ascii 
      return '' if date.nil?
      y = (NKF.nkf('-m0Z1 -w', date[1]).to_i + 1988).to_s
      m = (NKF.nkf('-m0Z1 -w', date[2]).to_i).to_s
      d = (NKF.nkf('-m0Z1 -w', date[3]).to_i).to_s
      sprintf(format, y, m, d)
    end

    def pick_template
      case @data
      when /審判請求の番.*不服.*特許出願の番号.*特願.*起案日.*審判長.*代理人弁理士/m
        @template = @templates[:shinpankyozetsuriyu]
        @template_name = '審判拒絶理由'
      when /<TITLE>拒絶理由通知書<\/TITLE>/i
        @template = @templates[:kyozetsuriyu]
        @template_name = '拒絶理由'
      when /<TITLE>補正の却下の決定<\/TITLE>/i
        @template = @templates[:rejectamendments]
        @template_name = '補正の却下の決定'
      when /<TITLE>拒絶査定<\/TITLE>/i
        @template = @templates[:kyozetsusatei]
        @template_name = '拒絶査定'
      when /<TITLE>審尋（審判官）<\/TITLE>/i
        @template = @templates[:shinnen]
        @template_name = '審尋'
      when /<TITLE>同一出願人による同日出願通知書<\/TITLE>/i
        @template = @templates[:shireisho]
        @template_name = '指令書'
      else
        # not satei or riyu, default to riyu
        @template = @templates[:kyozetsuriyu]
        @template_name = '拒絶理由'
      end
    end
  end
end
