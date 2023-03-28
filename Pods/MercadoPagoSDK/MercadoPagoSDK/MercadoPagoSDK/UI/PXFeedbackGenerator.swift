//
//  PXFeedbackGenerator.swift
//  MercadoPagoSDK
//
//  Created by AUGUSTO COLLERONE ALFONSO on 23/10/18.
//

import Foundation

struct PXFeedbackGenerator {
    private static func getBatteryLevel() -> Float {
        UIDevice.current.isBatteryMonitoringEnabled = true
        return UIDevice.current.batteryLevel
    }

    private static func getBatteryState() -> UIDevice.BatteryState {
        return UIDevice.current.batteryState
    }

    private static func shouldGiveFeedback() -> Bool {
        return getBatteryLevel() > 0.2 || getBatteryState() == .charging
    }

    // UINotificationFeedbackGenerator
    @available(iOS 10.0, *)
    private static func executeNotificationFeedback(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    // UISelectionFeedbackGenerator
    private static func executeSelectionFeedback() {
        if #available(iOS 10.0, *) {
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }

    // UIImpactFeedbackGenerator
    @available(iOS 10.0, *)
    private static func executeImpactFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: Public UINotificationFeedbackGenerator.
extension PXFeedbackGenerator {
    static func successNotificationFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeNotificationFeedback(type: .success)
            }
        }
    }

    static func warningNotificationFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeNotificationFeedback(type: .warning)
            }
        }
    }

    static func errorNotificationFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeNotificationFeedback(type: .error)
            }
        }
    }
}

// MARK: Public UISelectionFeedbackGenerator.
extension PXFeedbackGenerator {
    static func selectionFeedback() {
        if shouldGiveFeedback() {
            executeSelectionFeedback()
        }
    }
}

// MARK: Public UIImpactFeedbackGenerator.
extension PXFeedbackGenerator {
    static func lightImpactFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeImpactFeedback(style: .light)
            }
        }
    }

    static func mediumImpactFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeImpactFeedback(style: .medium)
            }
        }
    }

    static func heavyImpactFeedback() {
        if shouldGiveFeedback() {
            if #available(iOS 10.0, *) {
                executeImpactFeedback(style: .heavy)
            }
        }
    }
}
