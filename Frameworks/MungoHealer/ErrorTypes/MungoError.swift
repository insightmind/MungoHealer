//
//  Created by Cihat Gündüz on 16.10.18.
//  Copyright © 2018 Jamit Labs GmbH. All rights reserved.
//

import Foundation

public class MungoError: BaseError {
    public let source: ErrorSource
    public let errorDescription: String

    public init(source: ErrorSource, message: String) {
        self.source = source
        self.errorDescription = message
    }
}
