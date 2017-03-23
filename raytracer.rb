require 'matrix'

EPS = 1e-9

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

class AbstractObject
  attr_reader :center

  def initialize(center)
    @center = center
  end
end

class Sphere < AbstractObject
  attr_reader :radius, :color

  def initialize(center, radius, color)
    super(center)
    @radius = radius
    @color = color
  end

  def distance_to_intersection_with(ray)
    radical = ray.direction.dot(ray.origin - center)**2 -
              (ray.origin - center).norm**2 +
              radius**2
    return nil if radical < -EPS

    distance = -ray.direction.dot(ray.origin - center)
    return distance if radical.abs < EPS
    distance - Math.sqrt(radical)
  end
end

class World
  attr_reader :objects

  def initialize
    @objects = []
  end

  def add(object)
    objects << object
  end

  def render
    h = w = 250
    image = PPMImage.new(h, w)
    (0..w).each do |x|
      (0..h).each do |y|
        ray_x = (2 * (x + 0.5) / w) - 1
        ray_y = 1 - 2 * (y + 0.5) / h
        r = Ray.new(Vector[0, 0, 0], Vector[ray_x, ray_y, 1].normalize)

        qwe = Hash[
          objects.map do |object|
            [object, object.distance_to_intersection_with(r)]
          end
        ].reject { |k, v| v.nil? }
        color = if qwe.empty?
                  [0,0,0]
                else
                  obj = qwe.min_by { |_, v| v }[0]
                  obj.color
                end
        image.set(x, y, color)
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

#   def intersections_with(ray)

#   end
# end

class PPMImage
  attr_reader :height, :width

  def initialize(h, w)
    @height = h
    @width = w
    @data = [[0,0,0]] * h * w
  end

  def index_at_point(x, y)
    x + (y * width)
  end

  def set(x, y, color)
    @data[index_at_point(x, y)] = color
  end

  def write(file_name)
    File.open(file_name, 'w') do |file|
      file.write("P3\n")
      file.write("# test\n")
      file.write("#{width} #{height}\n")
      file.write("255\n")
      @data.each_with_index do |pixel, idx|
        file.write("#{pixel[0]} #{pixel[1]} #{pixel[2]} ")
      end
    end
  end
end

s  = Sphere.new(Vector[0, 5, 6], 3, [0, 234, 32])
s1 = Sphere.new(Vector[0, 2, 7], 2, [111, 2, 23])
w = World.new
w.add(s)
w.add(s1)
w.render
