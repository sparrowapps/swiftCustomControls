//
//  BarChartView.swift
//
//  Created by sparrow on 2016. 1. 17..
//  Copyright © 2016년 sparrowapps. All rights reserved.
//

import UIKit

@IBDesignable class BarChartView: UIView {
    //Weekly sample data
    var graphPoints:[Int] = [1, 1, 2, 3, 1, 2, 2]
    
    //1 - the properties for the gradient
    
    // 플러스 영역 막대 그래프 이미지
    @IBInspectable var plusImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    override func drawRect(rect: CGRect) {
        
        let width = rect.width
        let height = rect.height
        
        //calculate the x point
        let margin:CGFloat = 20.0
        let columnXPoint = { (column:Int) -> CGFloat in
            //Calculate gap between points
            let spacer = (width - margin*2 - 4) /
                CGFloat((self.graphPoints.count - 1))
            var x:CGFloat = CGFloat(column) * spacer
            x += margin + 2
            return x
        }
        
        // calculate the y point
        let topBorder:CGFloat = 34
        let bottomBorder:CGFloat = 25
        let graphHeight = height - topBorder - bottomBorder
        let maxValue = graphPoints.maxElement()!
        let columnYPoint = { (graphPoint:Int) -> CGFloat in
            var y:CGFloat = CGFloat(graphPoint) /
                CGFloat(maxValue) * graphHeight
            y = graphHeight + topBorder - y // Flip the graph
            return y
        }
        
        //Draw bar
        if specialOpts == false {
            //Draw horizontal graph lines on the top of everything
            let linePath = UIBezierPath()
            
            //top line
            linePath.moveToPoint(CGPoint(x:0, y: topBorder))
            linePath.addLineToPoint(CGPoint(x: width ,
                y:topBorder))
            
            //center line
            linePath.moveToPoint(CGPoint(x:0,
                y: graphHeight/2 + topBorder))
            linePath.addLineToPoint(CGPoint(x:width ,
                y:graphHeight/2 + topBorder))
            
            //bottom line
            linePath.moveToPoint(CGPoint(x:0,
                y:height - bottomBorder))
            linePath.addLineToPoint(CGPoint(x:width ,
                y:height - bottomBorder))
            let color = UIColor(hex: "d5d5d5")
            color.setStroke()
            
            linePath.lineWidth = 1.0
            linePath.stroke()

            
            // draw bar
            for i in 0..<graphPoints.count {
                var point = CGPoint(x:columnXPoint(i), y:columnYPoint(graphPoints[i]))
                let width  = (columnXPoint(1) - columnXPoint(0)) - 1
                point.x -= ( width / 2.0 )
                let height = (height - bottomBorder) - point.y
                
                let barRect = CGRectMake(point.x, point.y, width, height)
                
                if let barImage = plusImage {
                    barImage.drawInRect(barRect)
                }
            }
        }
    }
}
