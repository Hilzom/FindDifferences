//
//  DynamicPoint.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 18.05.2021.
//

import UIKit

final class Difference {

    private let point: DynamicPoint
    var x: CGFloat {
        point.x
    }
    var y: CGFloat {
        point.y
    }
    let id: UUID
    var isSelected: Bool = false

    init(percents: CGPoint) {
        self.point = .init(percents: percents)
        id = UUID()
    }

    func updateImageSize(with size: CGSize) {
        point.updateImageSize(with: size)
    }
}

extension Difference: Hashable {
    static func == (lhs: Difference, rhs: Difference) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
extension Array where Element: Difference {

    var foundCount: Int {
        filter { $0.isSelected }.count
    }

    var isAllFound: Bool {
        foundCount == count
    }
}

final class DynamicPoint {

    private let xValue: CGFloat
    private let yValue: CGFloat
    private var imageSize: CGSize
    private var widthPercent: CGFloat {
        return imageSize.width / 100
    }

    private var heightPercent: CGFloat {
        return imageSize.height / 100
    }

    var x: CGFloat {
        return xValue * widthPercent
    }
    var y: CGFloat {
        return yValue * heightPercent
    }

    var cgPoint: CGPoint {
        .init(x: x, y: y)
    }

    init(percents: CGPoint, imageSize: CGSize = .zero) {
        xValue = percents.x
        yValue = percents.y

        self.imageSize = imageSize
    }

    func updateImageSize(with size: CGSize) {
        imageSize = size
    }
}

extension Array where Element == Difference {

    func updateImageSize(with size: CGSize) {
        forEach {
            $0.updateImageSize(with: size)
        }
    }
}
