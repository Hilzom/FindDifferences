//
//  GameViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

class GameViewController: UIViewController, AppearanceDelegate {

    // MARK: - Properties

    private lazy var animator = Animator(rootView: view)

    private(set) lazy var stackView: UIStackView = {
        let topView = getWrappedView(with: topImage ?? "")
        let bottomView = getWrappedView(with: bottomImage ?? "")
        let stackView = UIStackView(arrangedSubviews: [topView, bottomView])
        stackView.spacing = Constants.imageSpacing
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    private(set) lazy var foundDifferencesView = FoundDifferencesBar(differences: differencePoints)
    private lazy var adsButton: UIImageView = {
        let button = UIImageView()
        button.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(adsButtonDidPress)))
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
        button.heightAnchor.constraint(equalToConstant: 125).isActive = true
        button.contentMode = .scaleAspectFill
        button.image = R.image.show_ad_icon()
        button.isUserInteractionEnabled = true

        return button
    }()
    private let adsLabel: UILabel = {
        let label = UILabel()
        label.text = "Подсказка"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.font = UIFont.systemFont(ofSize: 13)
        label.sizeToFit()
        return label
    }()
    private lazy var adsButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    var darkModeActive = false
    var darkViews: [UIView] = []
    var overlayViews: [UIView?] = []
    var scrollingIsActive = false
    lazy var darkView = getDarkView()
    lazy var navBarDarkView = getDarkView()

    private(set) var currentImage: UIImage?

    private var zoomScaleLabels: [UIButton] = []
    private var wrappers: [UIView] = []
    private(set) var scrollViews: [DiiffenceScrollView] = []
    private(set) var differencePoints: [Difference]
    private let topImage: String?
    private let bottomImage: String?

    private lazy var timer = GameTimer(delegate: self)
    var currentZoomScaleValue: CGFloat = .zero {
        didSet {
            let value = Int(currentZoomScaleValue * 100)
            let presentationValue = String(value) + "%"
            let isHidden = value == 100
            zoomScaleLabels.forEach {
                $0.setTitle(presentationValue, for: .normal)
                $0.isHidden = isHidden
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        configureColors()
        configureLayout()
        configureNavBar()
        currentZoomScaleValue = 1
        timer.resume()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        timer.resume()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        timer.pause()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        guard let wrapperSize = scrollViews.first?.contentSize else { return }
        differencePoints.updateImageSize(with: wrapperSize)
        scrollViews.forEach { $0.updateViews() }
        scrollViews.forEach { $0.updateConstraints() }
    }

    // MARK: - Init

    required init(differencePoints: [Difference], topImage: String, bottomImage: String) {
        self.topImage = topImage
        self.bottomImage = bottomImage
        self.differencePoints = differencePoints

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.topImage = nil
        self.bottomImage = nil
        fatalError()
    }

    // MARK: - Private functions

    func configureColors() {
        view.backgroundColor = Colors.bgColor
        adsLabel.textColor = Colors.textColor
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): Colors.textColor]
        foundDifferencesView.reload()
    }

    func configureLayout() {
        view.addSubview(darkView)
        view.addSubview(stackView)
        view.addSubview(foundDifferencesView)
        view.addSubview(adsButtonContainer)
        adsButtonContainer.addSubview(adsButton)
        view.addSubview(navBarDarkView)

        NSLayoutConstraint.activate([
            foundDifferencesView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            foundDifferencesView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.contentTopMargin),
            foundDifferencesView.heightAnchor.constraint(equalToConstant: 20),

            stackView.topAnchor.constraint(equalTo: foundDifferencesView.bottomAnchor, constant: Constants.contentTopMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),

            adsButtonContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            adsButtonContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            adsButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            adsButtonContainer.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 15),

            adsButton.centerXAnchor.constraint(equalTo: adsButtonContainer.centerXAnchor),
            adsButton.centerYAnchor.constraint(equalTo: adsButtonContainer.centerYAnchor)
        ])

        NSLayoutConstraint.activate([
            darkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            darkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            darkView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            darkView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            navBarDarkView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBarDarkView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            navBarDarkView.topAnchor.constraint(equalTo: view.topAnchor),
            navBarDarkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        let imageSize = currentImage?.size ?? .init(width: 1, height: 1)
        let stackWidth = view.frame.width - 10

        let asceptRatio = imageSize.height / imageSize.width

        let stackHeight = stackWidth * asceptRatio
        print(imageSize.width, imageSize.height, stackWidth, asceptRatio, stackHeight)
        scrollViews.forEach {
            $0.heightAnchor.constraint(equalToConstant: stackHeight).isActive = true
        }
    }

    func getScrollView(with name: String) -> DiiffenceScrollView {
        let scrollView = DiiffenceScrollView(delegate: self, differences: differencePoints)
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

    func differenceDidPress(with model: Difference, view: UIView) {
        Vibration.light.vibrate()
        disableDarkBGIfNeeded()
        if let toView = foundDifferencesView.currentView {
            animator.animateFound(from: view, to: toView)
        }
        scrollViews.forEach { $0.setSelected(with: model) }
        foundDifferencesView.reload()

        guard differencePoints.isAllFound else { return }
        let winVC = WinViewController()
        winVC.modalPresentationStyle = .fullScreen
        winVC.modalTransitionStyle = .crossDissolve
        present(winVC, animated: true, completion: nil)
    }

    private func configureNavBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Пауза", style: .plain, target: self, action: #selector(pauseDidPress))
    }

    @objc
    private func pauseDidPress() {
        presentPopUp(type: .pause)
    }

    @objc
    private func adsButtonDidPress() {
        guard !darkModeActive else { return }
        guard !UserDefaultsDataProvider.isPremium else {
            enableDarkBG()
            return
        }
        presentPopUp(type: .noVideoAd)
    }

    private func presentPopUp(type: PopUpViewController.PopUpType) {
        timer.pause()
        let popUp = PopUpViewController(with: type)
        popUp.onCloseCompletion = timer.resume
        present(popUp, animated: true, completion: nil)
    }

    // MARK: - Types

    enum Constants {
        static let imageSpacing: CGFloat = 16
        static let contentTopMargin: CGFloat = 16
        static let timerInterval = 2 * 60 + 1 // +1 потому что во viewDidLoad вызываю
    }

    deinit {
        print("hehe GameViewController deinit")
    }

    private func disableDarkBGIfNeeded() {
        guard darkModeActive else { return }
        zoomScaleLabels.forEach { $0.isHidden = false }
        disableDarkBG()
    }

    func enableDarkBG() {
        scrollViews.forEach { $0.zoomScale = 1 }
        zoomScaleLabels.forEach { $0.isHidden = true }
        darkModeActive = true
        darkViews.forEach {
            $0.alpha = 0
            $0.backgroundColor = Colors.blurBgColor
        }

        let diffViews = getNextDiffViews()
        for (index, view) in self.stackView.arrangedSubviews.enumerated() {
            let container = view.subviews.first
            let diffView = diffViews[index]
            guard let (overlay, hand) = container?.createOverlay(to: diffView) else { continue }
            container?.sendSubviewToBack(overlay)
            overlay.alpha = .zero
            hand.alpha = .zero
            overlayViews.append(overlay)
        }
        view.setNeedsLayout()
        view.layoutIfNeeded()

        showViews(completion: {})
    }

    func getNextDiffViews() -> [UIView] {
        return scrollViews.compactMap { $0.differenceViews.first(where: { !$0.model.isSelected }) }
    }

    func showViews(completion: @escaping () -> Void) {
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
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } completion: { _ in
            completion()
        }
    }

    func disableDarkBG() {
        darkModeActive = false
        clearAllViews { [weak self] in
            self?.enableScrollingMode()
        }
    }

    func clearAllViews(completion: @escaping () -> Void) {
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
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        } completion: {  [weak self] _ in
            guard let self = self else { return }
            (self.darkViews + self.overlayViews).forEach {
                guard !(self.darkView == $0 || self.navBarDarkView == $0) else { return }
                $0?.removeFromSuperview()
            }
            completion()
        }
    }

    func disableScrollingMode() {
        scrollViews.forEach { $0.isScrollEnabled = false }
        scrollingIsActive = false
        clearAllViews(completion: {})
    }

    func enableScrollingMode() {
        scrollViews.forEach { $0.isScrollEnabled = true }
        scrollingIsActive = true
        clearAllViews(completion: {})
    }

    private func getDarkView() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        darkViews.append(view)
        return view
    }
}

