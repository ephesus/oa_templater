OA Templater
==============

- [![Build Status](https://travis-ci.org/ephesus/oa_templater.svg?branch=master)](https://travis-ci.org/ephesus/oa_templater)
- [![Gem Version](https://badge.fury.io/rb/oa_templater.png)](https://rubygems.org/gems/oa_templater)

Pulls out relevant data from an Office Action from the Japanese Patent Office.


```ruby
oa = OaTemplater::OA.new(ARGV[0], ARGV[1])
oa.set_templates(kyozetsuriyu: "./kyozetsuriyu.docx",
                 kyozetsusatei: "kyozetsusatei.docx",
                 shinnen: "shinnen.docx")
oa.set_reasons_file(File.join(File.dirname(__FILE__), "templates", "reasons.yml"))
buffer = oa.scan

#write to oa.outputfile (e.g. ALP31232.拒絶理由.20140602.docx)
oa.finish 

#or manually
File.open(oa.outputfile, 'wb') { |f| f.write(buffer.string) }
```
