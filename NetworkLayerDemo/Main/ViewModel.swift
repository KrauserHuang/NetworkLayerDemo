//
//  ViewModel.swift
//  NetworkLayerDemo
//
//  Created by Tai Chin Huang on 2024/4/28.
//

import Foundation
import Combine

class ViewModel {
    
    private let networkManager: NetworkManager
    private var subscriptions: Set<AnyCancellable> = []
    
    init(networkManager: NetworkManager = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    public func fetchInitData() {
        let marqueeResponse: AnyPublisher<[MarqueeList], APIHandlerError> = networkManager.request(endpoint: .marqueeList)
        let campaignLinkResponse: AnyPublisher<[CampaignLink], APIHandlerError> = networkManager.request(endpoint: .campaignLink)
        let swpMainADResponse: AnyPublisher<BannerADResult, APIHandlerError> = networkManager.request(endpoint: .swpMainAD)
        let categoryADResponse: AnyPublisher<[CategoryAD], APIHandlerError> = networkManager.request(endpoint: .categoryAD)
        let swpPortraitADResponse: AnyPublisher<[SwpPortraitAD], APIHandlerError> = networkManager.request(endpoint: .swpPortraitAD)
        
        let firstZip = Publishers.Zip(marqueeResponse, campaignLinkResponse)
        let secondZip = Publishers.Zip3(swpMainADResponse, categoryADResponse, swpPortraitADResponse)
        
        Publishers.Zip(firstZip, secondZip)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Failed with error: \(error)")
                }
            } receiveValue: { [weak self] (firstGroup, secondGroup) in
                guard let self else { return }
                let (marqueeList, campaignLink) = firstGroup
                let (swpMainAD, categoryAD, swpPortraitAD) = secondGroup
                
//                dump(campaignLink)
//                print("Campaign Link: \(campaignLink)")
//                print("Swp Main AD: \(swpMainAD)")
//                print("Category AD: \(categoryAD)")
//                print("Swp Portrait AD: \(swpPortraitAD)")
            }
            .store(in: &subscriptions)
    }
}
