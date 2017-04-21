class Camera
  def initialize(position, direction, focale = 45)
  end
end

class World
  attr_reader :objects, :lights, :height, :width, :image

  def initialize(h = 100, w = 100)
    @height = h
    @width = w
    @objects = []
    @lights = []
    @image = ImageExporter.new(height, width)
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

  def cast_ray(ray, depth = 0, max_depth = 5, bias = 0.00001)
    hit_color = Color::SKY

    return hit_color if depth > max_depth

    hit = first_intersection(ray)
    return hit_color if hit.nil?

    if hit.object.transparency > 0 || hit.object.reflection > 0
      kr = ray.fresnel(hit.normal, hit.object.refractive_index)
      reflection_direction = ray.reflect(hit.normal)
      hit_color = cast_ray(Ray.new(hit.point + hit.normal, reflection_direction), depth + 1) * kr
      if hit.object.transparency > 0
        refraction_direction = ray.refract(hit.normal, hit.object.refractive_index)
        refraction_color = cast_ray(Ray.new(hit.point + hit.normal, refraction_direction), depth + 1)
        hit_color += refraction_color * (1 - kr) * hit.object.transparency
      end
      hit_color *= hit.object.color
    else
      lights.each do |light_point|
        light_intersection = light_first_intersection(light_point, hit)
        next unless can_see_intersection?(light_intersection, hit)
        light = light_point.lighting(light_intersection, Vec3d.new(ray.direction.x, ray.direction.y, 1), hit.normal)
        next unless light
        hit_color = hit.object.color * (light.diffuse * hit.object.kd + light.specular * hit.object.ks)
      end
    end
    hit_color
  end

  def render(fov = 90)
    scale = Math.tan(fov * 0.5 * Math::PI / 180)
    image_aspect_ratio = width / height.to_f
    (0..width - 1).each do |i|
      (0..height - 1).each do |j|
        ray_x = (2 * (i + 0.5) / width.to_f - 1) * image_aspect_ratio * scale # TODO: more rays per pixel
        ray_y = (1 - 2 * (j + 0.5) / height.to_f) * scale
        ray_origin = Vec3d.new(0, 0, 0)
        hit_color = cast_ray(Ray.new(ray_origin, Vec3d.new(ray_x, ray_y, 1)))
        hit_color **= 1 / 2.2
        image.set(i, j, hit_color)
      end
    end
  end
end
