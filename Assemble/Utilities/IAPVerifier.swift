//  Assemble
//  Created by David Spry on 10/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import StoreKit

/// A closure executed with the result of a product request and, if possible, the requested `SKProduct`.

public typealias ProductsRequestCompletionHandler = (_ result: Bool, _ identifier: String) -> Void

/// Manage the purchase, restoration, and verification of IAP products.
/// - Author: Pietro Rea
/// - SeeAlso: https://www.raywenderlich.com/5456-in-app-purchase-tutorial-getting-started

class IAPVerifier: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    public static let verifier = IAPVerifier()
    
    /// The `IAPVerifier`'s `StoreKit` products request
    
    private var request: SKProductsRequest?
    
    /// The callback to be executed when the outcome of a request has been determined
    
    private var callback: ProductsRequestCompletionHandler?
    
    /// Indicate whether the user can make payments.
    /// - Returns: `true` if the user can make payments, or `false` otherwise.

    private var isAuthorisedForPayment: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// Indicate whether the user owns Assemble's IAP product or not

    private var doesOwnProduct: Bool? = nil

    /// A collection of IAP product identifiers in use by the `IAPVerifier`

    public static var identifiers = Set<String>()
    
    // MARK: - Initialiser

    private override init() {}
    
    /// Restore all previously completed purchase transactions,
    ///
    /// - Parameter callback: The closure who should receive the result.

    public func restorePurchases(_ callback: @escaping ProductsRequestCompletionHandler) {
        self.callback = callback
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /// Perform a product request from the App Store and return the result to the given closure.
    ///
    /// - Parameter callback: The closure that should receive the App Store's response.

    public func requestProducts(then callback: @escaping ProductsRequestCompletionHandler) {
        IAPVerifier.identifiers.removeAll()
        IAPVerifier.identifiers.insert(UserDefaultsKeys.iap)
        self.callback = callback

        request?.cancel()
        request = SKProductsRequest(productIdentifiers: IAPVerifier.identifiers)
        request?.delegate = self
        request?.start()
    }
    
    /// Accepts the App Store response that contains the app-requested product information.
    /// - Note: This method is called when a list of products is successfully retrieved.
    /// - Parameter request:  The product request sent to the Apple App Store.
    /// - Parameter response: Detailed information about the list of products.

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.invalidProductIdentifiers.isNotEmpty {
            let invalidIdentifiers = response.invalidProductIdentifiers
            print("[IAPVerifier] Invalid identifiers requested:\n\(invalidIdentifiers)")
        }

        response.products.forEach {
            print("[IAPVerifier] Received product: \($0.price.floatValue): \($0.productIdentifier)")
        }

        clearRequestAndHandler()
    }
    
    /// This method is called when a request fails to execute properly.
    /// - Parameter request: The product request sent to the Apple App Store.
    /// - Parameter error:   The error that occurred.

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("[IAPVerifier] The list of products could not be retrieved.")
        print("[IAPVerifier] Error: \(error.localizedDescription)")
        clearRequestAndHandler()
    }
    
    /// Nullify the `IAPVerifier`'s `SKProductsRequest ` and `ProductsRequestCompletionHandler`.

    private func clearRequestAndHandler() {
        request = nil
        callback = nil
    }
    
    // MARK: - SKPaymentTransactionObserver

    /// This method is called when there are transactions to be processed in the `SKPaymentQueue`.
    /// - Parameter queue: The payment queue.
    /// - Parameter transactions: The transactions in the payment queue.

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: return
            case .purchased:  processPurchased(transaction)
            case .restored:   processRestored(transaction)
            case .failed:     processFailed(transaction)
            case .deferred:   print("[IAPVerifier] Deferred transaction")
            @unknown default: fatalError("[IAPVerifier] Unknown SKPaymentTransaction state")
            }
        }
    }
    
    /// Log each transaction that is removed from the `SKPaymentQueue`.
    /// - Parameter queue: The payment queue.
    /// - Parameter transactions: The transactions that were removed from the payment queue.

    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            let identifier = transaction.payment.productIdentifier
            print("[IAPVerifier] Product \(identifier) has been removed from the SKPaymentQueue.")
        }
    }
    
    /// This method is called when an error occurred while restoring purchases.
    /// - Parameter queue: The payment queue.
    /// - Parameter error: The error that occurred.

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            print(error.localizedDescription)
        }
    }
    
    /// This method is called when all restorable transactions have been processed by the `SKPaymentQueue`.
    /// - Parameter queue: The payment queue.

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if let doesOwnProduct = doesOwnProduct,
               doesOwnProduct == false {
            callback?(false, UserDefaultsKeys.iap)
        }
    }
    
    // MARK: - Payment Transaction Processing

    /// Process successful purchase transactions.
    /// - Parameter transaction: The purchase transaction.
    
    fileprivate func processPurchased(_ transaction: SKPaymentTransaction) {
        doesOwnProduct = true

        let identifier = transaction.payment.productIdentifier
        print("[IAPVerifier] Purchase of product \(identifier) succeeded.")

        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Process failed purchase transactions.
    /// - Parameter transaction: The failed purchase transaction.
    
    fileprivate func processFailed(_ transaction: SKPaymentTransaction) {
        let identifier = transaction.payment.productIdentifier
        print("[IAPVerifier] Purchase of product \(identifier) failed.")
        
        if let error = transaction.error {
            print("[IAPVerifier] Error: \(error.localizedDescription)")
        }
        
        if let error = transaction.error as? SKError,
               error.code != .paymentCancelled {
            print("[IAPVerifier] Push error \(error) to delegate on main thread.")
        }

        doesOwnProduct = false
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Process restored purchase transactions.
    /// - Parameter transaction: The restored purchase transaction.
    
    fileprivate func processRestored(_ transaction: SKPaymentTransaction) {
        doesOwnProduct = true
        callback?(true, transaction.payment.productIdentifier)

        print("[IAPVerifier] Product \(transaction.payment.productIdentifier) restored.")
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
}
