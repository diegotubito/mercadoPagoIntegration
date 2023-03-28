//
//  ViewController.swift
//  ConMercadoPago
//
//  Created by David Gomez on 27/03/2023.
//

import UIKit
import MercadoPagoSDK

class ViewController: UIViewController, PXLifeCycleProtocol {
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var paymentResult: UILabel!
    
    var preferenceId: String = ""
    var publicKey = "TEST-42b74188-7f95-44cf-b734-ae1e66b07e01"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @objc func startMercadoPagoCheckout() {
        let builder = MercadoPagoCheckoutBuilder.init(publicKey: publicKey, preferenceId: preferenceId)
        
        let config = PXAdvancedConfiguration()
        config.bankDealsEnabled = false
        builder.setAdvancedConfiguration(config: config)
        let checkout = MercadoPagoCheckout.init(builder: builder)
        
        checkout.start(navigationController: navigationController!, lifeCycleProtocol: self)
    }

    @IBAction func pay(_ sender: Any) {
        getClientID()
    }
    
    func finishCheckout() -> ((_ payment: PXResult?) -> Void)? {
        return  ({ (_ payment: PXResult?) in
            self.navigationController?.popToRootViewController(animated: false)
        })
    }

    func cancelCheckout() -> (() -> Void)? {
        return {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func getClientID() {
        fetchRequest { [ weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
                if let body = json?["body"] as? [String: Any], let id = body["id"] as? String {
                    DispatchQueue.main.async {
                        self.preferenceId = id
                        self.startMercadoPagoCheckout()
                    }

                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.paymentResult.text = error.message
                }
            }
        }
    }
}
