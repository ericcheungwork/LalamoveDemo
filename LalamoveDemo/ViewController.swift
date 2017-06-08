//
//  ViewController.swift
//  LalamoveDemo
//
//  Created by oOEric on 4/6/2017.
//  Copyright © 2017 Eric Cheung. All rights reserved.
//

import UIKit
import Alamofire
import MapKit
import CoreLocation

let screenSize = UIScreen.main.bounds
let marginBetweenItems: CGFloat = 20.0
let itemLabelHeight: CGFloat = 70.0
let itemImageViewTagBase: Int = 100
let itemLabelTagBase: Int = 200
let mainImageDetailViewHeight: CGFloat = 200.0
let mapViewHeight: CGFloat = 120.0


class ViewController: UIViewController, MKMapViewDelegate {
    
    var imageView: UIImageView = UIImageView()
    var scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
    
    var mainLabel:UILabel = UILabel()
    var blackView:UIView = UIView()
    var mainImageView:UIImageView = UIImageView()
    var closeButton:UIButton = UIButton()
    
    var allItems:[[String:Any]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        dlog(message: "app begins")

        
        Alamofire.request("http://localhost:8080/deliveries", method: .get, parameters: ["offset":"0"], encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if let data = response.result.value{
                    
                    let result: [[String:Any]] = data as! [[String:Any]]
                    
                    UserDefaults.standard.set(result, forKey: "allItems")
                    
                    print(data)
                    
                    self.generateInterface(receivedResult: result)
                }
                break
                
            case .failure(_):
                print(response.result.error)
                
                dlog(message: "can't load the server data")
                if let result = UserDefaults.standard.array(forKey: "allItems") as? [[String: Any]] {
                    
                    dlog(message: "use local data")
                    self.generateInterface(receivedResult: result)
                    
                } else {
                    self.showErrorMessage()
                }
                
                
                break
                
            }
        }


        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func showErrorMessage() {
        let actionSheetController: UIAlertController = UIAlertController(title: "Network Error", message: "Can't connect to server", preferredStyle: .alert)
        let okAction: UIAlertAction = UIAlertAction(title: "OK", style: .default) { action -> Void in

        }
        actionSheetController.addAction(okAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    func generateInterface(receivedResult:[[String:Any]]) {
//        print("result: \(receivedResult[0])")
        
//        scrollView.backgroundColor = UIColor.orange
        self.view.addSubview(scrollView)
        scrollView.isScrollEnabled = true
        
        var scrollViewContentView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: marginBetweenItems))
        
        var startingPositionX:CGFloat = marginBetweenItems
        var startingPositionY:CGFloat = marginBetweenItems
        
        allItems = receivedResult
        
        var index = 0
        for singleItem:[String:Any] in allItems {
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
        
        mainImageView = UIImageView(frame: mainImageViewframe)
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
        mainLabel.numberOfLines = 0
        
        var index = 0
        for singleItem:[String:Any] in allItems {
            
            if index == aButton.tag {
                
                let location:[String:Any] = singleItem["location"] as! [String : Any]
                let addressString:String = location["address"] as! String
                
                mainLabel.text = mainLabel.text! + "\n" + addressString
                break
            }
            
            index = index + 1
        }
        
        mainLabel.textAlignment = .center
        mainLabel.textColor = UIColor.white.withAlphaComponent(0)
        mainLabel.font = UIFont(name: "HelveticaNeue-Light", size: 20)
        
        blackView.addSubview(mainLabel)
        
        
        //close button
        closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: mainImageViewFrameAfterAnimation.origin.x - 20,
                                   y: mainImageViewFrameAfterAnimation.origin.y - 20,
                                   width: 40,
                                   height: 40)
        closeButton.setImage(UIImage(named: "close"), for: .normal)
        closeButton.addTarget(self, action: #selector(self.tappedCloseButton(aButton:)), for: .touchUpInside)
        closeButton.alpha = 0
        
        
        blackView.addSubview(closeButton)
        
        
        
        //animation after tap button
        UIView.animate(withDuration: 0.5) {
            self.blackView.backgroundColor = UIColor.black.withAlphaComponent(0.85)
            
            self.mainImageView.frame = mainImageViewFrameAfterAnimation
            
            self.closeButton.alpha = 1
            
            self.uiProcessingAfterAnimation(aButton: aButton)
            
        }
        
        
        
    }
    
    func uiProcessingAfterAnimation(aButton:UIButton) {
        mainLabel.textColor = UIColor.white.withAlphaComponent(1)
        
        var lat:CLLocationDegrees = 0
        var lng:CLLocationDegrees = 0
        
        var index = 0
        for singleItem:[String:Any] in allItems {
            
            if index == aButton.tag {
                
                let location:[String:Any] = singleItem["location"] as! [String : Any]
                lat = location["lat"] as! CLLocationDegrees
                lng = location["lng"] as! CLLocationDegrees

                break
            }
            
            index = index + 1
        }
        
        
        var mainMap: MKMapView = MKMapView(frame: CGRect(x: mainLabel.frame.origin.x,
                                                        y: mainLabel.frame.origin.y + mainLabel.frame.size.height + marginBetweenItems*2,
                                                        width: mainLabel.frame.size.width,
                                                        height: mapViewHeight))
        
        let center = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mainMap.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        mainMap.addAnnotation(annotation)
        
        blackView.addSubview(mainMap)
        
        

        
        
        
    }
    
    func tappedCloseButton(aButton:UIButton) {
        blackView.removeFromSuperview()
        blackView = UIView()
    }

}

