//
//  Network.swift
//  Kakaopay
//
//  Created by 박승태 on 2022/02/25.
//

import Combine
import Foundation

protocol NetworkProtocol {
    
    func requestGet(with endPoint: String,
                    queries: [String: Any]?) -> AnyPublisher<Network.CustomGetResponse, Error>
}

class Network: NetworkProtocol {
    
    static let shared: Network = Network()
    private init() { }
}

extension Network {
    
    func requestGet(with endPoint: String,
                    queries: [String : Any]?) -> AnyPublisher<CustomGetResponse, Error> {
        
        var urlString: String = Server.url + endPoint
        
        if let query = queries {
            
            let queryArr = query.compactMap { key, value in "\(key)=\(value)" }
            let queryString = "?" + queryArr.joined(separator: "&")
            urlString += queryString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        }
        
        guard let url = URL(string: urlString) else {
            
            return Fail(error: NetworkError.failed(errCode: 0,
                                                   message: "")).eraseToAnyPublisher()
        }
        
        return URLSession
                .shared
                .dataTaskPublisher(for: self.createURLReqeust(with: url))
                .tryMap() {
                
                    element -> CustomGetResponse in
                    
                    let httpReponse = element.response as? HTTPURLResponse
                    
                    self.printRequestInfo(
                        urlString,
                        "GET",
                        queries,
                        element.data,
                        httpReponse?.statusCode
                    )
                
                    guard httpReponse != nil else {
                        
                        throw NetworkError.failed(errCode: 0, message: "")
                    }
                    
                    if 200...299 ~= (httpReponse?.statusCode ?? 0) {
                        
                        return CustomGetResponse(isHadNextPage: true,
                                                 data: element.data)
                    }
                    
                    throw self.checkNetworkError(with: httpReponse?.statusCode ?? 0)
                
                }.eraseToAnyPublisher()
    }
    
    private func createURLReqeust(with url: URL) -> URLRequest {
        
        var request = URLRequest(url: url)        
        
        request.allHTTPHeaderFields?
               .updateValue("application/json;charset=UTF-8",
                            forKey: "Content-Type")
        
        return request
    }
    
    private func checkNetworkError(with statusCode: Int) -> NetworkError {
        
        
        if 500...599 ~= statusCode {
            
            return NetworkError.serverNotConnected
        }
        
        if statusCode == 401 {
            
            return NetworkError.invalidToken
        }
        
        if statusCode == 403 {
            
            return NetworkError.accessDenied
        }
        
        return NetworkError.failed(errCode: 0,
                                   message: "")
        
    }
}

extension Network {
    
    // MARK: -- Log
    
    private func printRequestInfo(_ url: String?,
                                  _ method: String?,
                                  _ params: [String: Any]?,
                                  _ data: Data,
                                  _ statusCode: Int?) {
        
        var message: String = "\n\n"
        message += "/*————————————————-————————————————-————————————————-"
        message += "\n|                    HTTP REQUEST                    |"
        message += "\n—————————————————————————————————-————————————————---*/"
        message += "\n"
        message += "* METHOD : \(method ?? "")"
        message += "\n"
        message += "* URL : \(url ?? "")"
        message += "\n"
        message += "* PARAM : \(params?.description ?? "")"
        message += "\n"
        message += "* STATUS CODE : \(statusCode ?? 0)"
        message += "\n"
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) {
            
            message += "* RESPONSE : \n\(json)"
        }
        else {
            
            message += "* RESPONSE : \n\(data.description)"
        }
        message += "\n"
        message += "/*————————————————-————————————————-————————————————-"
        message += "\n|                    RESPONSE END                     |"
        message += "\n—————————————————————————————————-————————————————---*/"
        println(message)
    }
    
    // MARK: - Log
    private func println<T>(_ object: T,
                            _ file: String = #file,
                            _ function: String = #function,
                            _ line: Int = #line){
    #if DEBUG
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm:ss:SSS"
        let process = ProcessInfo.processInfo
        
        var tid:UInt64 = 0;
        pthread_threadid_np(nil, &tid);
        let threadId = tid
        
        Swift.print("\(dateFormatter.string(from: NSDate() as Date)) \(process.processName))[\(process.processIdentifier):\(threadId)] \((file as NSString).lastPathComponent)(\(line)) \(function):\t\(object)")
    #else
    #endif
    }
}
