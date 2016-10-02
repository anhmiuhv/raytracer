import Foundation

let file = "test.ppm"

writePPM(
  file: file,
  pixels: Raytracer(
    width: 4,
    height: 2,
    distance: 1,
    surface: SurfaceList(surfaces: [
      Sphere(
        center: Point(x: 0, y: 0, z: -1),
        radius: 0.5
      ),
      Sphere(
        center: Point(x: 0, y: -100.5, z: -1),
        radius: 100
      )
    ])
  ).render(
    w: 200,
    h: 100
  )
)

let _ = shell("open", file)

print("Done!")
