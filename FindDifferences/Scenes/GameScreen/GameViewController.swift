//
//  GameViewController.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 14.05.2021.
//

import UIKit

class GameViewController: UIViewController {

    // MARK: - Properties

    private lazy var animator = Animator(rootView: view)

    private(set) lazy var stackView: UIStackView = {
        let topView = getWrappedView(with: "level_1_top_image")
        let bottomView = getWrappedView(with: "level_1_bottom_image")
        let stackView = UIStackView(arrangedSubviews: [topView, bottomView])
        stackView.spacing = Constants.imageSpacing
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()
    private(set) lazy var foundDifferencesView = FoundDifferencesBar(differences: differencePoints)
    private lazy var adsButton: UIButton = {
        let button = UIButton.getSquaredButton(with: 80).withDisabledHighlight()
        button.setImage(R.image.remove_ads_icon(), for: .normal)
        button.addTarget(self, action: #selector(adsButtonDidPress), for: .touchUpInside)
        let offset = adsLabel.frame.height + 5
        button.imageEdgeInsets = .init(top: offset, left: offset, bottom: offset, right: offset)

        button.addSubview(adsLabel)
        adsLabel.bottomAnchor.constraint(equalTo: button.bottomAnchor).isActive = true
        adsLabel.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true

        return button
    }()
    private let adsLabel: UILabel = {
        let label = UILabel()
        label.text = "Подсказка"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.sizeToFit()
        return label
    }()
    private lazy var adsButtonContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()


    private var zoomScaleLabels: [UIButton] = []
    private var wrappers: [UIView] = []
    private(set) var scrollViews: [DiiffenceScrollView] = []
    private(set) var differencePoints: [Difference]

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

    required init(differencePoints: [Difference]) {
        self.differencePoints = differencePoints

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Private functions

    private func configureColors() {
        view.backgroundColor = Colors.backgroundLight
    }

    func configureLayout() {
        view.addSubview(stackView)
        view.addSubview(foundDifferencesView)
        view.addSubview(adsButtonContainer)
        adsButtonContainer.addSubview(adsButton)

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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Pause", style: .plain, target: self, action: #selector(pauseDidPress))
    }

    @objc
    private func pauseDidPress() {
        timer.pause()
        let popUp = PopUpViewController(with: .pause)
        popUp.onCloseCompletion = timer.resume
        present(popUp, animated: true, completion: nil)
    }

    @objc
    private func adsButtonDidPress() {
        print("hehe ", #function)
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
        imageView.image = UIImage(named: name)
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
