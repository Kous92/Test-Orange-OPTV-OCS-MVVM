//
//  OCSAPIEndpoint.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 21/12/2021.
//

import Foundation

enum OCSAPIEndpoint {
    case searchPrograms(title: String)
    case getProgramContent(detaillink: String)
    
    var url: String {
        switch self {
        case .searchPrograms(let title):
            return "https://api.ocs.fr/apps/v2/contents?search=title%3D\(title)"
        case .getProgramContent(let detaillink):
            return detaillink
        }
    }
}
