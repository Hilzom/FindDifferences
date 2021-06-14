//
//  DiiffenceScrollView.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 18.05.2021.
//

import UIKit

protocol DiiffenceViewDelegate: AnyObject {

    // MARK: - Properties

    var differencePoints: [Difference] { get }
    func differenceDidPress(with model: Difference, view: UIView)
    func viewDidPress(in point: CGPoint)

}

class DiiffenceScrollView: UIScrollView {

    var differences: [Difference: Constraints] = [:]
    weak var customDelegate: DiiffenceViewDelegate?
    private(set) lazy var containerView = getScrollContainer()
    private(set) var differenceViews: [DifferenceView] = []

    private var missclicks: [UIView: Missclicks] = [:]

    override var zoomScale: CGFloat {
        didSet {
            differences.values.forEach {
                $0?.height.constant = Constants.differenceSize * zoomScale
            }
            missclicks.values.forEach {
                $0.constraints?.height.constant = Constants.differenceSize * zoomScale
            }
        }
    }

    required init(delegate: DiiffenceViewDelegate, differences: [Difference]) {
        customDelegate = delegate

        super.init(frame: .zero)

        configureLayout()


        differences.forEach {
            let view = DifferenceView(with: $0)
//            view.backgroundColor = .systemGreen
//            view.accessibilityIdentifier = $0.id.uuidString
            addSubview(view)
//            view.translatesAutoresizingMaskIntoConstraints = false
            let leading = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: $0.x)
            let top = view.topAnchor.constraint(equalTo: topAnchor, constant: $0.y)
            let height = view.heightAnchor.constraint(equalToConstant: Constants.differenceSize)
            height.isActive = true
            leading.isActive = true
            top.isActive = true
            let constraints = Constraints((leading: leading, top: top, height: height))
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(differenceDidPress(_:)))
            view.addGestureRecognizer(tapGesture)
            self.differences[$0] = constraints

            view.widthAnchor.constraint(equalTo: view.heightAnchor).isActive = true
//            view.heightAnchor.constraint(equalToConstant: Constants.differenceSize).isActive = true
            view.clipsToBounds = true
            view.layer.cornerRadius = Constants.differenceSize / 2

            self.differenceViews.append(view)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func differenceDidPress(_ tapGesture: UITapGestureRecognizer) {
        guard let view = tapGesture.view as? DifferenceView else { return }
        guard !view.model.isSelected else { return }
        view.model.isSelected = true
        customDelegate?.differenceDidPress(with: view.model, view: view)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        guard let firstTouch = touches.first?.location(in: self) else { return }
        guard let pressedView = touches.first?.view as? DifferenceView else {
            customDelegate?.viewDidPress(in: firstTouch)
            return
        }
        customDelegate?.differenceDidPress(with: pressedView.model, view: pressedView)
    }

    func updateViews() {
        differences.forEach {
            let difference = $0.key
            $0.value?.leading.constant = difference.x
            $0.value?.top.constant = difference.y
        }
        missclicks.values.forEach {
            let point = $0.point
            point.updateImageSize(with: contentSize)
            $0.constraints?.leading.constant = point.x
            $0.constraints?.top.constant = point.y
        }
    }

    func applyConstraintChages() {
        differenceViews.forEach {
            $0.updateConstraints()
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
        }
        missclicks.keys.forEach {
            $0.updateConstraints()
            $0.setNeedsLayout()
            $0.layoutIfNeeded()
        }
        updateConstraints()
        setNeedsLayout()
        layoutIfNeeded()
    }

    func setSelected(with model: Difference) {
        guard let view = differenceViews.first(where: { $0.model == model }) else { return }
        view.setSelected()
    }

    func configureLayout() {
        containerView = getScrollContainer()
        addSubview(containerView)
        containerView.pin(to: self)
        containerView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        containerView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }

    func missclicked(in point: CGPoint) {
        Vibration.warning.vibrate()
        let dynamicX = point.x / contentSize.width * 100
        let dynamicY = point.y / contentSize.height * 100
        let point = DynamicPoint(percents: .init(x: dynamicX, y: dynamicY), imageSize: contentSize)
        let view = createMissclickView()
        addSubview(view)
        let leading = view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: point.x)
        let top = view.topAnchor.constraint(equalTo: topAnchor, constant: point.y)
        let height = view.heightAnchor.constraint(equalToConstant: Constants.differenceSize)
        leading.isActive = true
        top.isActive = true
        height.isActive = true
        let constraints = Constraints((leading: leading, top: top, height: height))
        let missclick = Missclicks((point: point, constraints: constraints))
        missclicks[view] = missclick
        view.bounceThenDisappears()
    }

    private func getScrollContainer() -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func createMissclickView() -> UIView {
        let imageView = UIImageView()
        imageView.image = R.image.missclickIcon()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemRed
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.layer.cornerRadius = Constants.differenceSize / 2
        imageView.clipsToBounds = true
        return imageView
    }

    // MARK: - Types

    typealias Constraints = (leading: NSLayoutConstraint, top: NSLayoutConstraint, height: NSLayoutConstraint)?
    typealias Missclicks = (point: DynamicPoint, constraints: Constraints)

    private enum Constants {
        static let differenceSize: CGFloat = 40
    }
}










private extension UIView {

    static let leftRotationAngle = CGFloat(7).radians
    static let rightRotationAngle = CGFloat(-7).radians

    func bounceThenDisappears() {
        startPulseAnimation()
        toRight { [weak self] in
            self?.toLeft { [weak self] in
                self?.toRight { [weak self] in
                    self?.toLeft { [weak self] in
                        self?.toRight { [weak self] in
                            self?.toLeft { [weak self] in
                                self?.dissappear()
                            }
                        }
                    }
                }
            }
        }
    }

    private func startPulseAnimation() {
        clipsToBounds = false
        let view = CircledView()
        view.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.15)
        addSubview(view)
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        let widthConstraint = view.widthAnchor.constraint(equalTo: widthAnchor)
        widthConstraint.isActive = true
        setNeedsLayout()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.15) { [weak self] in
            guard let self = self else { return }
            widthConstraint.constant += 50
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            UIView.animate(withDuration: 0.15) {
                view.alpha = .zero
            } completion: { _ in
                view.removeFromSuperview()
            }
        }

    }

    private func dissappear() {
        UIView.animate(withDuration: 0.2) { [ weak self ] in
            self?.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }

    private func toLeft(then: @escaping () -> Void) {
        animate { [weak self] in
            self?.transform = CGAffineTransform.identity.rotated(by: Self.leftRotationAngle)
        } completion: {
            then()
        }
    }

    private func toRight(then: @escaping () -> Void ) {
        animate { [weak self] in
            self?.transform = CGAffineTransform.identity.rotated(by: Self.rightRotationAngle)
        } completion: {
            then()
        }
    }

    private func animate(animation: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.08) {
            animation()
        } completion: { _ in
            completion()
        }
    }
}

private extension CGFloat {

    var radians: CGFloat {
        self * .pi / 180
    }
}
