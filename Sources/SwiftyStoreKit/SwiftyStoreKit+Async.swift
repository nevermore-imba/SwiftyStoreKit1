//
// SwiftyStoreKit+Async.swift
// SwiftyStoreKit
//
// Copyright (c) 2015 Andrea Bizzotto (bizz84@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import StoreKit

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SwiftyStoreKit {

    /// Retrieve products information
    public class func products<Identifiers>(for identifiers: Identifiers) async -> RetrieveResults where Identifiers: Collection, Identifiers.Element == String {
        return await withCheckedContinuation { continuation in
            retrieveProductsInfo(Set(identifiers)) {
                continuation.resume(returning: $0)
            }
        }
    }

    /// Purchase a product
    public class func purchase(_ product: SKProduct, quantity: Int = 1, atomically: Bool = true, appAccountToken: UUID? = nil, simulatesAskToBuyInSandbox: Bool = false, paymentDiscount: PaymentDiscount? = nil) async throws -> PurchaseResult {
        return try await withCheckedThrowingContinuation { continuation in
            purchaseProduct(
                product,
                quantity: quantity,
                atomically: atomically,
                appAccountToken: appAccountToken,
                simulatesAskToBuyInSandbox: simulatesAskToBuyInSandbox,
                paymentDiscount: paymentDiscount)
            {
                continuation.resume(with: $0.mapError { $0 as Error })
            }
        }
    }

    /// Restore purchases
    public class func restore(atomically: Bool = true, appAccountToken: UUID? = nil) async throws -> [Purchase] {
        return try await withCheckedThrowingContinuation { continuation in
            restorePurchases(atomically: atomically, appAccountToken: appAccountToken) { result in
                if let error = result.restoreFailedPurchases.first?.0 {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: result.restoredPurchases)
                }
            }
        }
    }

}

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension SwiftyStoreKit {

    /// Verify application receipt
    /// - Parameters:
    ///   - validator: receipt validator to use
    ///   - forceRefresh: If `true`, refreshes the receipt even if one already exists.
    public class func verifyReceipt(using validator: ReceiptValidator, forceRefresh: Bool = false) async throws -> ReceiptInfo {
        return try await withCheckedThrowingContinuation { continuation in
            verifyReceipt(using: validator, forceRefresh: forceRefresh) { result in
                do {
                    let receiptInfo = try result.receiptInfo
                    continuation.resume(returning: receiptInfo)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    /// Fetch application receipt data
    /// - Parameter forceRefresh: If true, refreshes the receipt even if one already exists.
    /// - Returns: The receipt data or nil if not exists.
    public class func receiptData(forceRefresh: Bool) async throws -> Data? {
        return try await withCheckedThrowingContinuation { continuation in
            fetchReceipt(forceRefresh: forceRefresh) { result in
                switch result {
                case .success(let receiptData):
                    continuation.resume(returning: receiptData)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

}
