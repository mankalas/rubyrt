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
    @radius2 = radius * radius
  end

  def intersection_with(ray)
    l = centre - ray.origin
    t_ca = l.dot(ray.direction)
    return if t_ca < 0
    d2 = l.dot(l) - t_ca * t_ca
    return if d2 > radius2
    t_hc = Math.sqrt(radius2 - d2)
    t0 = t_ca - t_hc
    t1 = t_ca + t_hc
    return if t0 < 0 && t1 < 0
    Intersection.new(ray, self, [t0, t1].min)
  end

  class Intersection < AbstractIntersection
    def normal
      (point - object.centre).normalize
    end
  end

  private

  attr_reader :radius2
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
