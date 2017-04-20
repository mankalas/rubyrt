# A source of light
class PointLight
  attr_reader :position,
              :diffuse_color, :diffuse_power,
              :specular_color, :specular_power, :specular_hardness

  def initialize(position,
                 diffuse_color, diffuse_power,
                 specular_color, specular_power, specular_hardness = 100)
    @position = position
    @diffuse_color = diffuse_color
    @diffuse_power = diffuse_power
    @specular_color = specular_color
    @specular_power = specular_power
    @specular_hardness = specular_hardness
  end

  def lighting(intersection, view_direction, normal)
    return unless diffuse_power > 0

    light_direction = intersection.ray.direction
    distance = intersection.distance**2

    ndotL = normal.dot(light_direction)

    h = (light_direction + view_direction).normalize
    ndotH = [normal.dot(h), 0].max

    Light.new(diffuse_factoring(ndotL, distance),
              specular_factoring(ndotH, distance))
  end

  def diffuse_factoring(intensity, distance)
    saturated_intensity = [intensity, 1].min
    diffuse_color * saturated_intensity * diffuse_power / distance
  end

  def specular_factoring(intensity, distance)
    saturated_intensity = [intensity, 1].min**specular_hardness
    specular_color * saturated_intensity * specular_power / distance
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
