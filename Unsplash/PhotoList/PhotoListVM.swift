//
//  PhotoListVM.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Combine
import Foundation

protocol PhotoListVMProtocol {
    
    var isLoaded: CurrentValueSubject<Bool, Never> { get }
    var errMsg: CurrentValueSubject<String, Never> { get }
    
    var photos: [Photo] { get }
    
    func refreshPhotos()
    func requestPhotos()
}

class PhotoListVM: PhotoListVMProtocol {
    
    // MARK: -- Public Properties
    
    var isLoaded = CurrentValueSubject<Bool, Never>(true)
    var errMsg = CurrentValueSubject<String, Never>("")
    
    var photos = [Photo]()
    
    // MARK: -- Public Method
    
    init() {
        
        self.requestPhotos()
    }
    
    func refreshPhotos() {
        
        self.photoListNextPage = 1
        self.photos.removeAll()
        self.requestPhotos()
    }
    
    func requestPhotos() {
        
        guard self.isLoaded.value,
              let nextPage = self.photoListNextPage
        else {
            
            self.isLoaded.send(true)
            return
        }
        
        self.isLoaded.send(false)
        
        Network.shared.requestGet(with: API.photoList,
                                  queries: ["page": nextPage, // default per_page = 10
                                            "client_id": ""])
            .map { [weak self] in
                
                self?.photoListNextPage = $0.isHadNextPage ? nextPage + 1 : nil
                
                return $0.data
            }
            .decode(type: [Photo].self, decoder: JSONDecoder())
            .sink(receiveCompletion: { [weak self] completion in
                
                switch completion {
                    
                    case .failure(let error):
                        
                        print(error.localizedDescription)
                        
                        self?.errMsg.send(
                            (error as? NetworkError)?.description ?? ""
                        )
                    
                        self?.isLoaded.send(true)
                        
                    case .finished: break
                }
                
            }, receiveValue: { [weak self] photoList in
                
                self?.photos = (self?.photos ?? []) + photoList
                
                self?.isLoaded.send(true)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    private var photoListNextPage: Int? = 1
    private var cancellable = Set<AnyCancellable>()
}
