//
//  PXOneTapHeaderView+SummaryProtocol.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 22/05/2019.
//

import Foundation

extension PXOneTapHeaderView: PXOneTapSummaryProtocol {
    func didTapCharges() {
        delegate?.didTapCharges()
    }

    func didTapDiscount() {
        delegate?.didTapDiscount()
    }

    func handleHeaderTap() {
        delegate?.didTapMerchantHeader()
    }
}
