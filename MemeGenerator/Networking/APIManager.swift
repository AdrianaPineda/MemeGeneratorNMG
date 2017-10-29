//
//  APIManager.swift
//  MemeGenerator
//
//  Created by Natasha on 10/28/17.
//  Copyright © 2017 NatashaMartinez. All rights reserved.
//

import Foundation
import Alamofire

class APIManager {
    
    static let sharedInstance = APIManager()
    
    var delegate: AnyObject?
    
    class func apiRequest(url: Router,
                          success:@escaping (_ responseJSON: [String: Any]) -> (),
                          error:@escaping (_ errorMessage: String) -> ()) {
        
        Alamofire.request(url).validate().responseJSON { response in
            
            switch response.result {
                
            case .success:
                
                print("Validation Successful")
                
                if let responseJSON = response.result.value as? [String: Any] {
                    
                    print("Response JSON: \(responseJSON)")
                        success(responseJSON)
                }
            case .failure(let error):
                
                print("Failed Validation")
                print(error.localizedDescription)
                
                if let json = try? JSONSerialization.jsonObject(with: response.data!) as! [String: Any] {
                    print("Error message: \(json["message"] as! String)")
                }
            }
        }
    }
}
