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
#    puts "#{light.specular_color.inspect} * #{intensity} * #{light.specular_power} / #{distance} = #{(light.specular_color * intensity * light.specular_power / distance).inspect}"
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
    ndotH = normal.dot(h)

    Light.new(get_diffuse(light, [ndotL, 255].min, distance),
              get_specular(light, [ndotH, 255].min, distance))
  end

  def close(u, v)
    (0..2).all? do |i| (u[i] - v[i]).abs < EPS end
  end

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    r = Ray.new(Vector[0, 0, 0], Vector[ray_x, ray_y, 1])

    intersection = first_intersection(r)
    unless intersection.nil?
      color = Color.new(0, 0, 0)

      lights.each do |light|
        light_intersection = light_intersection(light, intersection.point)
        if close(light_intersection.point, intersection.point)
          lighting = get_lighting_point(light, light_intersection, Vector[ray_x, ray_y, 1], intersection.point)
          color += (intersection.object.color + lighting.specular) # + lighting.diffuse
        end
      end

      image.set(x, y, color.round)
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
[
  PointLight.new(Vector[-4, 0, 1], Color::WHITE, 1, Color::WHITE, 1),
#  Light.new(Vector[0,0,0], 15)
].each { |light| w.add_light(light) }

[
  Sphere.new(Vector[0, 0, 4], 1, Color.new(0, 255, 0)),
#  Sphere.new(Vector[-2, 1, 4], 1, Color.new(111, 2, 23)),
#  Sphere.new(Vector[2, -1, 4], 1.5, Color.new(42, 25, 255))
].each { |obj| w.add(obj) }

w.render
