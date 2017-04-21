require 'vec3d'

class Color < Vec3d
  alias r x
  alias g y
  alias b z

  WHITE = Color.new(0.9, 0.9, 0.9)
  BLACK = Color.new(0, 0, 0)
  RED = Color.new(0.9, 0.3, 0.3)
  GREEN = Color.new(0.1, 0.9, 0.1)
  BLUE = Color.new(0.1, 0.1, 0.9)
  SKY = Color.new(0.235294, 0.67451, 0.843137)
end
