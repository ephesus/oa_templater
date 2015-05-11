#!/usr/bin/env ruby
# encoding: UTF-8

CIT_SIMPLE = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p>'
CIT_WITH_PRIME = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">[</w:t></w:r><w:r><w:rPr><w:i /></w:rPr><w:t xml:space="preserve">%s\'.  </w:t></w:r><w:r><w:t xml:space="preserve">]</w:t></w:r></w:p>'
CIT_MISS = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:t xml:space="preserve">%s</w:t></w:r></w:p>'
HEADERS_FMT = '<w:p><w:pPr><w:tabs><w:tab w:val="clear" w:pos="864"/><w:tab w:val="left" w:pos="567"/></w:tabs><w:kinsoku w:val="0"/><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r w:rsidR="006A661C"><w:rPr><w:b/><w:noProof/></w:rPr><w:t>%s</w:t></w:r></w:p>'
STOPSTARTP = '</w:t></w:r></w:p><w:p w:rsidR="001827DB" w:rsidRDefault="00C26A48" w:rsidP="00C26A48"><w:pPr><w:tabs><w:tab w:val="clear" w:pos="864"/><w:tab w:val="left" w:pos="567"/></w:tabs><w:spacing w:line="360" w:lineRule="atLeast"/></w:pPr><w:r><w:rPr><w:rFonts w:hint="eastAsia"/></w:rPr></w:r><w:r w:rsidR="00014172"><w:t>'
