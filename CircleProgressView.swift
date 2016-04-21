//
//  CircleProgressView.swift
//
//
//  Created by Eric Rolf on 8/11/14.
//  Copyright (c) 2014 Eric Rolf, Cardinal Solutions Group. All rights reserved.
//

import UIKit

@objc @IBDesignable public class CircleProgressView: UIView {

    private struct Constants {
        let circleDegress = 360.0
        let minimumValue = 0.000000
        let maximumValue = 0.999999
        let ninetyDegrees = 90.0
        let twoSeventyDegrees = 270.0
        var contentView:UIView = UIView()
    }

    private let constants = Constants()
    private var internalProgress:Double = 0.0

    private var displayLink: CADisplayLink?
    private var destinationProgress: Double = 0.0
    
    @IBInspectable public var progress: Double = 0.000000 {
        didSet {
            internalProgress = progress
            setNeedsDisplay()
        }
    }

    @IBInspectable public var refreshRate: Double = 0.0 {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var roundcap: Bool = false {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var clockwise: Bool = true {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var trackWidth: CGFloat = 10 {
        didSet { setNeedsDisplay() }
    }
    
    //중심선
    @IBInspectable public var centertrackWidth: CGFloat = 2 {
        didSet { setNeedsDisplay() }
    }
    
    // track bakground image
    @IBInspectable public var trackBackgroundImage: UIImage? {
        didSet { setNeedsDisplay() }
    }
    
    // track image
    @IBInspectable public var trackImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var trackBackgroundColor: UIColor = UIColor.clearColor() {
        didSet { setNeedsDisplay() }
    }
    
    //중심선 칼러
    @IBInspectable public var centertrackColor: UIColor = UIColor.grayColor() {
        didSet { setNeedsDisplay() }
    }


    @IBInspectable public var trackFillColor: UIColor = UIColor.blueColor() {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var trackBorderColor:UIColor = UIColor.clearColor() {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var trackBorderWidth: CGFloat = 0 {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var centerFillColor: UIColor = UIColor.whiteColor() {
        didSet { setNeedsDisplay() }
    }
    
    @IBInspectable public var centerImage: UIImage? {
        didSet { setNeedsDisplay() }
    }

    @IBInspectable public var contentView: UIView {
        return self.constants.contentView
    }

    required override public init(frame: CGRect) {
        super.init(frame: frame)
        internalInit()
        self.addSubview(contentView)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        internalInit()
        self.addSubview(contentView)
    }
    
    func internalInit() {
        displayLink = CADisplayLink(target: self, selector: Selector("displayLinkTick"))
    }
    
    override public func drawRect(rect: CGRect) {
        
        super.drawRect(rect)
        
        let innerRect = CGRectInset(rect, trackBorderWidth, trackBorderWidth)
        
        internalProgress = (internalProgress/1.0) == 0.0 ? constants.minimumValue : progress
        internalProgress = (internalProgress/1.0) == 1.0 ? constants.maximumValue : internalProgress
        internalProgress = clockwise ?
                                (-constants.twoSeventyDegrees + ((1.0 - internalProgress) * constants.circleDegress)) :
                                (constants.ninetyDegrees - ((1.0 - internalProgress) * constants.circleDegress))
        
        let context = UIGraphicsGetCurrentContext()
        
        
        //center track Drawing
        let centerTrackPath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX + trackWidth/2.0, innerRect.minY + trackWidth/2.0, CGRectGetWidth(innerRect) - (trackWidth), CGRectGetHeight(innerRect) - (trackWidth)))
        centerTrackPath.lineWidth = centertrackWidth
        centertrackColor.setStroke()
        centerTrackPath.stroke()
        
        // 트랙 백그라운드 이미지 or background Drawing
        let circlePath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect)))
        if trackBackgroundImage != nil {
            trackBackgroundImage!.drawInRect(innerRect)
        } else {
            trackBackgroundColor.setFill()
            circlePath.fill()
        }

        if trackBorderWidth > 0 {
            circlePath.lineWidth = trackBorderWidth
            trackBorderColor.setStroke()
            circlePath.stroke()
        }
        
        // progress Drawing
        let progressPath = UIBezierPath()
        let progressRect: CGRect = CGRectMake(innerRect.minX, innerRect.minY, CGRectGetWidth(innerRect), CGRectGetHeight(innerRect))
        let center = CGPointMake(progressRect.midX, progressRect.midY)
        let radius = progressRect.width / 2.0
        let startAngle:CGFloat = clockwise ? CGFloat(-internalProgress * M_PI / 180.0) : CGFloat(constants.twoSeventyDegrees * M_PI / 180)
        let endAngle:CGFloat = clockwise ? CGFloat(constants.twoSeventyDegrees * M_PI / 180) : CGFloat(-internalProgress * M_PI / 180.0)
        
        progressPath.addArcWithCenter(center, radius:radius, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
        progressPath.addLineToPoint(CGPointMake(progressRect.midX, progressRect.midY))
        progressPath.closePath()
        CGContextSaveGState(context)
        progressPath.addClip()
        
        // 라운드캡 : 이 프로퍼티가 켜지면 트랙 백그라운드 이미지는 소용 없다.
        if roundcap {
            let progressCircle = CAShapeLayer()
            let progressPath2 = UIBezierPath()
            progressPath2.addArcWithCenter(center, radius:radius - trackWidth/2, startAngle:startAngle, endAngle:endAngle, clockwise:!clockwise)
            
            progressCircle.path = progressPath2.CGPath
            progressCircle.position = CGPointMake(progressRect.minX, progressRect.minY)
            progressCircle.fillColor = UIColor.clearColor().CGColor
            progressCircle.strokeColor = trackFillColor.CGColor
            progressCircle.lineCap = kCALineCapRound
            progressCircle.lineWidth = trackWidth
            self.layer.addSublayer(progressCircle)
        }
        
        if trackImage != nil {
            trackImage!.drawInRect(innerRect)
        } else {
            trackFillColor.setFill()
            circlePath.fill()
        }
        
        CGContextRestoreGState(context)
        
        // center Drawing
        let centerPath = UIBezierPath(ovalInRect: CGRectMake(innerRect.minX + trackWidth, innerRect.minY + trackWidth , CGRectGetWidth(innerRect) - (2 * trackWidth), CGRectGetHeight(innerRect) - (2 * trackWidth)))
        centerFillColor.setFill()
        centerPath.fill()
        
        if let centerImage = centerImage {
            CGContextSaveGState(context)
            centerPath.addClip()
            centerImage.drawInRect(rect)
            CGContextRestoreGState(context)
        } else {
            let layer = CAShapeLayer()
            layer.path = centerPath.CGPath
            contentView.layer.mask = layer
        }
    }
    
    //MARK: - Progress Update
    
    public func setProgress(newProgress: Double, animated: Bool) {
        if newProgress >= 1.0 {
            if animated {
                destinationProgress = 1.0
                displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            } else {
                progress = 1.0
            }
        } else {
            if animated {
                destinationProgress = newProgress
                displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
            } else {
                progress = newProgress
            }
            
        }
    }
    
    //MARK: - CADisplayLink Tick
    
    internal func displayLinkTick() {
            
        let renderTime = refreshRate.isZero ? displayLink!.duration : refreshRate

        if destinationProgress > progress {
            progress += renderTime
            if progress >= destinationProgress {
                progress = destinationProgress
                displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                return
            }
        }
        
        if destinationProgress < progress {
            progress -= renderTime
            if progress <= destinationProgress {
                progress = destinationProgress
                displayLink?.removeFromRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
                return
            }
        }
    }
}
