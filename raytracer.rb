require 'matrix'
require 'byebug'

require 'ppm_image'
require 'objects'
require 'color'

EPS = 1e-9

class PointLight
  attr_reader :position, :diffuse_color, :diffuse_power, :specular_color, :specular_power

  def initialize(position, diffuse_color, diffuse_power, specular_color, specular_power)
    @position = position
    @diffuse_color = diffuse_color
    @diffuse_power = diffuse_power
    @specular_color = specular_color
    @specular_power = specular_power
  end
end

class Light
  attr_reader :diffuse, :specular

  def initialize(diffuse, specular)
    @diffuse = diffuse
    @specular = specular
  end
end

class Camera
  def initialize(position, direction, focale = 45)

  end
end

class Ray
  attr_reader :direction, :origin

  def initialize(origin, direction)
    @origin = origin
    @direction = direction.normalize
  end
end

class Intersection
  attr_reader :ray, :object, :distance, :point

  def initialize(ray, object, distance)
    @ray = ray
    @object = object
    @distance = distance
    @point = ray.direction * distance + ray.origin
  end
end

class World
  attr_reader :objects, :lights, :height, :width, :image

  def initialize(h, w)
    @height = h
    @width = w
    @objects = []
    @lights = []
    @image = PPMImage.new(h, w)
  end

  def add(object)
    objects << object
  end

  def add_light(light)
    lights << light
  end

  def first_intersection(ray)
    objects.map do |object|
      distance = object.distance_to_intersection_with(ray)
      Intersection.new(ray, object, distance) if distance
    end.compact.min_by(&:distance)
  end

  def light_intersection(light, point)
    light_direction = point - light.position
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

  def close(u, v)
    (0..2).all? do |i| (u[i] - v[i]).abs < EPS end
  end

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    r = Ray.new(Vector[0, 0, 0], Vector[ray_x, ray_y, 1])

    intersection = first_intersection(r)
    image.set(x, y, Color::BLACK)

    unless intersection.nil?
      color = Color.new(0, 0, 0)

      lights.each do |light|
        light_intersection = light_intersection(light, intersection.point)
        if close(light_intersection.point, intersection.point)
          normal = (light_intersection.object.center - intersection.point).normalize
          lighting = get_lighting_point(light, light_intersection, Vector[ray_x, ray_y, 1], normal)
          color += (intersection.object.color.mult_color(light.diffuse_color * light.diffuse_power * (1 / light_intersection.distance**2))) +
                   (intersection.object.color.mult_color(lighting.specular))
        end
      end

      image.set(x, y, color**(1/2.2))
    end
  end

  def test
    render_pixel(55, height / 2)
  end

  def render
    (0..width).each do |x|
      (0..height).each do |y|
        render_pixel(x, y)
      end
    end
    image.write('test.ppm')
  end
end

# class Plane < AbstractObject
#   attr_reader :normal

#   def initialize(center, normal)
#     super(center)
#     @normal = normal.normalize
#   end

#   def intersection_with(ray)

#   end
# end

d = 250
w = World.new(d, d)
dif_pow = 20
spe_pow = 32
[
  PointLight.new(Vector[-10, 10, 10], Color::GREEN, dif_pow, Color::GREEN, spe_pow),
  PointLight.new(Vector[0, 10, 7], Color::RED, dif_pow, Color::RED, spe_pow),
  PointLight.new(Vector[10, 10, 10], Color::BLUE, dif_pow, Color::BLUE, spe_pow),
].each { |light| w.add_light(light) }

[
  Sphere.new(Vector[0, 0, 10], 4, Color::WHITE),
  # Sphere.new(Vector[-2, 1, 4], 1, Color.new(0.9, 0, 0)),
  # Sphere.new(Vector[2, -1, 4], 1.5, Color.new(0, 0, 0.9))
].each { |obj| w.add(obj) }

w.render
