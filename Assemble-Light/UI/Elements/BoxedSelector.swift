//  Assemble
//  Created by David Spry on 27/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class BoxedSelector: ASSegmentedControl {

    internal let selectionBox = UIView()
    internal var selectionBoxX: NSLayoutConstraint!
    internal var selectionBoxW: NSLayoutConstraint!
    
    override func stylise() {
        super.stylise()
        
        selectionBox.translatesAutoresizingMaskIntoConstraints = false
        selectionBox.backgroundColor = UIColor.clear
        selectionBox.layer.borderColor = UIColor.init(named: "Foreground")?.cgColor
        selectionBox.layer.borderWidth = 2.0
        addSubview(selectionBox)

        constrainSelectionBox()
    }
    
    private func constrainSelectionBox() {
        let itemWidth = widthForSegment(at: selectedSegmentIndex)
        selectionBoxX = selectionBox.centerXAnchor.constraint(equalTo: leadingAnchor)
        selectionBoxW = selectionBox.widthAnchor.constraint(equalToConstant: itemWidth)

        NSLayoutConstraint.activate([
            selectionBoxX,
            selectionBoxW,
            selectionBox.centerYAnchor.constraint(equalTo: centerYAnchor),
            selectionBox.heightAnchor.constraint(equalTo: heightAnchor),
            selectionBox.topAnchor.constraint(equalTo: topAnchor),
            selectionBox.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        selectionBoxX.constant = itemWidth * 0.5
        selectionBox.layoutIfNeeded()
    }
    
    override func setCustomFont() {
        super.setCustomFont()
        let colour = UIColor.init(named: "Foreground") ?? UIColor.lightText
        setTitleTextAttributes([.foregroundColor : colour], for: .selected)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        selectionBox.layer.borderColor = UIColor.init(named: "Foreground")?.cgColor
        selectionBox.layer.borderWidth = 2.0
        selectionBox.setNeedsDisplay()
    }
    
    public func setSelectionWithoutAction(to index: Int? = nil) {
        if let index = index, index > 0, index < numberOfSegments { selectedSegmentIndex = index }
        DispatchQueue.main.async {
            var margin: CGFloat = 0.0
            let width:  CGFloat = self.widthForSegment(at: self.selectedSegmentIndex)
            for i in 0 ..< self.selectedSegmentIndex {
                margin = margin + self.widthForSegment(at: i)
            }

            UIView.animate(withDuration: 0.075, delay: .zero, options: [.curveEaseOut], animations: {
                self.selectionBoxW.constant = width
                self.selectionBoxX.constant = margin + width * 0.5
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    override func sendActions(for controlEvents: UIControl.Event) {
        super.sendActions(for: controlEvents)
        
        if controlEvents == .valueChanged {
            setSelectionWithoutAction()
        }
    }

    override func setCustomAppearance() {
        super.setCustomAppearance()
        let clear = UIImage.init(color: UIColor.clear, size: CGSize(width: 1.0, height: bounds.height))
        setBackgroundImage(clear, for: .normal, barMetrics: .default)
    }

}
