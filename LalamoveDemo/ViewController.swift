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
let marginBetweenItems: CGFloat = 20.0
let itemLabelHeight: CGFloat = 30.0
let itemImageViewTagBase: Int = 100
let itemLabelTagBase: Int = 200
let mainImageDetailViewHeight: CGFloat = 250.0

class ViewController: UIViewController {
    
    var imageView: UIImageView = UIImageView()
    var scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
    var mainLabel:UILabel = UILabel()
    var blackView:UIView = UIView()
    
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
                    
                    let result: [[String:Any]] = data as! [[String:Any]]
                    
                    
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
    
    func generateInterface(receivedResult:[[String:Any]]) {
//        print("result: \(receivedResult[0])")
        
//        scrollView.backgroundColor = UIColor.orange
        self.view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        
        var scrollViewContentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: marginBetweenItems))
        
        var startingPositionX:CGFloat = marginBetweenItems
        var startingPositionY:CGFloat = marginBetweenItems
        
        var index = 0
        for singleItem:[String:Any] in receivedResult {
            print("singleItem: \(singleItem)")
            
            var itemWidthOrHeight:CGFloat = ((screenSize.width-60.0)/2.0)
            
            var itemView: UIView = UIView()
            itemView.frame = CGRect(x: startingPositionX, y: startingPositionY, width: itemWidthOrHeight, height: itemWidthOrHeight)
            //itemView.backgroundColor = UIColor.white
            
            var itemImageView: UIImageView = UIImageView()
            var itemLabel: UILabel = UILabel()
            
            
            
            itemImageView.frame = CGRect(x: 0, y: 0, width: itemView.frame.size.width, height: itemView.frame.size.height - itemLabelHeight)
            itemLabel.frame = CGRect(x: 0, y: itemImageView.frame.size.height, width: itemView.frame.size.width, height: itemLabelHeight)
            
            //itemImageView.backgroundColor = UIColor.lightGray
            itemImageView.contentMode = .scaleAspectFill
            itemImageView.clipsToBounds = true
            itemImageView.tag = itemImageViewTagBase + index
            
            //itemLabel.backgroundColor = UIColor.white
            
            updateImage(anImageView: itemImageView, urlString: singleItem["imageUrl"] as! String)
            
            itemLabel.text = singleItem["description"] as! String
            itemLabel.tag = itemLabelTagBase + index
            
            itemLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            itemLabel.numberOfLines = 0
            itemLabel.textAlignment = .center
            
            itemView.addSubview(itemImageView)
            itemView.addSubview(itemLabel)
            
            var itemOverlayButton: UIButton = UIButton()
            itemOverlayButton.frame = CGRect(x: 0, y: 0, width: itemView.frame.size.width, height: itemView.frame.size.height)
//            itemOverlayButton.backgroundColor = UIColor.blue
            itemOverlayButton.tag = index
            itemOverlayButton.addTarget(self, action: #selector(self.tappedItemOverlayButton(aButton:)), for: .touchUpInside)

            
            itemView.addSubview(itemOverlayButton)
            
            
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

    }
    
    func updateImage(anImageView:UIImageView, urlString:String) {
        let imageURL = URL(string: urlString)
        var image: UIImage?
        if let url = imageURL {

            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)

                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData as! Data)
                        anImageView.image = image
                        
                    } else {
                        image = nil
                    }
                }
            }
        }
    }
    
    func tappedItemOverlayButton(aButton:UIButton) {
        dlog(message: "#\(aButton.tag) Button pressed")
        
        blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        blackView.backgroundColor = UIColor.black.withAlphaComponent(0)
        self.view.addSubview(blackView)
        
        
        //Beginning position of the main item image
        var itemView = aButton.superview
        
        var aButtonImageViewFrame: CGRect = CGRect(x: aButton.frame.origin.x, y: aButton.frame.origin.y, width: aButton.frame.size.width, height: aButton.frame.size.height - itemLabelHeight)
        dlog(message: "aButtonImageViewFrame is \(aButtonImageViewFrame)")
        
        let mainImageViewframe = self.view.convert(aButtonImageViewFrame, from:itemView)
        dlog(message: "mainImageViewframe is \(mainImageViewframe)")
        
        var mainImageView:UIImageView = UIImageView(frame: mainImageViewframe)
        mainImageView.backgroundColor = UIColor.cyan
        
        if let sourceImageView:UIImageView = self.view.viewWithTag(itemImageViewTagBase+aButton.tag) as? UIImageView {
            mainImageView.image = sourceImageView.image
            mainImageView.contentMode = .scaleAspectFill
        }
        
        blackView.addSubview(mainImageView)
        
        mainImageView.clipsToBounds = true
        
        
        var mainImageViewFrameAfterAnimation:CGRect = CGRect(x: marginBetweenItems*2, y: marginBetweenItems*2, width: screenSize.width - marginBetweenItems*4, height: mainImageDetailViewHeight)
        
        
        //main label
        mainLabel = UILabel(frame: CGRect(x: mainImageViewFrameAfterAnimation.origin.x, y: mainImageViewFrameAfterAnimation.origin.y + mainImageViewFrameAfterAnimation.size.height + marginBetweenItems*2, width: mainImageViewFrameAfterAnimation.size.width, height: itemLabelHeight))
        
        var labelInHomeScreen = self.view.viewWithTag(itemLabelTagBase+aButton.tag) as? UILabel
        
        mainLabel.text = labelInHomeScreen?.text
        mainLabel.textAlignment = .center
        mainLabel.textColor = UIColor.white.withAlphaComponent(0)
        mainLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        
        blackView.addSubview(mainLabel)
        
        
        
        
        UIView.animate(withDuration: 0.5) {
            self.blackView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            
            mainImageView.frame = mainImageViewFrameAfterAnimation
            
            self.uiProcessingAfterAnimation(aButton: aButton)
        }
        
        
        
    }
    
    func uiProcessingAfterAnimation(aButton:UIButton) {
        mainLabel.textColor = UIColor.white.withAlphaComponent(1)
        
        
    }

}

