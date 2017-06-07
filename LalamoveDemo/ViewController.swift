//
//  ViewController.swift
//  LalamoveDemo
//
//  Created by oOEric on 4/6/2017.
//  Copyright © 2017 Eric Cheung. All rights reserved.
//

import UIKit
import Alamofire

let screenSize = UIScreen.main.bounds
let marginBetweenItems: CGFloat = 20

class ViewController: UIViewController {
    
    var imageView: UIImageView = UIImageView()
    var scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
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
                    
                    let result: [Any] = data as! [Any]
                    
                    
                    print(data)
                    
                    self.generateInterface(receivedResult: result)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                
                self.showErrorMessage()
                break
                
            }
        }


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showErrorMessage() {
        //...
    }
    
    func generateInterface(receivedResult:[Any]) {
//        print("result: \(receivedResult[0])")
        
        scrollView.backgroundColor = UIColor.orange
        self.view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        
        var scrollViewContentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: marginBetweenItems))
        
        var startingPositionX:CGFloat = marginBetweenItems
        var startingPositionY:CGFloat = marginBetweenItems
        
        var index = 0
        for singleItem:Any in receivedResult {
            print("singleItem: \(singleItem)")
            
            var itemWidthOrHeight:CGFloat = ((screenSize.width-60.0)/2.0)
            
            var itemView: UIView = UIView()
            itemView.frame = CGRect(x: startingPositionX, y: startingPositionY, width: itemWidthOrHeight, height: itemWidthOrHeight)
            itemView.backgroundColor = UIColor.white
            
            var itemImageView: UIImageView = UIImageView()
            var itemLabel: UILabel = UILabel()
            
            var itemLabelHeight: CGFloat = 30.0
            
            itemImageView.frame = CGRect(x: 0, y: 0, width: itemView.frame.size.width, height: itemView.frame.size.height - itemLabelHeight)
            itemLabel.frame = CGRect(x: 0, y: itemImageView.frame.size.height, width: itemView.frame.size.width, height: itemLabelHeight)
            
            itemImageView.backgroundColor = UIColor.lightGray
            itemLabel.backgroundColor = UIColor.darkGray
            
            itemLabel.text = singleItem["description"]
            
            itemView.addSubview(itemImageView)
            itemView.addSubview(itemLabel)
            
            scrollViewContentView.addSubview(itemView)
            
            if index%2 == 0 {   //e.g. index is 0, 2, 4...
                dlog(message:"index is \(index)")
                
                startingPositionX = startingPositionX+itemWidthOrHeight+marginBetweenItems
                
                scrollViewContentView.frame = CGRect(x: scrollViewContentView.frame.origin.x, y: scrollViewContentView.frame.origin.y, width: scrollViewContentView.frame.size.width, height: scrollViewContentView.frame.size.height + itemWidthOrHeight+marginBetweenItems)
            } else {
                
                startingPositionX = startingPositionX-itemWidthOrHeight-marginBetweenItems
                startingPositionY = startingPositionY+itemWidthOrHeight+marginBetweenItems
                
            }
            
            index = index + 1
         }
        
        scrollView.addSubview(scrollViewContentView)
        scrollView.contentSize = scrollViewContentView.frame.size
        
//        imageView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
//        self.view.addSubview(imageView)
        
//        fetchImage()
    }
    
    private func fetchImage() {
        let imageURL = URL(string: "http://placekitten.com.s3.amazonaws.com/homepage-samples/200/287.jpg")
        var image: UIImage?
        if let url = imageURL {

            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)

                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData as! Data)
                        self.imageView.image = image
                        self.imageView.sizeToFit()
                    } else {
                        image = nil
                    }
                }
            }
        }
    }

}