extension GameViewController {

    // MARK: - Fabric functions

//    private func getFoundButton() -> UIButton {
//        let button = UIButton()
//        button.
//        return button
//    }

    private func getWrappedView(with name: String) -> UIView {
        let wrapper = UIView()
        let scrollView = getScrollView(with: name)
        let button = getZoomScaleButton()

        wrapper.addSubview(scrollView)
        wrapper.addSubview(button)

        scrollView.pin(to: wrapper)

        button.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        button.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true

        zoomScaleLabels.append(button)
        wrappers.append(wrapper)
        scrollViews.append(scrollView)
        return wrapper
    }

    private func getZoomScaleButton() -> UIButton {
        let button = UIButton()
//        button.titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        button.backgroundColor = .init(white: 0.9, alpha: 0.95)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 40).isActive = true
        button.heightAnchor.constraint(equalToConstant: 20).isActive = true
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        button.clipsToBounds = true
        button.layer.cornerRadius = 8
        button.isUserInteractionEnabled = false
        return button
    }

    func getImageView(with name: String) -> UIImageView {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: name)
        imageView.image = image
        self.currentImage = image
        return imageView
    }
}

extension GameViewController: DiiffenceViewDelegate {
    func viewDidPress(in point: CGPoint) {
        scrollViews.forEach { $0.missclicked(in: point) }
        timer.touchFailed()
    }
}


final class Animator {

    let rootView: UIView
    private let containerSize: CGFloat = 30
    private let elementSize: CGFloat = 3.5
    private let fadeInAnimation: TimeInterval = 0.05
    private let fadeOutAnimation: TimeInterval = 1.2
    private let numberofElements = 0...10

