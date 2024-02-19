import UIKit

@available(iOS 13.0, *)
let leftArrow =  UIImage(systemName: "arrow.left.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)

@available(iOS 13.0, *)
let rightArrow =  UIImage(systemName: "arrow.right.circle.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 40, weight: .light))?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)

extension UIImage {

    // 이미지 크기 조정
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: 12, height: 12))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}
