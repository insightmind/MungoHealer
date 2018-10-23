//
//  AlertStrategy.swift
//  MungoHealer
//
//  Created by Cihat Gündüz on 15.10.18.
//  Copyright © 2018 Jamit Labs GmbH. All rights reserved.
//

import UIKit

/// An error handler that logs errors and shows system alerts for all BaseError types.
public struct AlertLogErrorHandler {
    private let window: UIWindow
    private let logError: (String) -> Void

    private var viewController: UIViewController {
        return window.topViewController
    }

    /// Creates an error handler that will log errors and present system alerts when appropriate.
    ///
    /// - Parameters:
    ///   - window: The key window of the application to find the current view controller.
    ///   - logError: The code to be called when trying to log some error message.
    public init(window: UIWindow, logError: @escaping (String) -> Void) {
        self.window = window
        self.logError = logError
    }

    fileprivate func showAlert(title: String, message: String, actions: [UIAlertAction]) {
        let alertCtrl = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { alertCtrl.addAction($0) }
        viewController.present(alertCtrl, animated: true, completion: nil)
    }
}

extension AlertLogErrorHandler: ErrorHandler {
    public func handle(error: Error) {
        logError(error.localizedDescription)

        if let localizedError = error as? LocalizedError, let errorDescription = localizedError.errorDescription {
            let alertTitle = LocalizedString("ALERT_LOG_ERROR_HANDLER.GENERIC_ERROR_TITLE")
            let okayTitle = LocalizedString("ALERT_LOG_ERROR_HANDLER.OKAY_BUTTON.TITLE")
            let okayAlertAction = UIAlertAction(title: okayTitle, style: .default, handler: nil)
            showAlert(title: alertTitle, message: errorDescription, actions: [okayAlertAction])
        }
    }

    public func handle(baseError: BaseError) {
        logError(baseError.localizedDescription)

        let okayTitle = LocalizedString("ALERT_LOG_ERROR_HANDLER.OKAY_BUTTON.TITLE")
        let okayAlertAction = UIAlertAction(title: okayTitle, style: .default, handler: nil)
        showAlert(title: title(for: baseError.source), message: baseError.localizedDescription, actions: [okayAlertAction])
    }

    public func handle(fatalError: FatalError) {
        logError(fatalError.localizedDescription)

        let terminateTitle = LocalizedString("ALERT_LOG_ERROR_HANDLER.TERMINATE_BUTTON.TITLE")
        let terminateAlertAction = UIAlertAction(title: terminateTitle, style: .destructive) { _ in
            self.crash(message: fatalError.localizedDescription)
        }

        showAlert(title: title(for: fatalError.source), message: fatalError.localizedDescription, actions: [terminateAlertAction])
    }

    public func handle(healableError: HealableError) {
        logError(healableError.localizedDescription)

        let healingOptions = healableError.healingOptions.map { alertAction(healingOption: $0) }
        showAlert(title: title(for: healableError.source), message: healableError.localizedDescription, actions: healingOptions)
    }

    private func title(for errorSource: ErrorSource) -> String {
        let keyPrefix = "ALERT_LOG_ERROR_HANDLER.ERROR_SOURCE_TITLE"

        switch errorSource {
        case .invalidUserInput:
            return LocalizedString("\(keyPrefix).INVALID_USER_INPUT")

        case .internalInconsistency:
            return LocalizedString("\(keyPrefix).INTERNAL_INCONSISTENCY")

        case .externalSystemUnavailable:
            return LocalizedString("\(keyPrefix).EXTERNAL_SYSTEM_UNAVAILABLE")

        case .externalSystemBehavedUnexpectedly:
            return LocalizedString("\(keyPrefix).EXTERNAL_SYSTEM_BEHAVED_UNEXPECTEDLY")

        case let .custom(title):
            return title
        }
    }

    private func alertAction(healingOption: HealingOption) -> UIAlertAction {
        let alertActionStyle: UIAlertAction.Style = {
            switch healingOption.style {
            case .normal:
                return .cancel

            case .recommended:
                return .default

            case .destructive:
                return .destructive
            }
        }()

        return UIAlertAction(title: healingOption.title, style: alertActionStyle) { _ in healingOption.handler() }
    }

    private func crash(message: String) { // swiftlint:disable:this unavailable_function
        fatalError(message)
    }
}
