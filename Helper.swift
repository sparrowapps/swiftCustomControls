//
//  Helper.swift
//  SmartBand
//
//  Created by sparrow on 2016. 1. 14..
//  Copyright © 2016년 sparrowapps. All rights reserved.
//

// 유틸리티 클래스

import CoreLocation
import Foundation
import SystemConfiguration.CaptiveNetwork
import UIKit

class Helper {
    
    static let sharedInstance = Helper()
    
    static func dateStrToHourMin(str: String) -> (Int,Int){
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let range = str.rangeOfString(" ")
        let substr = str.substringWithRange(str.startIndex..<(range?.endIndex)!)
        
        if let date = dateFormatter.dateFromString(substr) {
        
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Hour, .Minute], fromDate: date)
        
            return (components.hour, components.minute)
        } else {
            return (0,0)
        }
    }
    
    // 1,000 천단위 콤마 스타일
    static func numberDecimalStyleStr(n: Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.numberStyle = .DecimalStyle
        formatter.maximumFractionDigits = 0
        return formatter.stringFromNumber(n)!
    }
   
   
    //#import <CommonCrypto/CommonCrypto.h> 브리지 헤더에 추가
    // Swift 2.0, minor warning on Swift 1.2
    static func md5(string string: String) -> String {
        var digest = [UInt8](count: Int(CC_MD5_DIGEST_LENGTH), repeatedValue: 0)
        if let data = string.dataUsingEncoding(NSUTF8StringEncoding) {
            CC_MD5(data.bytes, CC_LONG(data.length), &digest)
        }
        
        var digestHex = ""
        for index in 0..<Int(CC_MD5_DIGEST_LENGTH) {
            digestHex += String(format: "%02x", digest[index])
        }
        
        return digestHex
    }
    
    //#include <ifaddrs.h>
    // 아이피 address 
    static func getIFAddresses() -> [String] {
        var addresses = [String]()
        
        // Get list of all interfaces on the local machine:
        var ifaddr : UnsafeMutablePointer<ifaddrs> = nil
        if getifaddrs(&ifaddr) == 0 {
            
            // For each interface ...
            for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
                let flags = Int32(ptr.memory.ifa_flags)
                var addr = ptr.memory.ifa_addr.memory
                
                // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        
                        // Convert interface address to a human readable string:
                        var hostname = [CChar](count: Int(NI_MAXHOST), repeatedValue: 0)
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),
                            nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                                if let address = String.fromCString(hostname) {
                                    addresses.append(address)
                                }
                        }
                    }
                }
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses
    }
    
    // 경로 얻기
    static func getDocumentsDirectory() -> NSString {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    // 이미지 위에 글 쓰기 (넘버링)
    static func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        //let textFont: UIFont = UIFont(name:"Helvetica Bold", size: 12)!
        let textFont: UIFont = UIFont.init(name:"Helvetica Bold", size: 12)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
    }
    
    // 이미지 위에 글 쓰기 (넘버링)
    static func textToImage(drawText: NSString, inImage: UIImage, atPoint:CGPoint, fontSize:CGFloat)->UIImage{
        
        // Setup the font specific variables
        let textColor: UIColor = UIColor.whiteColor()
        let textFont: UIFont = UIFont(name: "Helvetica Bold", size: fontSize)!
        
        //Setup the image context using the passed image.
        UIGraphicsBeginImageContext(inImage.size)
        
        //Setups up the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: textFont,
            NSForegroundColorAttributeName: textColor,
        ]
        
        //Put the image into a rectangle as large as the original image.
        inImage.drawInRect(CGRectMake(0, 0, inImage.size.width, inImage.size.height))
        
        // Creating a point within the space that is as bit as the image.
        let rect: CGRect = CGRectMake(atPoint.x, atPoint.y, inImage.size.width, inImage.size.height)
        
        //Now Draw the text into an image.
        drawText.drawInRect(rect, withAttributes: textFontAttributes)
        
        // Create a new image out of the images we have created
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //And pass it back up to the caller.
        return newImage
    }

    static func getWiFiSSID() -> String? {
        var ssid: String?
        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
            for interface in interfaces {
                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                    break
                }
            }
        }
        return ssid
    }

        static func getAddressString(manager: CLLocationManager, completion: (answer: String?) -> Void) {
        let geoCoder = CLGeocoder()
        var addressString : String = ""
        
        geoCoder.reverseGeocodeLocation(manager.location!, completionHandler: {
            (placemarks, error) -> Void in
            var placemark:CLPlacemark!
            
            if error == nil {
                if placemarks!.count > 0 {
                    
                    placemark = placemarks![0] as CLPlacemark
                    
                    if placemark.locality != nil {
                        addressString =  placemark.locality!
                    }
                    if placemark.thoroughfare != nil {
                        addressString = addressString + " " + placemark.thoroughfare!
                    }
                    completion(answer: addressString)
                }
            } else {
                print (error)
                completion(answer: "" )
            }
        })
    }

}
