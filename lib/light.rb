# A source of light
class PointLight
  attr_reader :position,
              :diffuse_color, :diffuse_power,
              :specular_color, :specular_power

  def initialize(position,
                 diffuse_color, diffuse_power,
                 specular_color, specular_power)
    @position = position
    @diffuse_color = diffuse_color
    @diffuse_power = diffuse_power
    @specular_color = specular_color
    @specular_power = specular_power
  end
end

# Light properties on a point
class Light
  attr_reader :diffuse, :specular

  def initialize(diffuse, specular)
    @diffuse = diffuse
    @specular = specular
  end
end

# A ray of light
class Ray
  attr_reader :direction, :origin

  def initialize(origin, direction)
    @origin = origin
    @direction = direction.normalize
  end
end
