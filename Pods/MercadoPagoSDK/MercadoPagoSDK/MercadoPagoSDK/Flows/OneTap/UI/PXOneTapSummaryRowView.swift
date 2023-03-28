//
//  PXOneTapSummaryRowView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 18/12/2018.
//

import UIKit



class PXOneTapSummaryRowView: UIView {

    typealias Handler = () -> Void

    enum RowType {
        case discount
        case charges
        case generic
    }

    let data: OneTapHeaderSummaryData

    init(data: OneTapHeaderSummaryData) {
        self.data = data
        super.init(frame: CGRect.zero)
        render()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func render() {
        let rowHeight: CGFloat = data.isTotal && !UIDevice.isSmallDevice() ? 20 : 16
        let titleFont = data.isTotal ? Utils.getFont(size: PXLayout.S_FONT) : Utils.getFont(size: PXLayout.XXS_FONT)
        let valueFont = data.isTotal ? Utils.getSemiBoldFont(size: PXLayout.S_FONT) : Utils.getFont(size: PXLayout.XXS_FONT)
        let shouldAnimate = data.isTotal ? false : true

        self.translatesAutoresizingMaskIntoConstraints = false
        self.pxShouldAnimatedOneTapRow = shouldAnimate

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = data.title
        titleLabel.textAlignment = .left
        titleLabel.font = titleFont
        titleLabel.textColor = data.highlightedColor
        titleLabel.alpha = data.alpha
        self.addSubview(titleLabel)
        PXLayout.pinLeft(view: titleLabel, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.centerVertically(view: titleLabel).isActive = true

        if let rightImage = data.image {
            let imageView: UIImageView = UIImageView()
            let imageSize: CGFloat = 16
            imageView.image = rightImage
            imageView.contentMode = .scaleAspectFit
            self.addSubview(imageView)
            PXLayout.setWidth(owner: imageView, width: imageSize).isActive = true
            PXLayout.setHeight(owner: imageView, height: imageSize).isActive = true
            PXLayout.centerVertically(view: imageView, to: titleLabel).isActive = true
            PXLayout.put(view: imageView, rightOf: titleLabel, withMargin: PXLayout.XXXS_MARGIN).isActive = true
        }

        let valueLabel = UILabel()
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        valueLabel.text = data.value
        valueLabel.textAlignment = .right
        valueLabel.font = valueFont
        valueLabel.textColor = data.highlightedColor
        valueLabel.alpha = data.alpha
        self.addSubview(valueLabel)
        PXLayout.pinRight(view: valueLabel, withMargin: PXLayout.L_MARGIN).isActive = true
        PXLayout.centerVertically(view: valueLabel).isActive = true
        PXLayout.setHeight(owner: self, height: rowHeight).isActive = true
    }
}
