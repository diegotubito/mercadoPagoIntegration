//
//  PXCardSlider.swift
//
//  Created by Juan sebastian Sanzone on 12/10/18.
//

import UIKit

final class PXCardSlider: NSObject {
    private var pagerView = FSPagerView(frame: .zero)
    private var pageControl = ISPageControl(frame: .zero, numberOfPages: 0)
    private var model: [PXCardSliderViewModel] = [] {
        didSet {
            self.selectedIndex = 0
            self.pagerView.reloadData()
            self.pageControl.numberOfPages = self.model.count
        }
    }
    private weak var delegate: PXCardSliderProtocol?
    private var selectedIndex: Int = 0
    private let cardSliderCornerRadius: CGFloat = 11
    weak var termsAndCondDelegate: PXTermsAndConditionViewDelegate?
}

// MARK: DataSource
extension PXCardSlider: FSPagerViewDataSource {
    func numberOfItems(in pagerView: FSPagerView) -> Int {
        return model.count
    }

    func pagerView(_ pagerView: FSPagerView, cellForItemAt index: Int) -> FSPagerViewCell {
        if model.indices.contains(index) {
            let targetModel = model[index]
            if let cardData = targetModel.cardData, let cell = pagerView.dequeueReusableCell(withReuseIdentifier: PXCardSliderPagerCell.identifier, at: index) as? PXCardSliderPagerCell {
                if targetModel.cardUI is AccountMoneyCard {
                    // AM card.
                    cell.renderAccountMoneyCard(balanceText: cardData.name, isDisabled: targetModel.isDisabled, cardSize: pagerView.itemSize)

                  } else if let oneTapCreditsInfo = targetModel.creditsViewModel, targetModel.cardUI is ConsumerCreditsCard {
                    cell.delegate = self
                    cell.renderConsumerCreditsCard(creditsViewModel: oneTapCreditsInfo, isDisabled: targetModel.isDisabled, cardSize: pagerView.itemSize)
                } else {
                    // Other cards.
                    cell.render(withCard: targetModel.cardUI, cardData: cardData, isDisabled: targetModel.isDisabled, cardSize: pagerView.itemSize)
                }
                return cell
            } else {
                // Add new card scenario.
                if let cell = pagerView.dequeueReusableCell(withReuseIdentifier: PXCardSliderPagerCell.identifier, at: index) as? PXCardSliderPagerCell {
                    cell.renderEmptyCard(cardSize: pagerView.itemSize)
                    return cell
                }
            }
        }
        return FSPagerViewCell()
    }
}

// MARK: Delegate
extension PXCardSlider: FSPagerViewDelegate {
    func pagerViewDidScroll(_ pagerView: FSPagerView) {
        delegate?.didScroll(offset: pagerView.literalScrollOffset)
    }

    func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        delegate?.didEndDecelerating()
    }

    func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        pageControl.currentPage = targetIndex
        if selectedIndex != targetIndex {
            PXFeedbackGenerator.selectionFeedback()
            selectedIndex = targetIndex
            if model.indices.contains(targetIndex) {
                let modelData = model[targetIndex]
                delegate?.newCardDidSelected(targetModel: modelData)
            }
        }
    }

    func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        if model.indices.contains(index) {
            let modelData = model[index]

            if modelData.isDisabled {
                delegate?.disabledCardDidTap(isAccountMoney: !modelData.isCard())
            }

            if modelData.cardData == nil {
                delegate?.addPaymentMethodCardDidTap()
            }
        }
    }
}

// MARK: Publics
extension PXCardSlider {
    func render(containerView: UIView, cardSliderProtocol: PXCardSliderProtocol? = nil) {
        setupSlider(containerView)
        setupPager(containerView)
        delegate = cardSliderProtocol
    }

    func update(_ newModel: [PXCardSliderViewModel]) {
        model = newModel
    }

    func show(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.pagerView.alpha = 1
            self?.pageControl.alpha = 1
        }
    }

    func hide(duration: Double = 0.5) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.pagerView.alpha = 0
            self?.pageControl.alpha = 0
        }
    }

    func getItemSize(_ containerView: UIView) -> CGSize {
        let targetWidth: CGFloat = containerView.bounds.width - PXCardSliderSizeManager.cardDeltaDecrease
        return PXCardSliderSizeManager.getGoldenRatioSize(targetWidth)
    }
}

// MARK: Privates
extension PXCardSlider {
    private func setupSlider(_ containerView: UIView) {
        containerView.addSubview(pagerView)
        pagerView.accessibilityIdentifier = "card_carrousel"
        PXLayout.setHeight(owner: pagerView, height: getItemSize(containerView).height).isActive = true
        PXLayout.pinLeft(view: pagerView).isActive = true
        PXLayout.pinRight(view: pagerView).isActive = true
        PXLayout.matchWidth(ofView: pagerView).isActive = true
        PXLayout.pinTop(view: pagerView).isActive = true
        pagerView.dataSource = self
        pagerView.delegate = self
        pagerView.register(PXCardSliderPagerCell.getCell(), forCellWithReuseIdentifier: PXCardSliderPagerCell.identifier)
        pagerView.register(FSPagerViewCell.self, forCellWithReuseIdentifier: "cell")
        pagerView.isInfinite = false
        pagerView.automaticSlidingInterval = 0
        pagerView.bounces = true
        pagerView.interitemSpacing = PXCardSliderSizeManager.interItemSpace
        pagerView.decelerationDistance = 1
        pagerView.itemSize = getItemSize(containerView)
    }

    private func setupPager(_ containerView: UIView) {
        let pagerYMargin: CGFloat = PXLayout.S_MARGIN
        let pagerHeight: CGFloat = 10
        pageControl.radius = 3
        pageControl.padding = 6
        pageControl.contentHorizontalAlignment = .center
        pageControl.numberOfPages = model.count
        pageControl.currentPage = 0
        pageControl.currentPageTintColor = ThemeManager.shared.getAccentColor()
        containerView.addSubview(pageControl)
        PXLayout.pinRight(view: pageControl).isActive = true
        PXLayout.pinLeft(view: pageControl).isActive = true
        PXLayout.centerHorizontally(view: pageControl).isActive = true
        PXLayout.pinBottom(view: pageControl, to: pagerView, withMargin: -pagerYMargin).isActive = true
        PXLayout.setHeight(owner: pageControl, height: pagerHeight).isActive = true
        pageControl.layoutIfNeeded()
    }
}

extension PXCardSlider: PXTermsAndConditionViewDelegate {
    func shouldOpenTermsCondition(_ title: String, url: URL) {
        termsAndCondDelegate?.shouldOpenTermsCondition(title, url: url)
    }
}
