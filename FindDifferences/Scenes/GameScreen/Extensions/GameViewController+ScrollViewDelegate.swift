//
//  GameViewController+ScrollViewDelegate.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

extension GameViewController: UIScrollViewDelegate {

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let containerView = scrollView.subviews.first
        let imageView = containerView?.subviews.first
        return imageView
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        synchronizeScrollViewZoom(scrollView)
        scrollViews.forEach { $0.applyConstraintChages() }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollViews.first(where: { $0.isZooming }) == nil else { return }
        synchronizeScrollView(scrollView)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        guard let scrollView = touches.first?.view as? UIScrollView else { return }
        synchronizeScrollView(scrollView)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let scrollView = touches.first?.view as? UIScrollView else { return }
        synchronizeScrollView(scrollView)
    }

    private func synchronizeScrollView(_ scrollView: UIScrollView) {
        guard let otherScrollView = scrollViews.filter( { !($0 == scrollView) }).first else { return }
        otherScrollView.zoomScale = scrollView.zoomScale
        currentZoomScaleValue = scrollView.zoomScale
        otherScrollView.delegate = nil
        otherScrollView.contentOffset = scrollView.contentOffset
        otherScrollView.delegate = self
        guard let wrapperSize = scrollViews.first?.contentSize else { return }
        differencePoints.updateImageSize(with: wrapperSize)
        scrollViews.forEach { $0.updateViews() }
        scrollViews.forEach { $0.updateConstraints() }
    }

    private func synchronizeScrollViewZoom(_ scrollView: UIScrollView) {
        guard let otherScrollView = scrollViews.filter( { !($0 == scrollView) }).first else { return }
        otherScrollView.zoomScale = scrollView.zoomScale
        currentZoomScaleValue = scrollView.zoomScale
        if !otherScrollView.isZooming {
            otherScrollView.delegate = nil
            otherScrollView.contentOffset = scrollView.contentOffset
            otherScrollView.delegate = self
        }
        guard let wrapperSize = scrollViews.first?.contentSize else { return }
        differencePoints.updateImageSize(with: wrapperSize)
        scrollViews.forEach { $0.updateViews() }
        scrollViews.forEach { $0.updateConstraints() }
    }
}
