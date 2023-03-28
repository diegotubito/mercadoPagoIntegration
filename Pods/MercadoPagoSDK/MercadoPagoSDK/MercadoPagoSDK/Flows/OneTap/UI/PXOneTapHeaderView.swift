//
//  PXOneTapHeaderView.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 11/10/18.
//

import UIKit

class PXOneTapHeaderView: PXComponentView {
    private var model: PXOneTapHeaderViewModel {
        willSet(newModel) {
            updateLayout(newModel: newModel, oldModel: model)
        }
    }

    internal weak var delegate: PXOneTapHeaderProtocol?
    private var isShowingHorizontally: Bool = false
    private var verticalLayoutConstraints: [NSLayoutConstraint] = []
    private var horizontalLayoutConstraints: [NSLayoutConstraint] = []
    private var merchantView: PXOneTapHeaderMerchantView?
    private var summaryView: PXOneTapSummaryView?
    private var splitPaymentView: PXOneTapSplitPaymentView?
    private var splitPaymentViewHeightConstraint: NSLayoutConstraint?
    private let splitPaymentViewHeight: CGFloat = 55

    init(viewModel: PXOneTapHeaderViewModel, delegate: PXOneTapHeaderProtocol?) {
        self.model = viewModel
        self.delegate = delegate
        super.init()
        self.render()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateModel(_ model: PXOneTapHeaderViewModel) {
        self.model = model
    }

    func updateSplitPaymentView(splitConfiguration: PXSplitConfiguration?) {
        if let newSplitConfiguration = splitConfiguration {
            self.splitPaymentView?.update(splitConfiguration: newSplitConfiguration)
        }
    }

    func hideSplitPaymentView(duration: Double = 0.5) {
        self.layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.layoutIfNeeded()

            strongSelf.splitPaymentView?.alpha = 0
            strongSelf.splitPaymentViewHeightConstraint?.constant = 0

            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    func showSplitPaymentView(duration: Double = 0.5) {
        self.layoutIfNeeded()
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            strongSelf.layoutIfNeeded()

            strongSelf.splitPaymentView?.alpha = 1
            strongSelf.splitPaymentViewHeightConstraint?.constant = strongSelf.splitPaymentViewHeight

            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }
}

// MARK: Privates.
extension PXOneTapHeaderView {

    private func shouldShowHorizontally(model: PXOneTapHeaderViewModel) -> Bool {
        if UIDevice.isLargeOrExtraLargeDevice() {
            //an extra large device will always be able to accomodate al view in vertical mode
            return false
        }

        if UIDevice.isSmallDevice() {
            //a small device will never be able to accomodate al view in vertical mode
            return true
        }

        // a regular device will collapse if combined rows result in a medium sized header or larger
        return model.hasMediumHeaderOrLarger()
    }

    private func removeAnimations() {
        self.layer.removeAllAnimations()
        for view in self.getSubviews() {
            view.layer.removeAllAnimations()
        }
    }

    private func updateLayout(newModel: PXOneTapHeaderViewModel, oldModel: PXOneTapHeaderViewModel) {
        removeAnimations()

        let animationDuration = 0.35
        let shouldAnimateSplitPaymentView = (newModel.splitConfiguration != nil) != (oldModel.splitConfiguration != nil)
        let shouldHideSplitPaymentView = newModel.splitConfiguration == nil
        let shouldShowHorizontally = self.shouldShowHorizontally(model: newModel)
        let shouldAnimateSummary = newModel.data.count != oldModel.data.count
        let shouldHideSummary = newModel.data.count < oldModel.data.count

        self.layoutIfNeeded()

        if shouldShowHorizontally, !isShowingHorizontally {
            //animate to horizontal
            self.animateToHorizontal(duration: animationDuration)
        } else if !shouldShowHorizontally, isShowingHorizontally {
            //animate to vertical
            self.animateToVertical(duration: animationDuration)
        }

        self.layoutIfNeeded()

        if shouldAnimateSummary {
            let animationDistance: CGFloat = 30
            var animationRows: [UIView] = []
            var pinTopConstraints: [NSLayoutConstraint] = []

            if !shouldHideSummary {
                summaryView?.update(newModel.data, hideAnimatedView: !shouldHideSummary)
            }

            self.layoutIfNeeded()

            if let subviews = summaryView?.getSubviews() {
                for view in subviews {
                    if view.pxShouldAnimatedOneTapRow, let summaryRowView = view as? PXOneTapSummaryRowView, let newRow = summaryView?.getSummaryRowView(with: summaryRowView.data) {

                        newRow.alpha = shouldHideSummary ? 1 : 0
                        animationRows.append(newRow)
                        self.addSubview(newRow)

                        PXLayout.setHeight(owner: newRow, height: summaryRowView.frame.height).isActive = true
                        PXLayout.setWidth(owner: newRow, width: summaryRowView.frame.width).isActive = true

                        let summaryRowViewFrame = summaryRowView.convert(summaryRowView.bounds, to: self)
                        let pinTopConstraint = PXLayout.pinTop(view: newRow, withMargin: summaryRowViewFrame.minY)

                        if !shouldHideSummary {
                            if shouldAnimateSplitPaymentView, shouldHideSplitPaymentView {
                                pinTopConstraint.constant += animationDistance + self.splitPaymentViewHeight
                            } else {
                                pinTopConstraint.constant += animationDistance
                            }
                        }

                        pinTopConstraint.isActive = true
                        pinTopConstraints.append(pinTopConstraint)
                    }
                }
            }

            summaryView?.update(newModel.data, hideAnimatedView: !shouldHideSummary)

            self.layoutIfNeeded()
            var pxAnimator = PXAnimator(duration: animationDuration, dampingRatio: 1)
            pxAnimator.addAnimation(animation: { [weak self] in
                for (index, view) in animationRows.enumerated() {
                    let pinTopConstraint = pinTopConstraints[index]

                    if shouldHideSummary {
                        pinTopConstraint.constant += animationDistance
                    } else {
                        if shouldAnimateSplitPaymentView {
                            if shouldHideSplitPaymentView {
                                pinTopConstraint.constant -= animationDistance
                            } else {
                                pinTopConstraint.constant -= animationDistance
                            }
                        } else {
                            pinTopConstraint.constant -= animationDistance
                        }
                    }

                    self?.layoutIfNeeded()
                    view.alpha = shouldHideSummary ? 0 : 1
                }
            })

            pxAnimator.addCompletion { [weak self] in
                if !shouldHideSummary {
                    self?.summaryView?.showAnimatedViews()
                }
                for view in animationRows {
                    view.removeFromSuperview()
                }
            }

            pxAnimator.animate()
        } else {
            summaryView?.update(newModel.data)
        }

        if shouldAnimateSplitPaymentView {
            if shouldHideSplitPaymentView {
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                self.hideSplitPaymentView(duration: animationDuration)
            } else {
                self.layoutIfNeeded()
                self.superview?.layoutIfNeeded()
                self.showSplitPaymentView(duration: animationDuration)
            }
        }
    }

    private func animateToVertical(duration: Double = 0) {
        self.isShowingHorizontally = false
        self.merchantView?.animateToVertical(duration: duration)
        let margin = model.splitConfiguration != nil ? PXLayout.ZERO_MARGIN : PXLayout.M_MARGIN
        self.merchantView?.updateContentViewLayout(margin: margin)
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            for constraint in strongSelf.horizontalLayoutConstraints.reversed() {
                constraint.isActive = false
            }

            for constraint in strongSelf.verticalLayoutConstraints.reversed() {
                constraint.isActive = true
            }
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    private func animateToHorizontal(duration: Double = 0) {
        self.isShowingHorizontally = true
        self.merchantView?.animateToHorizontal(duration: duration)
        var pxAnimator = PXAnimator(duration: duration, dampingRatio: 1)
        pxAnimator.addAnimation(animation: { [weak self] in
            guard let strongSelf = self else {
                return
            }

            for constraint in strongSelf.horizontalLayoutConstraints.reversed() {
                constraint.isActive = true
            }

            for constraint in strongSelf.verticalLayoutConstraints.reversed() {
                constraint.isActive = false
            }
            strongSelf.layoutIfNeeded()
        })

        pxAnimator.animate()
    }

    private func render() {
        removeAllSubviews()
        self.removeMargins()
        backgroundColor = ThemeManager.shared.navigationBar().backgroundColor

        let summaryView = PXOneTapSummaryView(data: model.data, delegate: self)
        self.summaryView = summaryView

        addSubview(summaryView)
        PXLayout.matchWidth(ofView: summaryView).isActive = true

        let splitPaymentView = PXOneTapSplitPaymentView(splitConfiguration: model.splitConfiguration) { (isOn, isUserSelection) in
            self.delegate?.splitPaymentSwitchChangedValue(isOn: isOn, isUserSelection: isUserSelection)
        }
        self.splitPaymentView = splitPaymentView
        self.addSubview(splitPaymentView)
        PXLayout.matchWidth(ofView: splitPaymentView).isActive = true

        let initialSplitPaymentViewHeight = model.splitConfiguration != nil ? self.splitPaymentViewHeight : 0
        self.splitPaymentViewHeightConstraint = PXLayout.setHeight(owner: splitPaymentView, height: initialSplitPaymentViewHeight)
        self.splitPaymentViewHeightConstraint?.isActive = true
        PXLayout.centerHorizontally(view: splitPaymentView).isActive = true
        PXLayout.pinBottom(view: splitPaymentView).isActive = true
        PXLayout.put(view: splitPaymentView, onBottomOf: summaryView).isActive = true

        let showHorizontally = shouldShowHorizontally(model: model)
        let merchantView = PXOneTapHeaderMerchantView(image: model.icon, title: model.title, subTitle: model.subTitle, showHorizontally: showHorizontally)

        let headerTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleHeaderTap))
        merchantView.addGestureRecognizer(headerTapGesture)

        self.merchantView = merchantView
        self.addSubview(merchantView)

        let bestRelation = PXLayout.put(view: merchantView, aboveOf: summaryView, withMargin: -PXLayout.M_MARGIN)
        bestRelation.priority = UILayoutPriority(rawValue: 900)
        let minimalRelation = PXLayout.put(view: merchantView, aboveOf: summaryView, withMargin: -PXLayout.XXS_MARGIN, relation: .greaterThanOrEqual)
        minimalRelation.priority = UILayoutPriority(rawValue: 1000)


        let horizontalConstraints = [PXLayout.pinTop(view: merchantView, withMargin: -PXLayout.XXL_MARGIN),
                                     bestRelation, minimalRelation,
                                     PXLayout.centerHorizontally(view: merchantView),
                                     PXLayout.matchWidth(ofView: merchantView)]

        self.horizontalLayoutConstraints.append(contentsOf: horizontalConstraints)

        let verticalLayoutConstraints = [PXLayout.pinTop(view: merchantView),
                                         PXLayout.put(view: merchantView, aboveOf: summaryView, relation: .greaterThanOrEqual),
                                         PXLayout.centerHorizontally(view: merchantView),
                                         PXLayout.matchWidth(ofView: merchantView)]

        self.verticalLayoutConstraints.append(contentsOf: verticalLayoutConstraints)

        if showHorizontally {
            animateToHorizontal()
        } else {
            animateToVertical()
        }
    }
}
