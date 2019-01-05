//
//  SettingsVC.swift
//  WSUStudentEvents
//
//  Created by Colin Warn on 8/7/17.
//  Copyright © 2017 Colin Warn. All rights reserved.
//

import UIKit
import StoreKit

class SettingsVC: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    //IAP Setup
    let removeAdsId = "cougarremoveads"
    
    @IBOutlet weak var restorePurchasesOutlet: UIButton!
    @IBOutlet weak var removeAdsOutlet: UIButton!
    var productID = ""
    var productsRequest = SKProductsRequest()
    var iapProducts = [SKProduct]()
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: "nonConsumablePurchaseMade")
    var removeAds = UserDefaults.standard.integer(forKey: "removeAds")
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Check your In-App Purchases
        print("NON CONSUMABLE PURCHASE MADE: \(nonConsumablePurchaseMade)")
        
        
        // Fetch IAP Products available
        fetchAvailableProducts()
    
        let removeAdsPurchased = defaults.bool(forKey: "nonConsumablePurchaseMade")
        if removeAdsPurchased {
            removeAdsOutlet.removeFromSuperview()
            restorePurchasesOutlet.removeFromSuperview()
        }
    
    }

    @IBAction func restorePurchases(_ sender: Any) {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    @IBAction func removeAds(_ sender: Any) {
        purchaseMyProduct(product: iapProducts[0])
    }
    
    func presentAlert(title: String, message: String) {
        let alertControler = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alertControler.addAction(ok)
        present(alertControler, animated: true, completion: nil)
    }
    
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        nonConsumablePurchaseMade = true
        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
        
       presentAlert(title: "Restored", message: "Purchases Restored!")
        removeAdsOutlet.removeFromSuperview()
        restorePurchasesOutlet.removeFromSuperview()
        
    }
    
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:
            removeAdsId
        )
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if (response.products.count > 0) {
            iapProducts = response.products
            
            // 1st IAP Product (Consumable) ------------------------------------
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            let price1Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
            print("Product Found: \(firstProduct.localizedDescription) for \(price1Str!)")
            // ------------------------------------------------
            
            
            
        }
        
    }
    
    func canMakePurchases() -> Bool {  return SKPaymentQueue.canMakePayments()  }
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases dsabled on the Device
        } else {
            presentAlert(title: "Enable In App Purchases", message: "In App Purchases are not enabled on your device.")
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    // The Consumable product (10 coins) has been purchased -> gain 10 extra coins!
                    if productID == removeAdsId {
                        
                        // Do stuff for a successful purchase
                        nonConsumablePurchaseMade = true
                        UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: "nonConsumablePurchaseMade")
                        
                        removeAdsOutlet.removeFromSuperview()
                        
                    } // Other IAP place here
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
    
    @IBAction func backPressed(_ sender: Any) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(nextViewController, animated: true, completion: nil)
    }

    
}
