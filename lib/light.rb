# A source of light
class PointLight
  attr_reader :position,
              :diffuse_color, :diffuse_power,
              :specular_color, :specular_power, :specular_hardness

  def initialize(position,
                 diffuse_color, diffuse_power,
                 specular_color, specular_power,
                 specular_hardness = 100)
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
    ndotL = normal.dot(light_direction).abs
    h = (light_direction + view_direction).normalize
    ndotH = [normal.dot(h), 0].max
    distance_sq = intersection.distance * intersection.distance
    Light.new(diffuse_factoring(ndotL, distance_sq),
              specular_factoring(ndotH, distance_sq))
  end

  def diffuse_factoring(intensity, distance_sq)
    intensity = [intensity, 1].min
    diffuse_color * intensity * diffuse_power / distance_sq
  end

  def specular_factoring(intensity, distance_sq)
    intensity = [intensity, 1].min**specular_hardness
    specular_color * intensity * specular_power / distance_sq
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
