module REHTML
  class Node
  end
  class Text < Node
    attr_reader :value
    def initialize(value)
      @value = value
    end
  end
  class CData < Text
  end
  class Tag < Node
    attr_reader :name, :attributes
    def initialize(name,attributes,empty)
      @name = name
      @attributes = attributes
      @empty = empty
    end
    def empty?
      @empty
    end
  end
  class EndTag < Tag
  end
  class Instruction < Node
    attr_reader :target, :content
    def initialize(target,content)
      @target = target
      @content = content
    end
    def is_xml_decl?
      target.upcase == 'XML'
    end
  end
  class Comment < Node
    attr_reader :string
    def initialize(string)
      @string = string
    end
  end
  class DocType < Node
    def initialize
    end
  end
end
