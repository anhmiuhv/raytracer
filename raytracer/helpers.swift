import Foundation
import Cocoa

func writePPM(file: String, pixels: [[Color]]) {
  try! ("P3\n" +
    "\(pixels.first?.count ?? 0) \(pixels.count)\n" +
    "255\n" +
    pixels.map { (row: [Color]) -> String in
      return row.map { (c: Color) -> String in
        return "\(Int(c.r*255)) \(Int(c.g*255)) \(Int(c.b*255))"
        }.joined(separator: "\n")
      }.joined(separator: "\n")
    ).write(toFile: file, atomically: true, encoding: String.Encoding.utf8)
}

struct PixelData {
  let a:UInt8 = 255
  let r, g, b: UInt8
}
func writePNG(file: String, pixels: [[Color]]) {
  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
  
  let bitsPerComponent:UInt = 8
  let bitsPerPixel:UInt = 32
  
  let width = pixels.first!.count
  let height = pixels.count
  var data = pixels.joined().map{PixelData(
    r: UInt8($0.r*255),
    g: UInt8($0.g*255),
    b: UInt8($0.b*255)
  )}
  
  let providerRef = CGDataProvider(
    data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)
  )!
  
  let cgim = CGImage(
    width: width,
    height: height,
    bitsPerComponent: Int(bitsPerComponent),
    bitsPerPixel: Int(bitsPerPixel),
    bytesPerRow: width * Int(MemoryLayout<PixelData>.size),
    space: rgbColorSpace,
    bitmapInfo: bitmapInfo,
    provider: providerRef,
    decode: nil,
    shouldInterpolate: true,
    intent: CGColorRenderingIntent.defaultIntent
  )
  
  let image = NSImage(cgImage: cgim!, size: NSSize(width: width, height: height))
  (NSBitmapImageRep(data: image.tiffRepresentation!)!
    .representation(using: NSBitmapImageFileType.PNG, properties: [:])!
   as NSData).write(toFile: file, atomically: true)
}

func rand(_ low: Scalar, _ high: Scalar) -> Scalar {
  return low + (high-low)*(Float(arc4random()) / Float(UINT32_MAX))
}

func lerp(_ from: Scalar, _ to: Scalar, _ amount: Scalar) -> Scalar {
  return ((1-amount)*from) + (amount*to)
}

func lerpColor(_ from: Color, _ to: Color, _ amount: Scalar) -> Color {
  return Color(
    r: ((1-amount)*from.r) + (amount*to.r),
    g: ((1-amount)*from.g) + (amount*to.g),
    b: ((1-amount)*from.b) + (amount*to.b)
  )
}

func blendColors(_ from: Color, _ to: Color) -> Color {
  return lerpColor(from, to, 0.5)
}

func lerpColor(_ from: Int, _ to: Int, _ amount: Scalar) -> Color {
  let fromColor = Color(from)
  let toColor = Color(to)
  return lerpColor(fromColor, toColor, amount)
}

func shell(_ args: String...) -> Int32 {
  let task = Process()
  task.launchPath = "/usr/bin/env"
  task.arguments = args
  task.launch()
  task.waitUntilExit()
  return task.terminationStatus
}

extension Array {
  func chunk(_ chunkSize: Int) -> Array<Array<Element>> {
    return stride(from: 0, to: self.count, by: chunkSize).map {
      Array(self[$0..<($0 + chunkSize)])
    }
  }
  
  func concurrentMap<U>(transform: @escaping (Element) -> U, callback: @escaping (Array<U>) -> ()) {
    let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.default)
    let group = DispatchGroup()
    
    let sync = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    //var index = 0
    
    let r = transform(self[0] as Element)
    var results = Array<U>(repeating:r, count: self.count)
    
    for (index, item) in enumerated() {
      queue.async(group: group) {
        let r = transform(item as Element)
        sync.sync() {
          results[index] = r
        }
      }
    }
    
    group.notify(queue: sync) {
      callback(results)
    }
  }
}
