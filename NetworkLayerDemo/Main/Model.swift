//
//  Model.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/28.
//

import Foundation

struct MarqueeList: Codable, Hashable {
    let subject: String?
    let app: MarqueeListApp?
    let subjectUrl: String?
}
struct MarqueeListApp: Codable, Hashable {
    let categoryId: String?
    let keyword: String?
    let type: String?
}

struct CampaignLink: Codable, Hashable {
    let url: String?
    let app: CampaignApp?
    let campaignName: String?
    let urlMobile: String?
    let adTitle: String?
    let adName: String?
}

struct CampaignApp: Codable, Hashable {
    let categoryId: String?
    let keyword: String?
    let type: String?
}

/*
 FlagshipStoreAd／CategoryMidAD會回傳BannerADData
 MiddleCategoryCenterAD會回傳[BannerAD]
 */
enum BannerADResult: Codable, Hashable {
    case data(BannerADData)
    case array([BannerAD])
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        // Attempt to decode as a dictionary (BannerADData)
        if let data = try? container.decode(BannerADData.self) {
            self = .data(data)
            return
        }
        
        // Attempt to decode as an array ([BannerAD])
        if let array = try? container.decode([BannerAD].self) {
            self = .array(array)
            return
        }
        
        throw DecodingError.typeMismatch(BannerADResult.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Expected to decode BannerADData or [BannerAD]"))
    }
}

struct BannerADData: Codable, Hashable {
    let CategoryCenterAD: [BannerAD]?
    let AD1: [BannerAD]?
    let AD2: [BannerAD]?
    let AD3: [BannerAD]?
    let AD4: [BannerAD]?
}

struct BannerAD: Codable, Hashable {
    var id = UUID()
    let name: String?
    let sort: Int?
    let url: String?
    let app: BannerADApp?
    let flagshipstoreAdId: String?
    let flagshipstoreId: String?
    let flagshipstoreName: String?
    let categoryName: String?
    let headId: Int?
    let urlMobile: String?
    let imageUrl: String?
    let imgUrlM: String?
    let createDate: String?
    let themeColor: String?
    let urlM: String?
    
    // AD3
    let headId4: Int?
    // CategoryMidAD
    let campaignId: String?
    // SwpMainAD
    let adName: String?
    let adTitle: String?
    var specialId: Int?
    
    enum CodingKeys: String, CodingKey {
        case name
        case sort
        case url
        case app
        case flagshipstoreAdId
        case flagshipstoreId
        case flagshipstoreName
        case categoryName
        case headId
        case urlMobile
        case imageUrl = "imgUrl"
        case imgUrlM
        case createDate
        case themeColor
        case headId4
        case campaignId
        case urlM
        case adName
        case adTitle
    }
    
    var imgUrl: String {
        return imgUrlM ?? ""
    }
}

struct BannerADApp: Codable, Hashable {
    let categoryId: String?
    let keyword: String
    let type: String
}

struct CategoryAD: Codable, Hashable {
    let name: String
    let theme: String?
    let url: String?
    let app: CategoryADApp?
    let imgUrl: String?
    let adName: String?
    let adTitle: String?
}

struct CategoryADApp: Codable, Hashable {
    let type: String?
    let keyword: String?
    let categoryId: String?
}

struct SwpPortraitAD: Codable, Hashable {
    let name: String?
    let url: String?
    let app: SwpPortraitADApp?
    let campaignId: String?
    let imgUrl: String?
    let adName: String?
    let adTitle: String?
}

struct SwpPortraitADApp: Codable, Hashable {
    let type: String?
    let keyword: String?
    let categoryId: String?
}
