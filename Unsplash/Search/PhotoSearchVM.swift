//
//  PhotoSearchVM.swift
//  Unsplash
//
//  Created by 박승태 on 2022/02/27.
//

import Combine
import Foundation

protocol PhotoSearchVMProtocl {
    
    var isLoaded: CurrentValueSubject<Bool, Never> { get }
    var errMsg: CurrentValueSubject<String, Never> { get }
    
    var resultPhotos: [Photo] { get }
    
    func typing(with searchWord: String)
    func requestPhotos()
}

class PhotoSearchVM: PhotoSearchVMProtocl {
    
    // MARK: -- Public Properties
    
    var isLoaded = CurrentValueSubject<Bool, Never>(true)
    var errMsg = CurrentValueSubject<String, Never>("")
        
    var resultPhotos = [Photo]()
    
    // MARK: -- Public Method
    
    func typing(with searchWord: String) {
        
        self.searchWord = searchWord
        
        if searchWord.isEmpty,
           !self.resultPhotos.isEmpty {
            
            self.resultPhotos.removeAll()
            self.isLoaded.send(true)
        }
    }
    
    func requestPhotos() {
        
        guard self.isLoaded.value,
              self.searchWord != "",
              let nextPage = self.photoListNextPage
        else {
            
            return
        }
        
        self.isLoaded.send(false)
        
        Network.shared.requestGet(with: API.searchPhoto,
                                  queries: ["page": nextPage,
                                            "per_page": 20,
                                            "query": self.searchWord,
                                            "client_id": ""])
            .map { [weak self] in
                
                self?.photoListNextPage = $0.isHadNextPage ? nextPage + 1 : nil
                
                return $0.data
            }
            .decode(type: PhotoResult.self, decoder: JSONDecoder())
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
                
            }, receiveValue: { [weak self] photoResult in
                
                self?.resultPhotos = (self?.resultPhotos ?? []) + photoResult.photos
                
                self?.isLoaded.send(true)
            })
            .store(in: &self.cancellable)
    }
    
    // MARK: -- Private Method
    
    // MARK: -- Private Properties
    
    private var searchWord: String = ""
    private var photoListNextPage: Int? = 1
    private var cancellable = Set<AnyCancellable>()
}
