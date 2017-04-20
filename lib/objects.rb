require 'color'

class AbstractObject
  attr_reader :centre, :color
  EPS = 1e-6

  def initialize(centre, color)
    @centre = centre
    @color = color
  end
end

class AbstractIntersection
  attr_reader :ray, :object, :distance, :point

  def initialize(ray, object, distance)
    @ray = ray
    @object = object
    @distance = distance
    @point = ray.direction * distance + ray.origin
  end
end

class Sphere < AbstractObject
  attr_reader :radius

  def initialize(centre, radius, color = Color::GREEN)
    super(centre, color)
    @radius = radius
  end

  def intersection_with(ray)
    dist_from_ray_orig_to_obj_centre = ray.origin - centre
    distance = ray.direction.dot(dist_from_ray_orig_to_obj_centre).abs
    radical = distance**2 - dist_from_ray_orig_to_obj_centre.norm**2 + radius**2

    return if radical < -EPS
    return Intersection.new(ray, self, distance) if radical.abs < EPS

    mult = ray.origin.dot(centre) < 0 ? -1 : 1
    Intersection.new(ray, self, distance + mult * Math.sqrt(radical))
  end

  class Intersection < AbstractIntersection
    def normal
      (point - object.centre).normalize
    end
  end
end

class Plane < AbstractObject
  attr_reader :normal

  def initialize(centre, normal, color = Color::WHITE)
    super(centre, color)
    @normal = normal.normalize
  end

  def intersection_with(ray)
    denom = normal.dot(ray.direction)
    return if denom.abs < EPS
    d = (centre - ray.origin).dot(normal) / denom
    return Intersection.new(ray, self, d) if d > 0
  end

  class Intersection < AbstractIntersection
    def normal
      object.normal
    end
  end
end
