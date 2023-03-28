//
//  PXSummaryComposer+AddRow.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 14/05/2019.
//

import Foundation

extension PXSummaryComposer {
    func chargesRow() -> OneTapHeaderSummaryData {
        let amount = getChargesAmount()
        let shouldDisplayHelper = shouldDisplayChargesHelp
        let helperImage = shouldDisplayHelper ? helpIcon(color: summaryColor()) : nil
        let amountToShow = Utils.getAmountFormated(amount: amount, forCurrency: currency)
        let defaultChargeText = "onetap_purchase_summary_charges".localized_beta
        let chargeText = additionalInfoSummary?.charges ?? defaultChargeText
        let row = OneTapHeaderSummaryData(chargeText, amountToShow, summaryColor(), textTransparency, false, helperImage, .charges)
        return row
    }

    func consumedDiscountRow() -> OneTapHeaderSummaryData {
        let helperImage = helpIcon(color: summaryColor())
        let row = OneTapHeaderSummaryData("total_row_consumed_discount".localized_beta, "", summaryColor(), textTransparency, false, helperImage, .discount)
        return row
    }

    func discountRow() -> OneTapHeaderSummaryData? {
        guard let discount = getDiscount() else {
            printError("Discount is required to add the discount row")
            return nil
        }

        let discountToShow = Utils.getAmountFormated(amount: discount.couponAmount, forCurrency: currency)
        let helperImage = helpIcon(color: discountColor())
        let row = OneTapHeaderSummaryData(discount.getDiscountDescription(),
                                          "- \(discountToShow)",
            discountColor(),
            textTransparency,
            false,
            helperImage,
            .discount)
        return row
    }

    func purchaseRow() -> OneTapHeaderSummaryData {
        let row = OneTapHeaderSummaryData( yourPurchaseSummaryTitle(),
                                           yourPurchaseToShow(),
                                           summaryColor(),
                                           textTransparency,
                                           false,
                                           nil,
                                           .generic)
        return row
    }

    func totalToPayRow() -> OneTapHeaderSummaryData {
        let totalAmountToShow = Utils.getAmountFormated(amount: amountHelper.getAmountToPayWithoutPayerCost(selectedCard?.cardId), forCurrency: currency)
        let text = "onetap_purchase_summary_total".localized_beta
        let row = OneTapHeaderSummaryData(text,
                                          totalAmountToShow,
                                          summaryColor(),
                                          textTransparency,
                                          true,
                                          nil,
                                          .generic)
        return row
    }

}
