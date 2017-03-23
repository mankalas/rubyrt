require 'matrix'

require 'ppm_image'
require 'objects'

EPS = 1e-9

class Light
  attr_reader :intensity, :origin

  def initialize(origin, intensity = 100)
    @origin = origin
    @intensity = intensity
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
  attr_reader :object, :distance, :point

  def initialize(ray, object, distance)
    @ray = ray
    @object = object
    @distance = distance
    @point = ray.direction * distance
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
    light_direction = point - light.origin
    light_ray = Ray.new(light.origin, light_direction)
    first_intersection(light_ray)
  end

  def apply_light_to_color(light, distance, obj_color, pix_color)
    (0..2).each do |idx|
      pix_color[idx] += [(obj_color[idx] * light.intensity / distance**2).round, 255].min
    end
  end

  def render_pixel(x, y)
    ray_x = (2 * (x + 0.5) / width) - 1 # TODO: more rays per pixel
    ray_y = 1 - 2 * (y + 0.5) / height
    r = Ray.new(Vector[0, 0, 0], Vector[ray_x, ray_y, 1])
    color = [0, 0, 0]

    intersection = first_intersection(r)
    unless intersection.nil?
      lights.each do |light|
        light_intersection = light_intersection(light, intersection.point)
        if light_intersection.object == intersection.object
          apply_light_to_color(light, light_intersection.distance, intersection.object.color, color)
        end
      end
    end
    image.set(x, y, color)
  end

  def render
    h = w = 250
    (0..w).each do |x|
      (0..h).each do |y|
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


w = World.new(250, 250)
[
  Light.new(Vector[-8, 0, -1], 30),
  Light.new(Vector[0,0,0], 15)
].each { |light| w.add_light(light) }

[
  Sphere.new(Vector[0, 1, 10], 4, [0, 234, 32]),
  Sphere.new(Vector[-2, 1, 4], 1, [111, 2, 23]),
  Sphere.new(Vector[2, -1, 4], 1.5, [42, 25, 255])
].each { |obj| w.add(obj) }

w.render
