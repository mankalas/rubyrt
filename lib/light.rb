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
    specular_hardness = intersection.object.specular_hardness
    Light.new(diffuse_factoring(ndotL, intersection.distance2),
              specular_factoring(ndotH**specular_hardness, intersection.distance2))
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

  def reflect(normal)
    (direction - normal * direction.dot(normal) * 2).normalize
  end

  def refract(normal, refractive_index)
    cos_i = direction.dot(normal)
    eta_i = 1
    eta_t = refractive_index
    if cos_i < 0
      cos_i *= -1
    else
      eta_i, eta_t = eta_t, eta_i
      normal *= 1
    end
    eta = eta_i / eta_t
    k = 1 - eta * eta * (1 - cos_i * cos_i)
    return Vec3d.new(0, 0, 0) if k < 0
    (direction * eta + normal * (eta * cos_i - Math.sqrt(k))).normalize
  end

  def fresnel(normal, refractive_index)
    cos_i = direction.dot(normal)
    eta_i = 1
    eta_t = refractive_index
    eta_i, eta_t = eta_t, eta_i if cos_i > 0
    sin_t = eta_i / eta_t * Math.sqrt([0, 1 - cos_i * cos_i].max)
    return 1 if sin_t >= 1
    cos_t = Math.sqrt([0, 1 - sin_t * sin_t].max)
    cos_i = cos_i.abs
    r_s = ((eta_t * cos_i) - (eta_i * cos_t)) / ((eta_t * cos_i) + (eta_i * cos_t))
    r_p = ((eta_i * cos_i) - (eta_t * cos_t)) / ((eta_i * cos_i) + (eta_t * cos_t))
    (r_s * r_s + r_p * r_p) / 2
  end
end
