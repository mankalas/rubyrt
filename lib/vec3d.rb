class Vec3d
  include Enumerable

  attr_reader :x, :y, :z

  def initialize(x, y, z)
    @x, @y, @z = x, y, z
  end

  def round
    Vec3d.new(x.round, y.round, z.round)
  end

  def round!
    @x = x.round, @y = y.round, @z = z.round
  end

  def ==(other)
    return false unless Vec3d === other
    x == other.x && y == other.y && z == other.z
  end

  def *(other)
    case other
    when Numeric
      Vec3d.new(x * other, y * other, z * other)
    when Vec3d
      Vec3d.new(x * other.x, y * other.y, z * other.z)
    end
  end

  def /(other)
    Vec3d.new(x / other, y / other, z / other)
  end

  def +(other)
    Vec3d.new(x + other.x, y + other.y, z + other.z)
  end

  def -(other)
    Vec3d.new(x - other.x, y - other.y, z - other.z)
  end

  def **(t)
    Vec3d.new(x**t, y**t, z**t)
  end

  def magnitude
    Math.sqrt(x * x + y * y + z * z)
  end
  alias norm magnitude

  def normalize
    n = magnitude
    raise Error, "Zero vectors can not be normalized" if n.zero?
    self / n
  end

  def saturate
    Vec3d.new((x * 255.0).round, (y * 255.0).round, (z * 255.0).round)
  end

  def to_a
    [x, y, z]
  end

  def to_s
    "Vec3d(#{x}, #{y}, #{x})"
  end

  def dot(other)
    x * other.x + y * other.y + z * other.z
  end
end
