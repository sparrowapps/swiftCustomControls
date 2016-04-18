import UIKit

public enum IconLabelPosition {
    case Left, Right
}

@IBDesignable public class IconLabel: UILabel {
    
    /** Image that will be placed with a text*/
    @IBInspectable public var icon: UIImage?
    
    /** Position of an image */
    @IBInspectable public var iconPosition: IconLabelPosition = .Left
    
    /** Additional spacing between text and image */
    @IBInspectable public var iconPadding: CGFloat = 0
    
    @IBInspectable public var iconVisible: Bool = true
    
    // MARK: Privates
    
    private var iconView: UIImageView?
    
    // MARK: Custom text drawings
    
    public override func drawTextInRect(rect: CGRect) {
        if numberOfLines != 1 || icon == nil {
            super.drawTextInRect(rect)
            return
        }
        
        if iconVisible == true {
            if let icon = icon {
                iconView?.removeFromSuperview()
                iconView = UIImageView(image: icon)
                
                var newRect: CGRect = CGRectZero
                var size: CGSize = frame.size
                
                if let text = self.text as NSString? {
                    size = text.boundingRectWithSize(CGSizeMake(frame.width, frame.height),
                        options: NSStringDrawingOptions.UsesLineFragmentOrigin,
                        attributes: [ NSFontAttributeName : font ],
                        context: nil).size
                }
                
                if let iconView = iconView {
                    if iconPosition == .Left {
                        if textAlignment == .Left {
                            iconView.frame = CGRectOffset(iconView.frame, 0, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake(iconView.frame.width + iconPadding, 0, frame.width - (iconView.frame.width + iconPadding), frame.height)
                        } else if textAlignment == .Right {
                            iconView.frame = CGRectOffset(iconView.frame, frame.width - size.width - iconView.frame.width - iconPadding, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake(frame.width - size.width - iconPadding, 0, size.width + iconPadding, frame.height)
                        } else if textAlignment == .Center {
                            iconView.frame = CGRectOffset(iconView.frame, (frame.width - size.width) / 2 - iconPadding - iconView.frame.width, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake((frame.width - size.width) / 2, 0, size.width + iconPadding, frame.height)
                        }
                    } else if iconPosition == .Right {
                        if textAlignment == .Left {
                            iconView.frame = CGRectOffset(iconView.frame, size.width + iconPadding, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake(0, 0, frame.width - frame.width, frame.height)
                        } else if textAlignment == .Right {
                            iconView.frame = CGRectOffset(iconView.frame, frame.width - iconView.frame.width, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake(frame.width - size.width - iconView.frame.width - iconPadding, 0, size.width, frame.height)
                        } else if textAlignment == .Center {
                            iconView.frame = CGRectOffset(iconView.frame, frame.width / 2 + size.width / 2 + iconPadding, (frame.height - iconView.frame.height) / 2)
                            newRect = CGRectMake((frame.width - size.width) / 2, 0, size.width, frame.height)
                        }
                    }
                    
                    addSubview(iconView)
                    super.drawTextInRect(newRect)
                }
            }
        }
    }
    
}
