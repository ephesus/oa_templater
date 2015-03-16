# encoding: UTF-8

require 'spec_helper'

describe OaTemplater do
  # instead of factory girl or whatever, just open up actual OA files
  let(:oas) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_satei.htm'), 66_666) }
  let(:oa1) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa1.htm'), 66_666) }
  let(:oa2) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa2.htm'), 66_666) }
  let(:oa3) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa3.htm'), 66_666) }
  let(:oa4) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa4.htm'), 66_666) }
  let(:oa5) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa5.htm'), 66_666) }
  let(:oa6) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa6.htm'), 66_666) }
  let(:oa7) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa7.htm'), 77_777) }
  let(:oa8) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa8.htm'), 88_888) }
  let(:oa9) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa9.htm'), 99_999) }
  let(:oa10) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa10.htm'), 10_010) }
  let(:oa11) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa11.htm'), 11_010) }
  let(:oa12) { OaTemplater::OA.new(File.join(File.dirname(__FILE__), 'test_oa12.htm'), 12_010) }

  context '#new' do
    # fail fast on catastrphic error
    it 'expects not nil' do
      expect(oa1).not_to be_nil
    end

    it 'should be an instance of OaTemplater' do
      expect(oa1).to be_an_instance_of OaTemplater::OA
    end

    # do some very high level checks that nothing is super-broken
    it 'captures ref_no' do
      oa8.parse_drafted
      expect(oa8.props[:ref_no]).to eql('F43204D1')
    end

    it 'captures ref_no' do
      oa1.parse_drafted
      expect(oa1.props[:ref_no]).to eql('J64754A1')
    end

    it 'captures blank ref_no' do
      oa5.parse_drafted
      expect(oa5.props[:ref_no]).to eql('')
    end

    it 'captures mailing_no' do
      oa8.parse_drafted
      expect(oa8.props[:mailing_no]).to eql('295285')
    end

    it 'captures mailing_no' do
      oa6.parse_drafted
      expect(oa6.props[:mailing_no]).to eql('503441')
    end

    it 'captures mailing_no' do
      oa1.parse_drafted
      expect(oa1.props[:mailing_no]).to eql('220540')
    end
  end

  context '#parse_drafted' do
    it 'captures drafted date' do
      oa1.parse_drafted
      expect(oa1.props[:drafted]).to eql('2014/04/10')
    end

    it 'captures drafted date' do
      oa6.parse_drafted
      expect(oa6.props[:drafted]).to eql('2014/09/17')
    end
  end

  context '#mailing_date' do
    it 'captures mailing_date' do
      oa1.parse_mailing_date
      expect(oa1.props[:mailing_date]).to eql('2014/04/15')
    end

    it 'sets the outputfile' do
      oa1.parse_mailing_date
      expect(oa1.outputfile).to eql('ALP66666.拒絶理由.20140415.docx')
    end

    it 'sets the outputfile' do
      oa5.parse_mailing_date
      expect(oa5.outputfile).to eql('ALP66666.拒絶理由.20140520.docx')
    end
  end

  context '#examiner' do
    it 'captures examiner' do
      oa6.parse_examiner(do_examiner: true)
      expect(oa6.props[:taro]).to eql('Akira OGAWA')
    end

    it 'captures examiner' do
      oa1.parse_examiner(do_examiner: true)
      expect(oa1.props[:taro]).to eql('Atsushi OKAZAKI')
    end

    it 'captures examiner code' do
      oa1.parse_examiner(do_examiner: true)
      expect(oa1.props[:code]).to eql('4515 4J00')
    end

    it 'captures examiner' do
      oa2.parse_examiner(do_examiner: true)
      expect(oa2.props[:taro]).to eql('Naoko MATSUMOTO')
    end

    it 'captures examiner code' do
      oa2.parse_examiner(do_examiner: true)
      expect(oa2.props[:code]).to eql('9546 4D00')
    end

    it 'captures examiner' do
      oa3.parse_examiner(do_examiner: true)
      expect(oa3.props[:taro]).to eql('Tadashi TERASAWA')
    end

    it 'captures examiner code' do
      oa3.parse_examiner(do_examiner: true)
      expect(oa3.props[:code]).to eql('9623 3I00')
    end

    it 'captures examiner code' do
      oa6.parse_examiner(do_examiner: true)
      expect(oa6.props[:code]).to eql('3006 2S00')
    end
  end

  context '#app_no' do
    it 'captures app_no' do
      oa1.parse_app_no
      expect(oa1.props[:app_no]).to eql('2010-288649')
    end
  end

  context '#drafted' do
    it 'captures drafted' do
      oa1.parse_drafted
      expect(oa1.props[:drafted]).to eql('2014/04/10')
    end
  end

  context '#headers' do
    it 'outputs some headers general check 3' do
      oa1.parse_headers true
      expect(oa1.props[:oa_headers]).to eql("\n\n\n\n1.Reasons 1 and 2\n・Claims 1 to 6 and 9 to 13\n・Citation 1\n・Notes\nCitations 1 の【Claims 1 】 to 【Claims 7 】,【 0001 】,【 and 0006】\n\nCitations 1 には,一般式:HdRe(OR 1 )fSiO (and 4\n\n\n2.Reason 2\n・Claims 7 and 8\n・Citations 1 and 2\n・Notes\nCitation 1\nCitations 2 の【 and 0002】\n\nClaims 7, 8 に係る発明と,Citations and 1\n\n\n")
    end

    it 'outputs some headers general check 2' do
      oa2.parse_headers true
      expect(oa2.props[:oa_headers]).to eql("\n\n\n(A)Reason 1: Claims 1 and 5 to 11: Citation 1\nReason 2: Claims 1 to 11: Citations 1 to 7\n(Notes)\nCitation 1\n\n献2(Claims 6, Embodiments and 1)\n),Citations 6 (特許請求の範囲,段落【 0037 】,段落【 0067 】 to 【 and 0137】\n\n(B)Reason 1: Claims 1 to 11: Citations 2 and 3\nReason 2: Claims 1 to 11: Citations 1 to 7\n(Notes)\nCitations 2 には,本願Claims and 2 to 4\n,Embodiment 1\nCitations 3 には,本願Claims and 2 to 4\n\n\n(C)Reasons 1 and 2: Claims 1 to 9: Citation 8\n(Notes)\nCitation 8\n\n(D)Reason 3\nよって,Claims 5, 7, 10 (,これらを引用するClaims 6, 8, 9, and 11\n\n\n")
    end

    it 'outputs some headers general check 3' do
      oa3.parse_headers true
      expect(oa3.props[:oa_headers]).to eql("\nReasons 1 .この出願は,下記の点で特許法第 and 37\n\nReasons 2 .この出願の下記のClaimsに係る発明は,下記の点で特許法第 29 条第 and 1\n\nReason 3\n\nReason 4\n\n\n<Reason 1>\nClaims 1 に係る発明は,Citations 1, and 2\nる,Claims 3, 4, and 26 to 31\n\nClaims 24 and 25\nClaims 1 に係る発明は,周知技術にすぎないものであることから,上記 (and 1)\n,Claim 1\nそれに対して,Claims 5 to 8 に係る発明の技術的特徴は「血管導管の前記第 and 1\nClaims 22 and 23\n\n\n<Reason 2>\nClaims 26 to 31\n\n<Reasons 3 and 4>\n・Claims 1, 24, and 25\n・Citation 1\nCitations 1 に記載された「中空器官固定用器具 (and 51)\n\n・Claims 1, 24, and 25\n・Citation 2\nCitation 2\n\n<Reason 4>\n・Claims 2 to 4\n・Citations 1, 3, and 4\nCitation 1\n\n\n")
    end

    it 'outputs no headers' do
      oa5.parse_headers true
      expect(oa5.props[:oa_headers]).to eql("\nClaim 11\n\n\n\n\n\n\nClaims 12 and 15 to 18\n\nClaims (1 to 10, 13, and 14)\n\n")
    end


    it 'outputs some headers general check 6' do
      oa6.parse_headers true
      expect(oa6.props[:oa_headers]).to eql("\nReason 1\n\n\n・Claims 1 to 3, 5 to 9, 11 to 15, and 17 to 22\n・Citation 1\n・Notes\n\nよって,Citations 1 に記載の発明に基づき,Claims 1 to 3, 5 to 9, and 11 to 1\n\n\nReason 2\n\n\n\n\n同様のReasonsで,Claims 2, 5, 7, 8, 11, 13, 14, 17 to 19, and 22\n\n\n\n\n\n")
    end

    it 'outputs some headers general check 3' do
      oa8.parse_headers true
      expect(oa8.props[:oa_headers]).to eql("\n\n\n\n\n<Reason 1>\n\n\n・Claim 1\n\n<Reason 2>\n\n・Claim 5\n\n\n\n<Reason 3>\n\n・Claims 1 to 4\n・Citations 1 and 2\n・Notes\nCitations 1 (特に,段落 0012, 0014, 0015, and 0031 to 0039\n一方,Citations 2 (特に,第 2 ページ右下欄第 7 行 to 第 3 ページ右上欄第 and 14\n\n\n")
    end

    it 'outputs no headers' do
      oa9.parse_headers true
      expect(oa9.props[:oa_headers]).to eql("\n\n\n・Claims 1 and 3\n・Citations 1 and 2\n・Notes\nCitations 1 には,レーザエネルギ源 and 11\nCitations 2 には,ダイオード and 2\nCitation 2\n\n・Claim 2\n・Citations 1 to 3\n・Notes\nCitations 3 には,長尺方向と短尺方向で曲率が異なるトロイダルレンズ and 150\nてCitation 3\n\n・Claims 4 to 6\n・Citations 1 to 4\n・Notes\nCitations 4 には,ガイド用可視光半導体レーザ and 10\nら,Citations 1 to 3 におけるレーザ装置にCitations and 4\n\n\n・Claims 7 and 9\n・Citations 1 to 5\n・Notes\nCitations 5 には, and 18\n\n・Claims 8 and 10 to 15\n・Citations 1 to 6\n・Notes\nCitation 6\n\n")
    end

    it 'outputs no headers' do
      oa11.parse_headers true
      expect(oa11.props[:oa_headers]).to eql("\n【Reason 1】\n\n\n・Claims: 1, 4, 6, and 12\n・Citation: 1\n・Notes\nCitations 1 には,相対的に比透磁率が小さい第 1 磁性体層と,第 and 1\n\n\n【Reason 2】\n\n\n・Claims: 1, 4, 6, and 12\n・Citation: 1\n・Notes\n上記【Reason 1】\n,Citation 1\nCitation 1\n\n・Claims: 2, 3, and 7 to 10\n・Citations: 1 and 2\n・Notes\n\n・Claim: 5\n・Citations: 1 to 3\n・Notes\n\n・Claim: 11\n・Citations: 1 to 3\n・Notes\n\n\n\n【Reason 3】\n\n\n・Claims: 6, 11, and 12\n・Notes\n\n\n")
    end

    it 'outputs no headers' do
      oa12.parse_headers true
      expect(oa12.props[:oa_headers]).to eql("\n\n・Claims 1, 2, 6 to 9, 13 to 16, 20 to 23, 27 to 30, 34 to 37, 41 to 44, 48 to 51, 55, and 56\n・Citation 1\n・Notes\nCitations 1 には,そのclaim 1 to 8, FIG. 2 A to FIG. and 5\n\n\n\nClaims 1, 2, 6, 7 に係る発明と各々対応するClaims 8, 9, and 13 to 16\n\nClaims (3 to 5, 10 to 12, 17 to 19, 24 to 26, 31 to 33, 38 to 40, 45 to 47, and 52 to 54)\n\n\n")
    end
  end

  context '#our_lawyer' do
    it 'captures our_lawyer' do
      oa1.parse_our_lawyer
      expect(oa1.props[:our_lawyer]).to eql('Masatake SHIGA')
    end

    it 'captures our_lawyer 村山' do
      oa6.parse_our_lawyer
      expect(oa6.props[:our_lawyer]).to eql('Yasuhiko MURAYAMA')
    end

    it 'captures our_lawyer 村山' do
      oa2.parse_our_lawyer
      expect(oa2.props[:our_lawyer]).to eql('Yasuhiko MURAYAMA')
    end
  end

  context '#see_list' do
    it 'captures see_list' do
      oa1.parse_see_list
      expect(oa1.props[:see_list]).to eql("\r\n(See the List of Citations for the cited publications)\r\n \r\n")
    end

    it 'captures no see_list' do
      oa5.parse_see_list
      expect(oa5.props[:see_list]).to eql('')
    end
  end

  context '#final_oa' do
    it 'captures no final_oa' do
      oa1.parse_final_oa
      expect(oa1.props[:final_oa]).to eql('')
    end

    it 'captures final_oa' do
      oa5.parse_final_oa
      expect(oa5.props[:final_oa]).to eql("\n<<<<    FINAL    >>>>\n \n")
    end
  end

  context '#satei_previous_oa' do
    it 'captures satei_previous_oa' do
      oas.parse_satei_previous_oa
      expect(oas.props[:satei_previous_oa]).to eql('2013/06/24')
    end

    it 'captures no satei_previous_oa' do
      oa1.parse_satei_previous_oa
      expect(oa1.props[:satei_previous_oa]).to eql('')
    end
  end

  context '#articles' do
    it 'captures articles' do
      oa1.set_reasons_file('/home/ephesus/code/reader/templates/reasons.yml')
      oa1.parse_articles
      expect(oa1.props[:articles]).to eql("Article 29, Paragraph 1\n\tArticle 29, Paragraph 2\n")
    end
  end

  context '#currently_known' do
    it 'captures no currently_known' do
      oa1.parse_currently_known
      expect(oa1.props[:currently_known]).to eql('')
    end
  end

  context '#parse_citations' do
    it 'reads citations, general check 1' do
      oa1.parse_citations
      expect(oa1.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H10-101800\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H11-147949\n[2'.  ]\n")
    end

    it 'reads citations, general check 2' do
      oa2.parse_citations
      expect(oa2.props[:citation_list]).to eql("1.  West German Patent Application Publication No. 3411062\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. S53-15437\n[2'.  ]\n3.  Japanese Unexamined Patent Application, First Publication No. 2000-7532\n[3'.  ]\n4.  Published Japanese Translation No. 2002-505360 of the PCT International Publication\n[4'.  ]\n5.  Japanese Unexamined Patent Application, First Publication No. H08-12538\n[5'.  ]\n6.  Japanese Unexamined Patent Application, First Publication No. 2006-124391\n[6'.  ]\n7.  Published Japanese Translation No. 2002-517427 of the PCT International Publication\n[7'.  ]\n8.  French Patent Application, Publication No. 2850021\n[8'.  ]\n")
    end

    it 'reads citations, general check 3' do
      oa3.parse_citations
      expect(oa3.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H07-132123\n[1'.  ]\n2.  Published Japanese Translation No. H09-511409 of the PCT International Publication\n[2'.  ]\n3.  Published Japanese Translation No. 2009-525128 of the PCT International Publication\n[3'.  ]\n4.  Japanese Unexamined Patent Application, First Publication No. S63-246174\n[4'.  ]\n")
    end

    it 'reads citations, general check 3' do
      oa4.parse_citations
      expect(oa4.props[:citation_list]).to eql("1.  United States Patent Application, Publication No. 2010/0049872\n2.  Japanese Unexamined Patent Application, First Publication No. 2006-178513\n[2'.  ]\n3.  PCT International Publication No. WO 98/24027\n[3'.  ]\n4.  United States Patent Application, Publication No. 2008/0228864\n5.  Japanese Unexamined Patent Application, First Publication No. 2007-287175\n[5'.  ]\n6.  Japanese Unexamined Patent Application, First Publication No. 2002-251315\n[6'.  ]\n7.  Japanese Unexamined Patent Application, First Publication No. 2003-330789\n[7'.  ]\n8.  Japanese Unexamined Patent Application, First Publication No. 2005-341004\n[8'.  ]\n9.  Japanese Unexamined Patent Application, First Publication No. 2004-021769\n[9'.  ]\n")
    end

    it 'reads citations, general check 4' do
      oa5.parse_citations
      expect(oa5.props[:citation_list]).to eql('')
    end

    it 'reads citations, general check 5' do
      oas.parse_citations
      expect(oas.props[:citation_list]).to eql('')
    end

    it 'reads citations, general check 6' do
      oa6.parse_citations
      expect(oa6.props[:citation_list]).to eql("1.  United States Patent Application, Publication No. 2010/0109945\n")
    end

    it 'reads citations, general check 7' do
      oa7.parse_citations
      expect(oa7.props[:citation_list]).to eql("1.  PCT International Publication No. WO 2009/006217\n[1'.  ]\n2.  Published Japanese Translation No. 2006-527170 of the PCT International Publication\n[2'.  ]\n3.  Published Japanese Translation No. 2005-537219 of the PCT International Publication\n[3'.  ]\n4. SYNTHESIS, 1988, V4, P274-277\n5. ORGANIC SYNTHESIS, 1990 1月 1日, V69, P238-244\n(注)法律又は契約等の制限により、提示した非特許文献の一部又は全てが送付\nされない場合があります。\n")
    end

    it 'reads citations, general check 8' do
      oa8.parse_citations
      expect(oa8.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. H07-243344\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. H03-141835\n[2'.  ]\n")
    end

    it 'reads citations, general check 9' do
      oa9.parse_citations
      expect(oa9.props[:citation_list]).to eql("1.  Published Japanese Translation No. 2004-538108 of the PCT International Publication\n[1'.  ]\n2.  United States Patent Application, Publication No. 2005/0053106\n3.  Japanese Unexamined Patent Application, First Publication No. 2003-066368\n[3'.  ]\n4.  Japanese Unexamined Patent Application, First Publication No. H01-099576\n[4'.  ]\n5.  Published Japanese Translation No. 2006-518610 of the PCT International Publication\n[5'.  ]\n6.  Published Japanese Translation No. 2005-518255 of the PCT International Publication\n[6'.  ]\n")
    end

    it 'reads citations, general check 10' do
      oa10.parse_citations
      expect(oa10.props[:citation_list]).to eql("1. NAGY ZOLTAN A, NATURE MEDICINE, 2002 8月, V8 N8, P801-807\n2. VIDOVIC D, CANCER LETTERS, 米国, 1998 6月19日, V128 N2, P12\n7-135\n3.  United States Patent Application, Publication No. 2001/0053360\n4. Fukuda T.  et al. , Restoration of surface IgM-mediated apoptosis in an\n anti-IgM-resistant variant of WEHI-231 lymphoma cells by HS1,  a protein\n-tyrosine kinase substrate. , Proc. Natl. Acad. Sci. USA, 1995, Vol. 92\n, p. 7302-7306\n")
    end

    it 'reads citations, general check 11' do
      oa11.parse_citations
      expect(oa11.props[:citation_list]).to eql("1.  Japanese Unexamined Patent Application, First Publication No. 2008-219614\n[1'.  ]\n2.  Japanese Unexamined Patent Application, First Publication No. 2005-142984\n[2'.  ]\n3.  Japanese Unexamined Patent Application, First Publication No. 2008-153925\n[3'.  ]\n")
    end

    it 'reads citations, general check 12' do
      oa12.parse_citations
      expect(oa12.props[:citation_list]).to eql("1.  United States Patent Application, Publication No. 2009/0204819\n")
    end
  end

  context '#parse_ipc' do
    it 'reads ipc, group text check' do
      oa1.parse_ipc
      expect(oa1.props[:ipc_list]).to eql("IPC: C08L 83/00-83/16\r\n             A61K 8/00-8/99\r\n             A61Q 1/00-90/00\r\n             C08G 77/00-77/62\r\n             C09D 1/00-10/00\r\n                  101/00-201/10\r\n             D06M 13/00-15/05\r\n                  15/07-15/41\r\n                  15/423-15/427\r\n                  15/43\r\n                  15/433-15/55\r\n                  15/564-15/576\r\n                  15/59\r\n                  15/61-15/70\r\n")
    end

    it 'reads ipc, group text check' do
      oa2.parse_ipc
      expect(oa2.props[:ipc_list]).to eql("IPC: A61K8/00-8/99\r\n             A61Q1/00-90/00\r\n\r\n・出願人への要請\r\n 引用文献3は、本願出願時に公開されており、本願と出願人又は発明者が共通\r\nする文献であって、本願の一以上の請求項について、当該引用文献のみで新規性\r\n又は進歩性を否定するものです。\r\n このような文献に基づいて、事前に発明を適切に評価することは、出願人によ\r\nる適切な請求項の作成に役立つとともに、迅速かつ的確な審査にも資するものと\r\n考えられます。出願・審査請求の際には、このような文献を出願人が知ってい")
    end

    it 'reads ipc, group text check' do
      oa3.parse_ipc
      expect(oa3.props[:ipc_list]).to eql("IPC: A61F2/06\r\n             A61M1/10\r\n\r\n")
    end

    it 'reads ipc, group text check' do
      oa4.parse_ipc
      expect(oa4.props[:ipc_list]).to eql("IPC: G06F13/00\r\n             G06F12/00\r\n")
    end

    it 'reads ipc, group text check' do
      oa10.parse_ipc
      expect(oa10.props[:ipc_list]).to eql("IPC: A61K38/00-38/58\r\n             A61K39/00-39/44\r\n             A61K45/00-45/08\r\n             A61K48/00\r\n                     C07K1/00-19/00\r\n         \tDB Name: CAPLUS/BIOSIS/MEDLINE (STN)  \r\n")
    end

    it 'reads ipc, group text check' do
      oa11.parse_ipc
      expect(oa11.props[:ipc_list]).to eql("IPC: H01Q  1/00-13/28、\r\n                  21/00-25/04\r\n         ")
    end

    it 'reads ipc, group text check' do
      oa12.parse_ipc
      expect(oa12.props[:ipc_list]).to eql("IPC: G06F21/30-21/46\r\n         \tDB Name: ")
    end
  end # context parse_ipc
end
