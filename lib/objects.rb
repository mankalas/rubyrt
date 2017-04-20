require 'color'

class AbstractObject
  attr_reader :centre, :color
  EPS = 1e-6

  def initialize(centre, color)
    @centre = centre
    @color = color
  end
end

class Sphere < AbstractObject
  attr_reader :radius

  def initialize(centre, radius, color = Color::GREEN)
    super(centre, color)
    @radius = radius
  end

  def distance_to_intersection_with(ray)
    distance = -ray.direction.dot(ray.origin - centre)

    radical = ray.direction.dot(ray.origin - centre)**2 -
              (ray.origin - centre).norm**2 +
              radius**2
    return if radical < -EPS

    return distance if radical.abs < EPS
    mult = ray.origin.dot(centre) < 0 ? -1 : 1
    distance + mult * Math.sqrt(radical)
  end
end

class Plane < AbstractObject
  attr_reader :normal

  def initialize(centre, normal, color = Color::WHITE)
    super(centre, color)
    @normal = normal.normalize
  end

  def distance_to_intersection_with(ray)
    denom = normal.dot(ray.direction)
    return if denom.abs < EPS
    d = (centre - ray.origin).dot(normal) / denom
    return d if d > 0
  end
end
