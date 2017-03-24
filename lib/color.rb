require 'matrix'

class Color < Vector
  def r
    self[0]
  end

  def g
    self[1]
  end

  def b
    self[2]
  end

  def *(x)
    case x
    when Color
      els = [@elements[0] * x.r, @elements[1] * x.g, @elements[2] * x.b]
      self.class.elements(els, false)
    else
      super(x)
    end
  end

  def /(x)
    case x
    when Color
      els = [@elements[0] / x.r, @elements[1] / x.g, @elements[2] / x.b]
      self.class.elements(els, false)
    else
      super(x)
    end
  end

  def **(x)
    els = @elements.map { |e| e**x }
    self.class.elements(els, false)
  end

  WHITE = Color[0.9, 0.9, 0.9]
  BLACK = Color[0, 0, 0]
  RED = Color[0.9, 0.3, 0.3]
  GREEN = Color[0.1, 0.9, 0.1]
  BLUE = Color[0.1, 0.1, 0.9]
end
