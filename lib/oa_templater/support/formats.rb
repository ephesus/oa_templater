#!/usr/bin/env ruby
# encoding: UTF-8

CIT_SIMPLE = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p>'
CIT_WITH_PRIME = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">[</w:t></w:r><w:r><w:rPr><w:i /></w:rPr><w:t xml:space="preserve">%s\'.  </w:t></w:r><w:r><w:t xml:space="preserve">]</w:t></w:r></w:p>'
CIT_WITH_PRIME_PCT = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">[</w:t></w:r><w:r><w:rPr><w:i /></w:rPr><w:t xml:space="preserve">%s\'.  PCT International Publication No. WO X; Corresponding English language application</w:t></w:r><w:r><w:t xml:space="preserve">]</w:t></w:r></w:p>'
CIT_MISS = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>'
HEADERS_FMT = '<w:p><w:pPr><w:tabs><w:tab w:val="clear" w:pos="864"/><w:tab w:val="left" w:pos="567"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r w:rsidR="006A661C"><w:rPr><w:b/><w:noProof/></w:rPr><w:t>%s</w:t></w:r></w:p>'
STOPSTARTTAB = '</w:t></w:r></w:p><w:p w:rsidR="001827DB" w:rsidRDefault="006B1000" w:rsidP="00C26A48"><w:pPr><w:tabs><w:tab w:val="clear" w:pos="864"/><w:tab w:val="left" w:pos="567"/></w:tabs><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:rPr><w:rFonts w:hint="eastAsia"/></w:rPr><w:tab/></w:r><w:r w:rsidR="00014172"><w:t>'
STOPSTARTP = '</w:t></w:r></w:p><w:p w:rsidR="001827DB" w:rsidRDefault="00C26A48" w:rsidP="00C26A48"><w:pPr><w:tabs><w:tab w:val="clear" w:pos="864"/><w:tab w:val="left" w:pos="567"/></w:tabs><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:rPr><w:rFonts w:hint="eastAsia"/></w:rPr></w:r><w:r w:rsidR="00014172"><w:t>'


FINALWML = '<w:p w:rsidR="00D6029F" w:rsidRPr="00D6029F" w:rsidRDefault="00D6029F" w:rsidP="00D6029F"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:jc w:val="center"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:b/><w:noProof/></w:rPr></w:pPr><w:r><w:rPr><w:rFonts w:hint="eastAsia"/><w:b/><w:noProof/></w:rPr><w:t>&lt;</w:t></w:r><w:r w:rsidR="00344336" w:rsidRPr="00D6029F"><w:rPr><w:b/><w:noProof/></w:rPr><w:t>Reason for Making the Notice of Reasons for Rejection Final</w:t></w:r><w:r><w:rPr><w:rFonts w:hint="eastAsia"/><w:b/><w:noProof/></w:rPr><w:t>></w:t></w:r></w:p><w:p w:rsidR="00BA3DB3" w:rsidRDefault="00BA3DB3" w:rsidP="00467FCF"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr></w:pPr></w:p><w:p w:rsidR="00693616" w:rsidRDefault="00344336" w:rsidP="00693616"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:ind w:firstLine="567"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr></w:pPr><w:r><w:rPr><w:noProof/></w:rPr><w:t>This Notice of Reasons for Rejection only gives notification of the existence of reasons for rejection made necessary by the amendments made in response to the previous Notice of Reasons for Rejection.</w:t></w:r></w:p><w:p w:rsidR="00693616" w:rsidRDefault="00693616" w:rsidP="00693616"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:ind w:firstLine="567"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr></w:pPr></w:p><w:p w:rsidR="00693616" w:rsidRDefault="00344336" w:rsidP="00693616"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:ind w:firstLine="567"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr></w:pPr><w:r><w:rPr><w:noProof/></w:rPr><w:t>This Notice of Reasons for Rejection only gives notification of the existence of reasons for rejection relating to slight deficiencies in the descriptions that still remain because no notification was previously given of reasons for rejection regarding such slight deficiencies in the descriptions even though these deficiencies were present.</w:t></w:r></w:p><w:p w:rsidR="00693616" w:rsidRDefault="00693616" w:rsidP="00693616"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:ind w:firstLine="567"/><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr></w:pPr></w:p><w:p w:rsidR="00256A20" w:rsidRDefault="00344336" w:rsidP="00693616"><w:pPr><w:widowControl w:val="0"/><w:tabs><w:tab w:val="clear" w:pos="864"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/><w:ind w:firstLine="567"/></w:pPr><w:r><w:rPr><w:noProof/></w:rPr><w:t>This Notice of Reasons for Rejection only gives notification of the following reasons for rejection.</w:t></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:br/></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:br/><w:t xml:space="preserve">1. </w:t></w:r><w:r w:rsidR="00693616"><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr><w:tab/></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:t>Reasons for rejection for which notification was made necessary by the amendments made in response to the first Notice of Reasons for Rejection (corresponding to "A" among the reasons for rejection mentioned above).</w:t></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:br/><w:t xml:space="preserve">2. </w:t></w:r><w:r w:rsidR="00693616"><w:rPr><w:rFonts w:hint="eastAsia"/><w:noProof/></w:rPr><w:tab/></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:t>Reasons for rejection relating to the fact that, although slight deficiencies in the descriptions existed, since notification was not given of the reasons for rejection relating to those deficiencies, such slight deficiencies in the descriptions still remain (corresponding to "B" among the reasons for rejection mentioned ab</w:t></w:r><w:bookmarkStart w:id="0" w:name="_GoBack"/><w:bookmarkEnd w:id="0"/><w:r><w:rPr><w:noProof/></w:rPr><w:t>ove).</w:t></w:r><w:r><w:rPr><w:noProof/></w:rPr><w:br/></w:r></w:p>a'
