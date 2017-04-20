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
    objects.map { |object| object.intersection_with(ray) }.compact.min_by(&:distance)
  end

  def light_first_intersection(light, intersection)
    light_direction = intersection.point - light.position
    light_ray = Ray.new(light.position, light_direction)
    first_intersection(light_ray)
  end

  def apply_light_to_color(light, intersection)
    intersection.object.color * light.intensity / intersection.distance**2
  end

  def get_specular(light, intensity, distance)
    # puts "#{light.specular_color.inspect} * #{intensity} * #{light.specular_power} / #{distance} = #{(light.specular_color * intensity * light.specular_power / distance).inspect}"
    light.specular_color * intensity * light.specular_power / distance
  end

  def get_diffuse(light, intensity, distance)
    light.diffuse_color * intensity * light.diffuse_power / distance
  end

  def get_lighting_point(light, intersection, view_direction, normal)
    return unless light.diffuse_power > 0

    light_direction = intersection.ray.direction
    distance = intersection.distance**2

    ndotL = normal.dot(light_direction)

    h = (light_direction + view_direction).normalize
    ndotH = [normal.dot(h), 0].max

    Light.new(get_diffuse(light, [ndotL, 1].min, distance),
              get_specular(light, [ndotH, 1].min**42, distance))
  end

  def can_see_intersection?(light_intersection, object_intersection)
    # Light actually intersects with something
    light_intersection &&
      # Light intersects with the correct object
      light_intersection.object == object_intersection.object &&
      # Light intersects close to the view point (not on the other
      # side of the object for instance)
      close?(light_intersection.point, object_intersection.point)
  end

  def close?(u, v)
    (0..2).all? { |i| (u[i] - v[i]).abs < EPS }
  end

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    ray_origin = Vector[0, 0, 0]
    r = Ray.new(ray_origin, Vector[ray_x, ray_y, 1])

    object_intersection = first_intersection(r)
    image.set(x, y, Color::BLACK)

    return if object_intersection.nil?
    color = Color::BLACK

    lights.each do |light|
      light_intersection = light_first_intersection(light, object_intersection)
      next unless can_see_intersection?(light_intersection, object_intersection)
      lighting = get_lighting_point(light, light_intersection, Vector[ray_x, ray_y, 1], object_intersection.normal)
      color += (object_intersection.object.color * light.diffuse_color * light.diffuse_power * (1 / light_intersection.distance**2)) +
               (object_intersection.object.color * lighting.specular)
    end

    image.set(x, y, color**(1 / 2.2))
  end

  def render
    (0..width - 1).each do |x|
      (0..height - 1).each do |y|
        render_pixel(x, y)
      end
    end
  end
end
