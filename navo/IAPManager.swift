import UIKit
import StoreKit

class IAPManager: NSObject, SKProductsRequestDelegate {
    static let sharedInstance = IAPManager()
    
    var request:SKProductsRequest!
    var products:[SKProduct] = []
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        self.products = response.products
    }
    
    func getProductIdentifiers() -> [String] {
        var identifiers:[String] = []
        
        if let fileUrl = Bundle.main.url(forResource: "products", withExtension: "plist") {
            let products = NSArray(contentsOf: fileUrl)
            
            for product in products as! [String] {
                identifiers.append(product)
            }
        }
        
        return identifiers
    }
    
    func preformProductRequiestForIdentifiers(identifiers: [String]) {
        let products = NSSet(array: identifiers) as! Set<String>
        
        self.request = SKProductsRequest(productIdentifiers: products)
        self.request.delegate = self
        self.request.start()
    }
    
    func requestProducts() {
        self.preformProductRequiestForIdentifiers(identifiers: self.getProductIdentifiers())
    }
    
    func setupPurchases(_ handler: @escaping (Bool) -> Void) {
        if SKPaymentQueue.canMakePayments(){
            handler(true)
            return
        }
        handler(false)
        
    }
}
