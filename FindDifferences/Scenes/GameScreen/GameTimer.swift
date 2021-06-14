//
//  GameTimer.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 18.05.2021.
//

import Foundation

protocol GameTimerDelegate: AnyObject {

    // MARK: - Functions

    func timerDidTick(with presentationValue: String)
    func timeDidEnd()
}

final class GameTimer {

    private var timer: Timer?
    private var totalTime: Int
    private var isTimerPaused: Bool = true {
        didSet {
            guard !isTimerPaused else {
                timer?.invalidate()
                timer = nil
                return
            }
            recreateTimer()
        }
    }
    private weak var delegate: GameTimerDelegate?
    private var numberOfFailedTouches: Int = .zero

    init(totalTime: Int = 120, delegate: GameTimerDelegate) {
        self.delegate = delegate
        self.totalTime = totalTime
    }

    // MARK: - Functions

    func pause() {
        isTimerPaused = true
    }

    func resume() {
        isTimerPaused = false
    }

    func touchFailed() {
        totalTime -= getAndIncrementFailedTouchSanction()
        timer?.fire()
    }

    // MARK: - Private functions

    @objc
    private func timerDidTick() {
        guard totalTime > 0 else {
            invalidate()
            delegate?.timeDidEnd()
            return
        }
        guard !isTimerPaused else { return }
        let seconds = totalTime % 60
        let minutes = (totalTime - seconds) / 60
        let secondsValue = getSecondsToPresent(from: seconds)
        let value = "\(minutes):\(secondsValue)"
        delegate?.timerDidTick(with: value)
        totalTime -= 1
    }

    private func getSecondsToPresent(from seconds: Int) -> String {
        switch seconds {
        case .zero:
            return "00"

        case 1, 2, 3, 4, 5, 6, 7, 8, 9:
            return "0\(seconds)"

        default:
            return "\(seconds)"
        }
    }

    private func invalidate() {
        timer?.invalidate()
        timer = nil
    }

    private func recreateTimer() {
        invalidate()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerDidTick), userInfo: nil, repeats: true)
        guard let timer = timer else { return }
        RunLoop.main.add(timer, forMode: .common)
        timer.fire()
    }

    private func getAndIncrementFailedTouchSanction() -> Int {
        defer { numberOfFailedTouches += 1 }
        switch numberOfFailedTouches {
        case 0: return 10
        case 1: return 15
        case 2: return 20
        case 3: return 25
        default: return 30
        }
    }
}
