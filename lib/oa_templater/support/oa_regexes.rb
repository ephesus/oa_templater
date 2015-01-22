module OaTemplater
  R_HEADER_SEPARATOR = /:|：|\/|／(?:請求項|引用文献|理由|先願|実施例)/
  R_HEADER_TYPES = /(
    (?:(?:..)?(?:＜|（|［|【)(?:本願)*(?:請\p{Z}*求\p{Z}*項|引用文献|理\p{Z}*由|備\p{Z}*考|実\p{Z}*施\p{Z}*例)(?:\p{Z}*.*\p{N}，*\p{Z}*)+(?:(?:について)*＞|）|］|】))
                     | (?:(?:^.{0,4})((?:＜|（|［|【)(?:本願)*(?:請\p{Z}*求\p{Z}*項|引用文献|理\p{Z}*由|備\p{Z}*考|実\p{Z}*施\p{Z}*例)\p{N}.*?(?:について)?(?:）)))
                     | (?:^\p{Z}*(?:・.*)\p{N}(?:について)*\p{Z}*$)
                     | (?:^.*(?:本\p{Z}*願)*(?:請\p{Z}*求\p{Z}*項|引用文献|理\p{Z}*由|実\p{Z}*施\p{Z}*例):*：*.*\p{N}(?:について)*\p{Z}*$)
                     | (?:(?:・)*備考)
                     | (?:^\p{Z}*$)
                    )/x
  R_RESPONSE_PERIOD = /、この通知書の発送の日から６０日以内に意見書を提出して/
  R_AND_AMENDMENTS = /なお、意見書.{0,4}?手続補正書の内容を検討しました/
  R_CITATIONS_START = /(引用文献(?:等についてはＡを参照.{0,4})|引　用　文　献　等　一　覧|引用文献(等)?一覧|引用文献等|引\p{Z}*用\p{Z}*文\p{Z}*献|引用刊行(物)?).?(?:<\/CENTER>)*\s+\p{Z}*\p{N}+?(?:\.|．|：)*\p{Z}*/m
  R_CAPTURE_APPEAL_DRAFTED = /作成日p{Z}+\p{Z}*(?:平成)*\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/
  R_CAPTURE_DRAFTED = /起案日\p{Z}+\p{Z}*(?:平成)*\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/
  R_CAPTURE_MAILING_DATE = /発送日\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)/
  R_CAPTURE_PREVIOUS_OA = /この出願については、\p{Z}*平成\p{Z}*(\p{N}+)年\p{Z}*(\p{N}+)月\p{Z}*(\p{N}+)日付け拒絶理由通知書に記載/
  R_CAPTURE_RETROACTIVE = /出願日（遡及日）\p{Z}*平成(\p{N}*)年\p{Z}*(\p{N}*)月\p{Z}*(\p{N}*)日/
  R_CAPTURE_APPEAL_NO = /番号\p{Zs}*不服(\p{N}+)\S(\p{Zs}*\p{N}+)/
  R_CAPTURE_APP_NO = /特許出願の番号\p{Z}+特願(\p{N}+)\S(\p{N}+)/
  R_CAPTURE_TARO = /特許庁審査官\p{Zs}+(\S+?)\p{Zs}(\S+?)\p{Zs}+(\p{N}+)\p{Zs}+(\S+)/
  R_CAPTURE_APPEAL_TARO = /審判長(?:\p{Z}*)特許庁審判官\p{Z}+(\S+?)\p{Z}(\S+?)\p{Z}*$/
end