    func animateFound(from: UIView, to: UIView) {
        let fromPoint = from.bounds.origin
        let toPoint = to.bounds.origin
        let convertedFrom = from.convert(fromPoint, to: nil)
        let convertedTo = to.convert(toPoint, to: nil)

        let yDiff = convertedFrom.y - convertedTo.y
        let xDiff = convertedTo.x - convertedFrom.x

        let countOfAnimation = Int(round(yDiff / containerSize))
        let xDiffPerFrame = Int(round(xDiff)) / countOfAnimation

        var animationViews: [UIView] = []
        for index in 0..<countOfAnimation {
            let animation = createAnimatedSquare(for: index)
            rootView.addSubview(animation)
            let previousIndex = index - 1
            let previousView = animationViews.indices.contains(previousIndex) ? animationViews[previousIndex] : from
            animationViews.append(animation)
            animation.bottomAnchor.constraint(equalTo: previousView.topAnchor).isActive = true
            animation.centerXAnchor.constraint(equalTo: previousView.centerXAnchor, constant: CGFloat(xDiffPerFrame)).isActive = true
        }
    }

    private func createAnimatedSquare(for index: Int) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        var topConstraints: [NSLayoutConstraint] = []
        var views: [UIView] = []
        numberofElements.forEach { _ in
            let view = createOneAnimationElement()
            let top = randomlyPlaceViewInContainer(view: view, container: container)
            topConstraints.append(top)
            views.append(view)
        }
        container.widthAnchor.constraint(equalTo: container.heightAnchor).isActive = true
        container.heightAnchor.constraint(equalToConstant: containerSize).isActive = true
        container.clipsToBounds = false

        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(index * 40)) { [weak self] in
            self?.fadeIn(views: views) { [weak self] in
                self?.fadeOut(views: views, topConstraints: topConstraints) {
//                    print("completion")
                }
            }
        }
        return container
    }

    private func createOneAnimationElement() -> UIView {
        let view = UIView()
        let randomRed: CGFloat = .random(in: 0...1)
        let randomAlpha: CGFloat = .random(in: 0.7...1)
        view.backgroundColor = UIColor(red: randomRed, green: 1, blue: .zero, alpha: randomAlpha)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: elementSize).isActive = true
        view.clipsToBounds = true
        view.layer.cornerRadius = elementSize / 2
        view.alpha = .zero
        return view
    }

    private func randomlyPlaceViewInContainer(view: UIView, container: UIView) -> NSLayoutConstraint {
        container.addSubview(view)
        let maxX = containerSize - elementSize / 2
        let rangeX: CGFloat = .random(in: .zero...maxX)
        let rangeY: CGFloat = .random(in: .zero...maxX)
        let leading = view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: rangeX)
        let top = view.topAnchor.constraint(equalTo: container.topAnchor, constant: rangeY)

        NSLayoutConstraint.activate([
            leading,
            top
        ])
        return top
    }

    init(rootView: UIView) {
        self.rootView = rootView
    }
}

extension Animator {

    // MARK: - Animations

    private func fadeIn(views: [UIView], completion: @escaping () -> Void ) {
        UIView.animate(withDuration: fadeInAnimation) {
            views.forEach { $0.alpha = 1 }
        } completion: { _ in
            completion()
        }
    }

    private func fadeOut(views: [UIView], topConstraints: [NSLayoutConstraint], completion: @escaping () -> Void) {
        UIView.animate(withDuration: fadeOutAnimation) {
            views.forEach { $0.alpha = .zero }
            topConstraints.forEach { $0.constant += 40 }
            views.forEach { $0.superview?.setNeedsLayout(); $0.superview?.layoutIfNeeded() }
        } completion: { _ in
            views.first?.superview?.removeFromSuperview()
            views.forEach { $0.removeFromSuperview() }
            completion()
        }
    }
}

private extension CGPoint {

//    func distance( _ to: CGPoint) -> CGFloat {
//        let xDist = self.x - to.x
//        let yDist = self.y - to.y
//        return CGFloat(sqrt(xDist * xDist + yDist * yDist))
//    }

    func distance(_ to: CGPoint) -> CGFloat {
        return sqrt((self.x - to.x) * (self.x - to.x) + (self.y - to.y) * (self.y - to.y))
    }

//    func CGPointDistance(from: CGPoint, to: CGPoint) -> CGFloat {
//        return sqrt(CGPointDistanceSquared(from: from, to: to))
//    }

    func angle(to comparisonPoint: CGPoint) -> CGFloat {
        let originX = comparisonPoint.x - x
        let originY = comparisonPoint.y - y
        let bearingRadians = atan2f(Float(originY), Float(originX))
        var bearingDegrees = CGFloat(bearingRadians).degrees

        while bearingDegrees < 0 {
            bearingDegrees += 360
        }

        return bearingDegrees
    }
}

extension CGFloat {
    var degrees: CGFloat {
        return self * CGFloat(180) / .pi
    }
}
