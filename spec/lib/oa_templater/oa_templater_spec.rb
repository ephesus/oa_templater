# encoding: UTF-8

require "spec_helper"

describe OaTemplater do
  #instead of factory girl or whatever, just open up actual OA files
  let(:oas) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_satei.htm"), 66666) }
  let(:oa1) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_oa1.htm"), 66666) }
  let(:oa2) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_oa2.htm"), 66666) }
  let(:oa3) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_oa3.htm"), 66666) }
  let(:oa4) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_oa4.htm"), 66666) }
  let(:oa5) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), "test_oa5.htm"), 66666) }

  context "#new" do
    #fail fast on catastrphic error
    it "expects not nil" do
      expect(oa1).not_to be_nil
    end

    it "should be an instance of OaTemplater" do
      expect(oa1).to be_an_instance_of OaTemplater::OA
    end

    #do some very high level checks that nothing is super-broken
    it "captures ref_no" do
      oa1.parse_drafted
      expect(oa1.props[:ref_no]).to eql("J64754A1")
    end

    it "captures blank ref_no" do
      oa5.parse_drafted
      expect(oa5.props[:ref_no]).to eql("")
    end

    it "captures mailing_no" do
      oa1.parse_drafted
      expect(oa1.props[:mailing_no]).to eql("220540")
    end
  end


  context "#parse_drafted" do
    it "captures drafted date" do
      oa1.parse_drafted
      expect(oa1.props[:drafted]).to eql("2014/04/10")
    end
  end

  context "#mailing_date" do
    it "captures mailing_date" do
      oa1.parse_mailing_date
      expect(oa1.props[:mailing_date]).to eql("2014/04/15")
    end

    it "sets the outputfile" do
      oa1.parse_mailing_date
      expect(oa1.outputfile).to eql("ALP66666.拒絶理由.20140415.docx")
    end

    it "sets the outputfile" do
      oa5.parse_mailing_date
      expect(oa5.outputfile).to eql("ALP66666.拒絶理由.20140520.docx")
    end
  end

  context "#examiner" do
    it "captures examiner" do
      oa1.parse_examiner
      expect(oa1.props[:taro]).to eql("岡▲崎▼ 忠")
    end

    it "captures examiner code" do
      oa1.parse_examiner
      expect(oa1.props[:code]).to eql("4515 4J00")
    end
  end

  context "#app_no" do
    it "captures app_no" do
      oa1.parse_app_no
      expect(oa1.props[:app_no]).to eql("2010-288649")
    end
  end

  context "#drafted" do
    it "captures drafted" do
      oa1.parse_drafted
      expect(oa1.props[:drafted]).to eql("2014/04/10")
    end
  end

  context "#our_lawyer" do
    it "captures our_lawyer" do
      oa1.parse_our_lawyer
      expect(oa1.props[:our_lawyer]).to eql("Masatake SHIGA")
    end

    it "captures our_lawyer 村山" do
      oa2.parse_our_lawyer
      expect(oa2.props[:our_lawyer]).to eql("Yasuhiko MURAYAMA")
    end
  end

  context "#see_list" do
    it "captures see_list" do
      oa1.parse_see_list
      expect(oa1.props[:see_list]).to eql("\n(See the List of Citations for the cited publications)\n \n")
    end

    it "captures no see_list" do
      oa5.parse_see_list
      expect(oa5.props[:see_list]).to eql("")
    end
  end

  context "#final_oa" do
    it "captures no final_oa" do
      oa1.parse_final_oa
      expect(oa1.props[:final_oa]).to eql("")
    end

    it "captures final_oa" do
      oa5.parse_final_oa
      expect(oa5.props[:final_oa]).to eql("\n<<<<    FINAL    >>>>\n \n")
    end
  end

  context "#satei_previous_oa" do
    it "captures satei_previous_oa" do
      oas.parse_satei_previous_oa
      expect(oas.props[:satei_previous_oa]).to eql("2013/06/24")
    end

    it "captures no satei_previous_oa" do
      oa1.parse_satei_previous_oa
      expect(oa1.props[:satei_previous_oa]).to eql("")
    end
  end

  context "#articles" do
    it "captures articles" do
      oa1.set_reasons_file("/home/ephesus/code/reader/templates/reasons.yml")
      oa1.parse_articles
      expect(oa1.props[:articles]).to eql("Article 29, Paragraph 1\n\tArticle 29, Paragraph 2\n")
    end
  end

  context "#currently_known" do
    it "captures no currently_known" do
      oa1.parse_currently_known
      expect(oa1.props[:currently_known]).to eql("")
    end
  end

  context "#parse_citations" do
    it "reads citations, general check 1" do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n\n")
    end

    it "reads citations, general check 2" do
      oa2.parse_citations
      expect(oa2.props[:citation_list]).to eql("1.  West German Patent Application Publication No. 3411062\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. S53-15437\n[2'.  ]\n3.  Japanese Unexamined Patent Application, First Publication No. 2000-7532\n[3'.  ]\n4.  Published Japanese Translation No. 2002-505360 of the PCT International Publication\n[4'.  ]\n5.  Japanese Unexamined Patent Application, First Publication No. H08-12538\n[5'.  ]\n6.  Japanese Unexamined Patent Application, First Publication No. 2006-124391\n[6'.  ]\n7.  Published Japanese Translation No. 2002-517427 of the PCT International Publication\n[7'.  ]\n8.  French Patent Application, Publication No. 2850021\n[8'.  ]\n\n")
    end

    it "reads citations, general check 3" do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n\n")
    end

    it "reads citations, general check 3" do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n\n")
    end

    it "reads citations, general check 4" do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n\n")
    end

    it "reads citations, general check 5" do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n\n")
    end
  end

  context "#parse_ipc" do
    it "reads ipc, group text check" do
      oa1.parse_ipc
      expect(oa1.props[:ipc_list]).to eql("IPC: C08L 83/00-83/16\r\n             A61K 8/00-8/99\r\n             A61Q 1/00-90/00\r\n             C08G 77/00-77/62\r\n             C09D 1/00-10/00\r\n                  101/00-201/10\r\n             D06M 13/00-15/05\r\n                  15/07-15/41\r\n                  15/423-15/427\r\n                  15/43\r\n                  15/433-15/55\r\n                  15/564-15/576\r\n                  15/59\r\n                  15/61-15/70\r\n")
    end

    it "reads ipc, group text check" do
      oa2.parse_ipc
      expect(oa2.props[:ipc_list]).to eql("IPC: A61K8/00-8/99\r\n             A61Q1/00-90/00\r\n\r\n・出願人への要請\r\n 引用文献3は、本願出願時に公開されており、本願と出願人又は発明者が共通\r\nする文献であって、本願の一以上の請求項について、当該引用文献のみで新規性\r\n又は進歩性を否定するものです。\r\n このような文献に基づいて、事前に発明を適切に評価することは、出願人によ\r\nる適切な請求項の作成に役立つとともに、迅速かつ的確な審査にも資するものと\r\n考えられます。出願・審査請求の際には、このような文献を出願人が知ってい")
    end

    it "reads ipc, group text check" do
      oa3.parse_ipc
      expect(oa3.props[:ipc_list]).to eql("IPC: A61F2/06\r\n             A61M1/10\r\n\r\n")
    end

    it "reads ipc, group text check" do
      oa4.parse_ipc
      expect(oa4.props[:ipc_list]).to eql("IPC: G06F13/00\r\n             G06F12/00\r\n")
    end
  end #context parse_ipc
end
