//
//  TrainingViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit

final class TrainingViewController: GameViewController {

    var firstDifferences: [UIView] {
        scrollViews.compactMap { $0.differenceViews[1] }
    }
    var hands: [UIImageView] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    private var needsToShowDarkMode = true

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard needsToShowDarkMode else { return }
        needsToShowDarkMode = false
        enableDarkBG()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        darkViews.forEach { $0.removeFromSuperview() }
    }

//    override func configureLayout() {
//        view.addSubview(darkView)
//        view.addSubview(stackView)
//        view.addSubview(foundDifferencesView)
//        view.addSubview(navBarDarkView)
//
////        firstDifferences.forEach { $0.superview?.bringSubviewToFront($0) }
//
//
////        firstDifferences.forEach { $0.superview?.bringSubviewToFront($0) }
//
//
//        NSLayoutConstraint.activate([
//            foundDifferencesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            foundDifferencesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.contentTopMargin),
//            foundDifferencesView.heightAnchor.constraint(equalToConstant: 20),
//
//            stackView.topAnchor.constraint(equalTo: foundDifferencesView.bottomAnchor, constant: Constants.contentTopMargin),
//            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
//            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5)
//        ])
//
//        NSLayoutConstraint.activate([
//            darkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            darkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            darkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            darkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
//
//            navBarDarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            navBarDarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            navBarDarkView.topAnchor.constraint(equalTo: view.topAnchor),
//            navBarDarkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
//        ])
//        let imageSize = currentImage?.size ?? .init(width: 1, height: 1)
//        let stackWidth = view.frame.width - 10
//
//        let asceptRatio = imageSize.height / imageSize.width
//
//        let stackHeight = stackWidth * asceptRatio
//        print(imageSize.width, imageSize.height, stackWidth, asceptRatio, stackHeight)
//        scrollViews.forEach {
//            $0.heightAnchor.constraint(equalToConstant: stackHeight).isActive = true
//        }
//        currentZoomScaleValue = 1
//    }

    override func getScrollView(with name: String) -> DiiffenceScrollView {
        let scrollView = TrainingScrollView(delegate: self, differences: differencePoints)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.bouncesZoom = false
        scrollView.bounces = false
        scrollView.delegate = self
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false



        let imageView = getImageView(with: name)
        scrollView.containerView.addSubview(imageView)
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.pin(to: scrollView.containerView)

        return scrollView
    }

    override func clearAllViews(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.darkViews.forEach {
                $0.alpha = 0
                $0.superview?.setNeedsLayout()
                $0.superview?.layoutIfNeeded()
            }
            self.overlayViews.forEach {
                $0?.alpha = 0
                $0?.superview?.setNeedsLayout()
                $0?.superview?.layoutIfNeeded()
            }
            self.hands.forEach {
                $0.alpha = 0
                $0.superview?.setNeedsLayout()
                $0.superview?.layoutIfNeeded()
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } completion: {  [weak self] _ in
            guard let self = self else { return }
            (self.darkViews + self.overlayViews + self.hands).forEach { $0?.removeFromSuperview() }
            completion()
        }
    }

    override func showViews(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return}
            self.darkViews.forEach {
                $0.alpha = 1
                $0.superview?.setNeedsLayout()
                $0.superview?.layoutIfNeeded()
            }
            self.overlayViews.forEach {
                $0?.alpha = 1
                $0?.superview?.setNeedsLayout()
                $0?.superview?.layoutIfNeeded()
            }
            self.hands.forEach {
                $0.alpha = 1
                $0.superview?.setNeedsLayout()
                $0.superview?.layoutIfNeeded()
            }
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    override func enableScrollingMode() {
        var scrollingHands: [UIImageView] = []
        let firstFrame = R.image.scrolling_first_frame()
        let secondFrame = R.image.scrolling_second_frame()
        let handMargin: CGFloat = 10
        scrollingIsActive = true
        for view in self.stackView.arrangedSubviews {
            //            let container = view.subviews.first
            let hand = view.createHand()
            hand.image = firstFrame
            view.addSubview(hand)
            hand.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -handMargin).isActive = true
            hand.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -handMargin).isActive = true
            hand.alpha = .zero
            hands.append(hand)
            scrollingHands.append(hand)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()
        showViews {
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                while self.scrollingIsActive {
                    self.checkIsPresenting()
                    scrollingHands.update(with: firstFrame)
                    usleep(300000)
                    scrollingHands.update(with: secondFrame)
                    usleep(300000)
                }
            }
        }
    }

    override func disableScrollingMode() {
        scrollingIsActive = false
        clearAllViews(completion: {})
    }

    private func disableScrollingModeIfNeeded() {
        guard scrollingIsActive else { return }
        disableScrollingMode()
    }
}

extension TrainingViewController {

    private func checkIsPresenting() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            guard self.navigationController?.viewControllers.contains(self) == true else {
                self.scrollingIsActive = false
                return
            }
        }
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        disableScrollingModeIfNeeded()
    }
}

private extension Array where Element: UIImageView {

    func update(with image: UIImage?) {
        DispatchQueue.main.async {
            forEach { $0.image = image }
        }
    }
}
