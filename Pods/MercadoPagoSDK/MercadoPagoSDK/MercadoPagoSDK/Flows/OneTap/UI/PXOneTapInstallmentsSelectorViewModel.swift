//
//  PXOneTapInstallmentsSelectorViewModel.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 30/10/18.
//

import Foundation

typealias PXOneTapInstallmentsSelectorData = (title: NSAttributedString, value: NSAttributedString, isSelected: Bool)

final class PXOneTapInstallmentsSelectorViewModel {
    let installmentData: PXInstallment
    let selectedPayerCost: PXPayerCost?

    init(installmentData: PXInstallment, selectedPayerCost: PXPayerCost?) {
        self.installmentData = installmentData
        self.selectedPayerCost = selectedPayerCost
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return installmentData.payerCosts.count
    }

    func cellForRowAt(_ indexPath: IndexPath) -> UITableViewCell {
        let cell = PXOneTapInstallmentsSelectorCell()
        if let payerCost = getPayerCostForRowAt(indexPath) {
            var isSelected = false
            if let selectedPayerCost = selectedPayerCost, selectedPayerCost == payerCost {
                isSelected = true
            }
            let data = getDataFor(payerCost: payerCost, isSelected: isSelected)
            cell.updateData(data)
            cell.backgroundColor = .white
            return cell
        }
        return cell
    }

    func heightForRowAt(_ indexPath: IndexPath) -> CGFloat {
        return PXOneTapInstallmentInfoView.DEFAULT_ROW_HEIGHT
    }

    func getDataFor(payerCost: PXPayerCost, isSelected: Bool) -> PXOneTapInstallmentsSelectorData {
        let currency = SiteManager.shared.getCurrency()
        let showDescription = MercadoPagoCheckout.showPayerCostDescription()

        var title: NSAttributedString = NSAttributedString(string: "")
        var value: NSAttributedString = NSAttributedString(string: "")

        if payerCost.installments == 1 {
            value = NSAttributedString(string: "")
        } else if payerCost.hasInstallmentsRate() {
            let attributedTotal = NSMutableAttributedString(attributedString: NSAttributedString(string: "(", attributes: [NSAttributedString.Key.foregroundColor: UIColor.px_grayLight()]))
            attributedTotal.append(Utils.getAttributedAmount(payerCost.totalAmount, currency: currency, color: UIColor.px_grayLight(), fontSize: 15, baselineOffset: 3))
            attributedTotal.append(NSAttributedString(string: ")", attributes: [NSAttributedString.Key.foregroundColor: UIColor.px_grayLight()]))

            if showDescription == false {
                value = NSAttributedString(string: "")
            } else {
                value = attributedTotal
            }

        } else {
            if showDescription == false {
                value = NSAttributedString(string: "")
            } else {
                value = NSAttributedString(string: "Sin interés".localized, attributes: [NSAttributedString.Key.foregroundColor: ThemeManager.shared.noTaxAndDiscountLabelTintColor()])
            }

        }
        var installmentNumber = String(format: "%i", payerCost.installments)
        installmentNumber = "\(installmentNumber) x "
        let totalAmount = Utils.getAttributedAmount(payerCost.installmentAmount, thousandSeparator: currency.getThousandsSeparatorOrDefault(), decimalSeparator: currency.getDecimalSeparatorOrDefault(), currencySymbol: currency.getCurrencySymbolOrDefault(), color: UIColor.black, centsFontSize: 14, baselineOffset: 5)

        let atribute = [NSAttributedString.Key.font: Utils.getFont(size: 20), NSAttributedString.Key.foregroundColor: UIColor.black]
        let installmentLabel = NSMutableAttributedString(string: installmentNumber, attributes: atribute)

        installmentLabel.append(totalAmount)
        title = installmentLabel

        return PXOneTapInstallmentsSelectorData(title, value, isSelected)
    }

    func getPayerCostForRowAt(_ indexPath: IndexPath) -> PXPayerCost? {
        return installmentData.payerCosts[indexPath.row]
    }
}
