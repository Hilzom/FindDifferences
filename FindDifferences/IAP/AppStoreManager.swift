//
//  AppStoreManager.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 06.06.2021.
//

import Foundation
import StoreKit


protocol AppStoreManagerDelegate: AnyObject {
    func productsLoaded()
}

protocol AppStoreObserverDelegate: AnyObject {
    func productsPurchased(id: String)
}

final class AppStoreManager: NSObject {
    static let shared = AppStoreManager()

    // Keep a strong reference to the product request.
    var request: SKProductsRequest!
    weak var delegate: AppStoreManagerDelegate?

    func validate(productIdentifiers: [String]) {
        let productIdentifiers = Set(productIdentifiers)

        request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }

    var products = [SKProduct]()
    // SKProductsRequestDelegate protocol method.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            products = response.products
        }
        products.forEach { print($0.localizedTitle, $0.description, $0.price) }
        DispatchQueue.main.async {
            self.delegate?.productsLoaded()
        }
    }

    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension AppStoreManager: SKProductsRequestDelegate {
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("0", error)
    }

    func requestDidFinish(_ request: SKRequest) {
        print("1", request)
    }
}

final class AppStoreManagerObserver: NSObject {
    static let shared = AppStoreManagerObserver()
    weak var delegate: AppStoreObserverDelegate?
    override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }
}

extension AppStoreManagerObserver: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        transactions.forEach {
            let productId = $0.payment.productIdentifier
            switch $0.transactionState {
            case .purchased, .restored:
                UserDefaultsDataProvider.isPremium = true
                delegate?.productsPurchased(id: productId)

            default:
                return

            }
        }
    }
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        paymentQueue(queue, updatedTransactions: queue.transactions)
    }

    func buy() {
        guard let product = AppStoreManager.shared.products.first else { return }
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }
}

extension Array where Element: SKProduct {

    func getProduct(withID id: String) -> SKProduct? {
        return self.first(where: {
            $0.productIdentifier == id
        })
    }
}

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)!
    }
}
