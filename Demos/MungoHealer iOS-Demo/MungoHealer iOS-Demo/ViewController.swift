//
//  Created by Cihat Gündüz on 15.10.18.
//  Copyright © 2018 Jamit Labs. All rights reserved.
//

import MungoHealer
import UIKit

struct MyError: Error {}

struct MyLocalizedError: LocalizedError {
    let errorDescription: String? = "This is a fake localized error message for presenting to the user."
}

struct MyBaseError: BaseError {
    let errorDescription = "This is a fake base error message for presenting to the user."
    let source = ErrorSource.invalidUserInput
}

struct MyFatalError: FatalError {
    let errorDescription = "This is a fake fatal error message for presenting to the user."
    let source = ErrorSource.internalInconsistency
}

struct MyHealableError: HealableError {
    private let retryClosure: () -> Void

    let errorDescription = "This is a fake healable error message for presenting to the user."
    let source = ErrorSource.custom(title: "This is a custom error source!")

    var healingOptions: [HealingOption] {
        let retryOption = HealingOption(style: .recommended, title: "Try Again", handler: retryClosure)
        let cancelOption = HealingOption(style: .normal, title: "Cancel", handler: {})
        return [retryOption, cancelOption]
    }

    init(retryClosure: @escaping () -> Void) {
        self.retryClosure = retryClosure
    }
}

class ViewController: UIViewController {
    @IBAction func throwErrorButtonPressed() {
        do {
            throw MyError()
        } catch {
            mungo.handle(error)
        }
    }

    @IBAction func throwLocalizedErrorButtonPressed() {
        do {
            throw MyLocalizedError()
        } catch {
            mungo.handle(error)
        }
    }

    @IBAction func throwBaseErrorButtonPressed() {
        do {
            throw MyBaseError()
        } catch {
            mungo.handle(error)
        }
    }

    @IBAction func throwFatalErrorButtonPressed() {
        do {
            throw MyFatalError()
        } catch {
            mungo.handle(error)
        }
    }

    @IBAction func throwHealableErrorButtonPressed() {
        do {
            throw MyHealableError(retryClosure: { [weak self] in self?.throwHealableErrorButtonPressed() })
        } catch {
            mungo.handle(error)
        }
    }
}

