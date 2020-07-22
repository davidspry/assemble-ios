//  Assemble
//  Created by David Spry on 10/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import StoreKit

/// A closure executed with the result of a transaction and, if possible, the identifier of the requested `SKProduct`.

public typealias ProductTransactionCallback = (_ result: Bool, _ error: Bool, _ message: String?) -> Void

/// Manage the purchase, restoration, and verification of IAP products.
/// - Author: Pietro Rea
/// - SeeAlso: https://www.raywenderlich.com/5456-in-app-purchase-tutorial-getting-started

class IAPVerifier: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {

    /// The single, shared instance of the `IAPVerifier`.
    
    public static let shared = IAPVerifier()

    /// The `IAPVerifier`'s `StoreKit` products request
    
    private var request: SKProductsRequest?
    
    /// The callback to be executed when ownership of the IAP has been confirmed.
    
    public var callback: ProductTransactionCallback?
    
    /// Indicate whether the user can make payments.
    /// - Returns: `true` if the user can make payments, or `false` otherwise.
    
    public var isAuthorisedForPayment: Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    /// The `SKProduct` representing Assemble's IAP product.
    
    private var product: SKProduct?

    /// Indicate whether the user owns Assemble's IAP product or not.
    
    private var doesOwnProduct: Bool? = nil

    /// A collection of IAP product identifiers in use by the `IAPVerifier`
    
    public static var identifiers: Set<String> = [UserDefaultsKeys.iap]
    
    // MARK: - Initialiser

    private override init() {}
    
    /// Initiate a purchase transaction with Assemble's IAP product.
    /// - Parameter callback: The closure who should receive the the result of the purchase transaction.

    public func initiatePurchase(_ callback: @escaping ProductTransactionCallback) {
        if let product = product {
            self.callback = callback
            let payment = SKMutablePayment(product: product)
            SKPaymentQueue.default().add(payment)
        }

        else {
            let message = "UNKNOWN: The product could not be found. " +
                          "Your device may not be connected to the internet."
            callback(true, false, message)
        }
    }

    /// Restore all previously completed purchase transactions,
    ///
    /// - Parameter callback: The closure who should receive the result.

    public func restorePurchase(_ callback: @escaping ProductTransactionCallback) {
        self.callback = callback
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    /// Perform a product request from the App Store and return the result to the given closure.

    public func requestProducts(_ callback: @escaping ProductTransactionCallback) {
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
        var result = false

        if response.invalidProductIdentifiers.isNotEmpty {
            let invalidIdentifiers = response.invalidProductIdentifiers
            print("[IAPVerifier] Invalid identifiers requested:\n\(invalidIdentifiers)")
        }

        response.products.forEach { product in
            result = true
            self.product = product
            print("[IAPVerifier] Received product: \(product.productIdentifier)")
        }
        
        callback?(result, false, product?.regularPrice ?? "")
    }
    
    /// This method is called when a request fails to execute properly.
    /// - Parameter request: The product request sent to the Apple App Store.
    /// - Parameter error:   The error that occurred.

    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("[IAPVerifier] The list of products could not be retrieved.")
        print("[IAPVerifier] Error: \(error.localizedDescription)")
        
        if let callback = callback {
            callback(false, true, error.localizedDescription)
        }
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
            case .deferred:   print("[IAPVerifier] The current transaction has been deferred.")
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
    
    /// This method is called when the user ceases to be entitled to one or more in-app purchases.
    /// - Parameter queue: The payment queue calling the delegate method.
    /// - Parameter productIdentifiers: The list of product identifiers with revoked entitlements.

    func paymentQueue(_ queue: SKPaymentQueue, didRevokeEntitlementsForProductIdentifiers productIdentifiers: [String]) {
        let defaults = UserDefaults()
        for product in productIdentifiers {
            defaults.set(false, forKey: product)
            print("[IAPVerifier] Entitlement revoked for product: \(product)")
            NotificationCenter.default.post(name: .updateEntitlements, object: product)
        }
    }
    
    /// This method is called when an error occurred while restoring purchases.
    /// - Parameter queue: The payment queue.
    /// - Parameter error: The error that occurred.

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        if let error = error as? SKError, error.code != .paymentCancelled {
            print("[IAPVerifier] An error occurred while restoring purchases.")
            callback?(false, true, "ERROR: \(error.localizedDescription)")
        }
    }
    
    /// This method is called when all restorable transactions have been processed by the `SKPaymentQueue`.
    /// - Parameter queue: The payment queue.

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if doesOwnProduct == nil || doesOwnProduct == false {
            let message = "COMPLETE: No previous purchase transactions could be restored."
            callback?(false, false, message)
        }
    }
    
    // MARK: - Payment Transaction Processing

    /// Process successful purchase transactions.
    /// - Parameter transaction: The purchase transaction.

    fileprivate func processPurchased(_ transaction: SKPaymentTransaction) {
        doesOwnProduct = true
        
        if  let callback = callback {
            let identifier = transaction.payment.productIdentifier
            print("[IAPVerifier] Purchase of product \(identifier) succeeded.")

            callback(true, false, "COMPLETE: Purchase transaction processed successfully.")
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
    /// Process failed purchase transactions.
    /// - Parameter transaction: The failed purchase transaction.
    
    fileprivate func processFailed(_ transaction: SKPaymentTransaction) {
        let identifier = transaction.payment.productIdentifier
        if let error = transaction.error {
            print("[IAPVerifier] Purchase of product \(identifier) failed.")
            print("[IAPVerifier] Error: \(error.localizedDescription)")
        }
        
        if let error = transaction.error as? SKError {
            if error.code == .paymentCancelled {
                callback?(false, false, "COMPLETE: Payment cancelled.")
            }

            else {
                callback?(false, true, "ERROR: \(error.localizedDescription)")
            }
        }

        doesOwnProduct = false
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    /// Process restored purchase transactions.
    /// - Parameter transaction: The restored purchase transaction.
    
    fileprivate func processRestored(_ transaction: SKPaymentTransaction) {
        doesOwnProduct = true

        if  let callback = callback {
            let identifier = transaction.payment.productIdentifier
            print("[IAPVerifier] Product \(identifier) restored.")

            callback(true, false, "COMPLETE: Product restored successfully.")
            SKPaymentQueue.default().finishTransaction(transaction)
        }
    }
    
}
