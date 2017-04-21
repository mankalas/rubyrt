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

  def lighting(intersection, view_direction, normal)
    return unless diffuse_power > 0

    light_direction = intersection.ray.direction
    # TODO: fix this '#abs'
    ndotL = normal.dot(light_direction).abs
    h = (light_direction + view_direction).normalize
    ndotH = [normal.dot(h), 0].max
    Light.new(diffuse_factoring(ndotL, intersection.distance2),
              specular_factoring(ndotH, intersection.distance2))
  end

  def diffuse_factoring(intensity, d2)
    intensity = [intensity, 1].min
    diffuse_color * intensity * diffuse_power / d2
  end

  def specular_factoring(intensity, d2)
    specular_color * intensity * specular_power / d2
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
