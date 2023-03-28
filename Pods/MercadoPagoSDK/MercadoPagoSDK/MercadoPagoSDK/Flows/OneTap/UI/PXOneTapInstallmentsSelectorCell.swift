//
//  PXOneTapInstallmentsSelectorCell.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 30/10/18.
//

import UIKit

final class PXOneTapInstallmentsSelectorCell: UITableViewCell {

    var data: PXOneTapInstallmentsSelectorData?

    func updateData(_ data: PXOneTapInstallmentsSelectorData) {
        self.data = data
        self.selectionStyle = .default
        let selectedView = UIView()
        selectedView.backgroundColor = #colorLiteral(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        self.selectedBackgroundView = selectedView

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.attributedText = data.title
        titleLabel.textAlignment = .left
        contentView.addSubview(titleLabel)
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.attributedText = data.value
        valueLabel.textAlignment = .right
        contentView.addSubview(valueLabel)
        PXLayout.pinRight(view: valueLabel, withMargin: PXLayout.M_MARGIN).isActive = true
        PXLayout.centerVertically(view: valueLabel).isActive = true

        if data.isSelected {
            let selectedIndicatorView = UIView()
            selectedIndicatorView.translatesAutoresizingMaskIntoConstraints = false
            selectedIndicatorView.backgroundColor = ThemeManager.shared.getAccentColor()
            contentView.addSubview(selectedIndicatorView)
            PXLayout.setWidth(owner: selectedIndicatorView, width: 4).isActive = true
            PXLayout.pinTop(view: selectedIndicatorView).isActive = true
            PXLayout.pinBottom(view: selectedIndicatorView).isActive = true
            PXLayout.pinLeft(view: selectedIndicatorView, withMargin: 0).isActive = true
        }
    }
}
