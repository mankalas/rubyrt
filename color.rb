class Color
  attr_reader :r, :g, :b

  def initialize(r, g, b)
    @r, @g, @b = r, g, b
  end

  def +(other)
    Color.new(r + other.r, g + other.g, b + other.b)
  end

  def *(other)
    Color.new(*(to_a.map { |c| c * other }))
  end

  def /(other)
    Color.new(*(to_a.map { |c| c / other }))
  end

  def to_a
    [r, g, b]
  end

  def clamp
    Color.new(*(to_a.map { |c| [c, 255].min }))
  end

  def round
    Color.new(*(to_a.map(&:round)))
  end
end
