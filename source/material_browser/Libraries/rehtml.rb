require 'rehtml/version'
require 'rehtml/tokenizer'
require 'rehtml/builder'

module REHTML
  # convert html(string) to REXML::Document
  def self.to_rexml(html)
    builder = REXMLBuilder.new
    builder.parse(Tokenizer.new(html))
    builder.doc
  end
end
