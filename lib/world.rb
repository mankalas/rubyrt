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

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    ray_origin = Vec3d.new(0, 0, 0)
    r = Ray.new(ray_origin, Vec3d.new(ray_x, ray_y, 1))

    object_intersection = first_intersection(r)
    image.set(x, y, Color::BLACK)

    return if object_intersection.nil?
    color = Color::BLACK

    lights.each do |light_point|
      light_intersection = light_first_intersection(light_point, object_intersection)
      next unless can_see_intersection?(light_intersection, object_intersection)
      light = light_point.lighting(light_intersection, Vec3d.new(ray_x, ray_y, 1), object_intersection.normal)
      next unless light
      color += object_intersection.object.color * (light.diffuse + light.specular)
    end

    color **= 1 / 3.2
    image.set(x, y, color)
  end

  def render
    (0..width - 1).each do |x|
      (0..height - 1).each do |y|
        render_pixel(x, y)
      end
    end
  end
end
