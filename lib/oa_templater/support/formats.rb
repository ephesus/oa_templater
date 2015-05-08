#!/usr/bin/env ruby
# encoding: UTF-8

CIT_SIMPLE = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p>'
CIT_WITH_PRIME = '<w:p><w:pPr><w:pStyle w:val="Paragraph" /></w:pPr><w:r><w:t xml:space="preserve">%s.  %s</w:t></w:r></w:p><w:p><w:pPr><w:pStyle w:val="Paragraph" /></w:pPr><w:r><w:t xml:space="preserve">[</w:t></w:r><w:r><w:rPr><w:i /></w:rPr><w:t xml:space="preserve">%s\'.  </w:t></w:r><w:r><w:t xml:space="preserve">]</w:t></w:r></w:p>'
