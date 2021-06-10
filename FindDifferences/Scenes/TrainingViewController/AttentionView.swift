//
//  AttentionView.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit

//final class AttentionView: UIView {
//
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        createOverlay(frame: rect, xOffset: 50, yOffset: 200, radius: 45)
////        let bottomRect = CGRect(
////            origin: CGPoint(x: rect.midX, y: rect.midY),
////            size: CGSize(width: rect.size.width / 2, height: rect.size.height / 2)
////        )
////        backgroundColor = .systemBlue
////        UIColor.systemOrange.set()
////        guard let context = UIGraphicsGetCurrentContext() else { return }
////        context.fillEllipse(in: rect)
////
////        UIColor.clear.set()
////        context.fillEllipse(in: bottomRect)
//////        context.fill(bottomRect)
//    }
//}

extension UIView {

    func createOverlay(to view: UIView) -> (overlay: UIView, hand: UIImageView) {
        // Step 1
        let overlayView = UIView()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(overlayView)
        overlayView.pin(to: self)
        setNeedsLayout()
        layoutIfNeeded()
        overlayView.backgroundColor = Colors.blurBgColor
        // Step 2
        view.superview?.setNeedsLayout()
        view.superview?.layoutIfNeeded()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        let path = CGMutablePath()
        path.addArc(center: view.center,
                    radius: view.frame.width,
                    startAngle: 0.0,
                    endAngle: 2.0 * .pi,
                    clockwise: false)
        path.addRect(CGRect(origin: .zero, size: overlayView.frame.size))
        // Step 3
        let maskLayer = CAShapeLayer()
        maskLayer.backgroundColor = UIColor.black.cgColor
        maskLayer.path = path
        maskLayer.fillRule = .evenOdd
        // Step 4
        overlayView.layer.mask = maskLayer
        overlayView.clipsToBounds = true

        let handView = createHand()
        handView.image = R.image.effect_hand()
        addSubview(handView)
        handView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        handView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        overlayView.layer.zPosition = 100

        return (overlayView, handView)
    }

    func createHand() -> UIImageView {
        let handView = UIImageView()
        handView.contentMode = .scaleAspectFit
        handView.translatesAutoresizingMaskIntoConstraints = false
        handView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        handView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        handView.layer.zPosition = 101
        return handView
    }
}
