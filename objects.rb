class AbstractObject
  attr_reader :centre, :color

  def initialize(centre, color)
    @centre = centre
    @color = color
  end
end

class Sphere < AbstractObject
  attr_reader :radius

  def initialize(centre, radius, color)
    super(centre, color)
    @radius = radius
  end

  def distance_to_intersection_with(ray)
    radical = ray.direction.dot(ray.origin - centre)**2 -
              (ray.origin - centre).norm**2 +
              radius**2
    return if radical < -EPS

    distance = -ray.direction.dot(ray.origin - centre)
    return distance if radical.abs < EPS
    distance - Math.sqrt(radical)
  end
end

class Plane < AbstractObject
  attr_reader :normal

  def initialize(centre, normal, color)
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
