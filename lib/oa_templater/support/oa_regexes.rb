module OaTemplater
  R_HEADER_SEPARATOR = /\p{N}:|\p{N}：|\/|／/
  R_RESPONSE_PERIOD = /、この通知書の発送の日から６０日以内に意見書を提出して/
  R_AND_AMENDMENTS = /なお、意見書.{0,4}?手続補正書の内容を検討しました/
  R_CITATIONS_START = /(引　用　文　献　等　一　覧|引用文献(等)?一覧|引用文献等|引用文献|引用刊行(物)?).?(?:<\/CENTER>)*\s+\p{Z}*\p{N}+?(?:\.|．|：)/m
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

