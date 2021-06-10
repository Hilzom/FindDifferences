//
//  GameViewController+GameTimerDelegate.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 18.05.2021.
//

import Foundation

extension GameViewController: GameTimerDelegate {

    func timeDidEnd() {
        let popUp = PopUpViewController(with: .gameOver)
        present(popUp, animated: true, completion: nil)
    }

    func timerDidTick(with presentationValue: String) {
        navigationItem.title = presentationValue
    }
}
