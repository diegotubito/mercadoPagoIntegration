//
//  AssociateCardService.swift
//  MercadoPagoSDK
//
//  Created by Diego Flores Domenech on 11/9/18.
//  Copyright © 2018 MercadoPago. All rights reserved.
//

import UIKit

final class AssociateCardService: MercadoPagoService {

    let uri = "/v1/px_mobile_api/card-association"
    let accessToken: String

    init(accessToken: String) {
        self.accessToken = accessToken
        super.init(baseURL: PXServicesURLConfigs.MP_API_BASE_URL)
    }

    func associateCardToUser(paymentMethod: PXPaymentMethod, cardToken: PXToken, success: @escaping ([String: Any]) -> Void, failure: @escaping (PXError) -> Void) {
        let paymentMethodDict: [String: String] = ["id": paymentMethod.id]
        let body: [String: Any] = ["card_token_id": cardToken.id, "payment_method": paymentMethodDict]

        let jsonData = try? JSONSerialization.data(withJSONObject: body, options: [])

        self.request(uri: uri, params: "access_token=\(accessToken)", body: jsonData, method: .post, headers: nil, cache: false, success: { (data) in
            let jsonResult = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            if let jsonResult = jsonResult as? [String: Any] {
                do {
                    let apiException = try PXApiException.fromJSON(data: data)
                    failure(PXError(domain: "mercadopago.sdk.associateCard", code: ErrorTypes.API_EXCEPTION_ERROR, userInfo: jsonResult, apiException: apiException))
                } catch {
                    success(jsonResult)
                }
            }
        }) { (_) in
            failure(PXError(domain: "mercadopago.sdk.associateCard", code: ErrorTypes.NO_INTERNET_ERROR, userInfo: [NSLocalizedDescriptionKey: "Hubo un error", NSLocalizedFailureReasonErrorKey: "Verifique su conexión a internet e intente nuevamente"]))
        }
    }

}
