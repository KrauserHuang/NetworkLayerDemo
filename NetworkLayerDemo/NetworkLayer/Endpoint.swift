//
//  Endpoint.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/8.
//

import Foundation

enum Endpoint {
    
    static let basePath = "/api/"
    
    // MAIN PAGE
    case marqueeList
    case campaignLink
    case swpMainAD
    case categoryAD
    case swpPortraitAD
    
    // SEARCH PAGE
    case searchOrder
    case searchOrderDetail
//    case ...
    
    var path: String {
        var finalPath = ""
        var path = ""
        switch self {
        // MAIN PAGE
        case .marqueeList: path = "MarqueeList"
        case .campaignLink: path = "CampaignLink"
        case .swpMainAD: path = "SwpMainAD"
        case .categoryAD: path = "CategoryAD"
        case .swpPortraitAD: path = "SwpPortraitAD"
        
        // SEARCH PAGE
        case .searchOrder: path = "SearchOrder"
        case .searchOrderDetail: path = "SearchOrderDetail"
        }
        finalPath = Endpoint.basePath + path
        return finalPath
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .swpPortraitAD: return .get
        case .categoryAD: return .get
        case .swpMainAD: return .get
        case .campaignLink: return .get
        case .marqueeList: return .get
        case .searchOrder: return .post
        case .searchOrderDetail: return .post
        }
    }
}
