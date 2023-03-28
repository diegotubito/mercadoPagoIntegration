//
//  PXCreditsExpectationView.swift
//  MercadoPagoSDK
//
//  Created by Federico Bustos Fierro on 16/5/18.
//  Copyright © 2019 MercadoPago. All rights reserved.
//

import Foundation

final class PXCreditsExpectationView: PXBodyView {

    let TITLE_FONT_SIZE: CGFloat = PXLayout.M_FONT
    let SUBTITLE_FONT_SIZE: CGFloat = PXLayout.XS_FONT

    var titleLabel: UILabel?
    var subtitleLabel: UILabel?
    let props: PXCreditsExpectationProps

    init(props: PXCreditsExpectationProps) {
        self.props = props
        super.init()
        createSubviews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func createSubviews() {
        self.backgroundColor = .white
        self.translatesAutoresizingMaskIntoConstraints = false

        // Title
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel = title
        self.addSubview(title)
        title.font = Utils.getLightFont(size: TITLE_FONT_SIZE)
        title.text = props.title
        title.textColor = .px_grayDark()
        title.textAlignment = .center
        title.numberOfLines = 0
        self.pinFirstSubviewToTop(withMargin: PXLayout.L_MARGIN)?.isActive = true
        PXLayout.matchWidth(ofView: title, toView: self, withPercentage: CGFloat(60), relation: .equal).isActive = true
        PXLayout.centerHorizontally(view: title).isActive = true

        //Subtitle
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 0
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(detailLabel)
        self.subtitleLabel = detailLabel
        detailLabel.font = Utils.getLightFont(size: SUBTITLE_FONT_SIZE)
        detailLabel.text = props.subtitle
        detailLabel.textColor = .px_grayDark()
        detailLabel.textAlignment = .center
        self.putOnBottomOfLastView(view: detailLabel, withMargin: PXLayout.S_MARGIN)?.isActive = true
        PXLayout.matchWidth(ofView: detailLabel, toView: self, withPercentage: CGFloat(80), relation: .equal).isActive = true
        PXLayout.centerHorizontally(view: detailLabel).isActive = true
        self.pinLastSubviewToBottom(withMargin: PXLayout.L_MARGIN)?.isActive = true
    }
}
