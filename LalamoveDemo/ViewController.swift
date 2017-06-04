//
//  ViewController.swift
//  LalamoveDemo
//
//  Created by oOEric on 4/6/2017.
//  Copyright © 2017 Eric Cheung. All rights reserved.
//

import UIKit
import Alamofire

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dlog(message: "app begins")

        
        //Notes: use https instead of http if not using mock server

        //**correct link, correct para
//            <-- GET /deliveries?offset=0
//                --> GET /deliveries?offset=0 200 2,003ms 3.85kb
        
        Alamofire.request("http://localhost:8080/deliveries", method: .get, parameters: ["offset":"0"], encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    print(response.result.value)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                break
                
            }
        }


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

