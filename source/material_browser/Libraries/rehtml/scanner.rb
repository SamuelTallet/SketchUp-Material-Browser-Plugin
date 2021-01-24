# -*- encoding: utf-8 -*-
require 'strscan'
module REHTML
  class Scanner < StringScanner
    def scan_before_or_eos(regex, move_after=false)
      self.scan_before(regex, true, move_after)
    end
    def scan_before(regex, or_eos=false, move_after=false)
      text = self.scan_until(regex)
      if text
        size = self.matched.size
        self.pos -= size unless move_after
        return text[0...(-size)]
      end
      if or_eos
        text = self.rest
        self.terminate
      end
      text
    end
  end
end
