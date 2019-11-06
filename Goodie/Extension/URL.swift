//
//  URL.swift
//  Goodie
//
//  Created by 이창현 on 06/10/2019.
//  Copyright © 2019 이창현. All rights reserved.
//

import Foundation

extension URL {
    func valueOf(_ queryParamaterName: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParamaterName })?.value
    }
}
