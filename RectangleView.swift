//
//  RectangleView.swift
//
//  Created by sparrow on 2016. 1. 23..
//  Copyright © 2016년 sparrowapps. All rights reserved.
//

import UIKit

@IBDesignable class RectangleView: UIView {
    
    @IBInspectable var lineColor: UIColor = UIColor.grayColor()
    @IBInspectable var lineWidth: CGFloat = 1

    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        let path = CGPathCreateMutable()
        
        let rectangle = CGRect(x: 0, y: 0, width: width, height: height)
        
        
        CGPathAddRect(path, nil, rectangle)
        
        let currentContext = UIGraphicsGetCurrentContext()
        
        CGContextAddPath(currentContext, path)
        
        lineColor.setStroke()
        
        CGContextSetLineWidth(currentContext, lineWidth)
        
        CGContextDrawPath(currentContext, .Stroke)
    }
}
