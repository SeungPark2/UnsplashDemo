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
    
    func requestPhotos()
}

class PhotoListVM: PhotoListVMProtocol {
    
    var isLoaded = CurrentValueSubject<Bool, Never>(true)
    var errMsg = CurrentValueSubject<String, Never>("")
    
    var photos = [Photo]()
    
    func requestPhotos() {
        
        guard self.isLoaded.value,
              let nextPage = self.photoListNextPage else {
            
            return
        }
        
        self.isLoaded.send(false)
        
        Network.shared.requestGet(with: API.photoList,
                                  queries: ["page": nextPage,
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
                    
                case .finished: break
                }
                
            }, receiveValue: { [weak self] photoList in
                
                self?.photos = (self?.photos ?? []) + photoList
                
                self?.isLoaded.send(true)
            })
            .store(in: &self.cancellable)
        
    }
    
    private var photoListNextPage: Int? = 1
    private var cancellable = Set<AnyCancellable>()
}
