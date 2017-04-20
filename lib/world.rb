class Camera
  def initialize(position, direction, focale = 45)
  end
end

class World
  attr_reader :objects, :lights, :height, :width, :image

  def initialize(h, w)
    @height = h
    @width = w
    @objects = []
    @lights = []
    @image = ImageExporter.new(h, w)
  end

  def add(object)
    case object
    when AbstractObject
      objects
    when PointLight
      lights
    end << object
  end

  def first_intersection(ray)
    objects.map { |object| object.intersection_with(ray) }.compact.min_by(&:distance2)
  end

  def light_first_intersection(light, intersection)
    light_direction = intersection.point - light.position
    light_ray = Ray.new(light.position, light_direction)
    first_intersection(light_ray)
  end

  def can_see_intersection?(light_intersection, object_intersection)
    # Light actually intersects with something
    light_intersection &&
      # Light intersects with the correct object
      light_intersection.object == object_intersection.object &&
      # Light intersects close to the view point (not on the other
      # side of the object for instance)
      true#close?(light_intersection.point, object_intersection.point)
  end

  def close?(u, v)
    (0..2).all? { |i| (u[i] - v[i]).abs < EPS }
  end

  def fresnel(direction, normal, refractive_index)
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

  def reflect(ray_direction, normal)
    ray_direction - normal * ray_direction.dot(normal) * 2
  end

  def refract(ray_direction, normal, ior)
    cos_i = ray_direction.dot(normal)
    eta_i = 1
    eta_t = ior
    if cos_i < 0
      cos_i *= -1
    else
      eta_i, eta_t = eta_t, eta_i
      normal *= 1
    end
    eta = eta_i / eta_t
    k = 1 - eta * eta * (1 - cos_i * cos_i)
    k < 0 ? Vec3d.new(0, 0, 0) : ray_direction * eta + normal * (eta * cos_i - Math.sqrt(k))
  end

  def cast_ray(ray, depth = 0, bias = 0.5)
    hit_color = Color::BLACK

    return hit_color if depth > 3

    object_intersection = first_intersection(ray)
    return hit_color if object_intersection.nil?

    hit_object = object_intersection.object
    hit_point = object_intersection.point
    normal = object_intersection.normal
    case hit_object.material_type
    when :reflection_and_refraction
      reflection_direction = reflect(ray.direction, normal).normalize
      refraction_direction = refract(ray.direction, normal, hit_object.refractive_index).normalize

      reflection_ray_origin = reflection_direction.dot(normal) < 0 ?
                                hit_point - normal * bias :
                                hit_point + normal * bias
      refraction_ray_origin = refraction_direction.dot(normal) < 0 ?
                                hit_point - normal * bias :
                                hit_point + normal * bias

      reflection_color = cast_ray(Ray.new(reflection_ray_origin, reflection_direction), depth + 1)
      refraction_color = cast_ray(Ray.new(refraction_ray_origin, refraction_direction), depth + 1)
      kr = fresnel(ray.direction, normal, hit_object.refractive_index)
      hit_color = reflection_color * kr + refraction_color * (1 - kr)
    else
      lights.each do |light_point|
        light_intersection = light_first_intersection(light_point, object_intersection)
        next unless can_see_intersection?(light_intersection, object_intersection)
        light = light_point.lighting(light_intersection, Vec3d.new(ray.direction.x, ray.direction.y, 1), object_intersection.normal)
        next unless light
        hit_color += object_intersection.object.color * (light.diffuse + light.specular)
      end
    end
    hit_color
  end

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    ray_origin = Vec3d.new(0, 0, 0)
    hit_color = cast_ray(Ray.new(ray_origin, Vec3d.new(ray_x, ray_y, 1)))
    hit_color **= 1 / 3.2
    image.set(x, y, hit_color)
  end

  def render
    (0..width - 1).each do |x|
      (0..height - 1).each do |y|
        render_pixel(x, y)
      end
    end
  end
end
