import Foundation

func Point(x: Scalar, y: Scalar, z: Scalar) -> Vector4 {
  return Vector4(x, y, z, 1)
}

func Vector(x: Scalar, y: Scalar, z: Scalar) -> Vector4 {
  return Vector4(x, y, z, 0)
}

extension Matrix4 {
  func blend(_ other: Matrix4, _ amount: Scalar) -> Matrix4 {
    return Matrix4(
      zip(self.toArray(), other.toArray())
        .map{ (values: (Scalar, Scalar)) -> Scalar in
          lerp(values.0, values.1, amount)
        }
    )
  }
}

func Translate(x: Scalar, y: Scalar, z: Scalar) -> Matrix4 {
  return Matrix4(
    1, 0, 0, x,
    0, 1, 0, y,
    0, 0, 1, z,
    0, 0, 0, 1
  ).transpose
}

func ScaleOrigin(x: Scalar, y: Scalar, z: Scalar) -> Matrix4 {
  return Matrix4(
    x, 0, 0, 0,
    0, y, 0, 0,
    0, 0, z, 0,
    0, 0, 0, 1
  ).transpose
}

func RotateX(theta: Scalar) -> Matrix4 {
  return Matrix4(
    1, 0, 0, 0,
    0, cos(theta), -sin(theta), 0,
    0, sin(theta), cos(theta), 0,
    0, 0, 0, 1
  ).transpose
}

func RotateY(theta: Scalar) -> Matrix4 {
  return Matrix4(
    cos(theta), 0, sin(theta), 0,
    0, 1, 0, 0,
    -sin(theta), 0, cos(theta), 0,
    0, 0, 0, 1
  ).transpose
}

func RotateZ(theta: Scalar) -> Matrix4 {
  return Matrix4(
    cos(theta), -sin(theta), 0, 0,
    sin(theta), cos(theta), 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
  ).transpose
}
