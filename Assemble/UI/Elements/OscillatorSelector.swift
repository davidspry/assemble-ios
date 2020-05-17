//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class OscillatorSelector: UISegmentedControl {

    private var itemWidth: CGFloat = 55
    private let highlight = UIView()
    private var highlightX: NSLayoutConstraint!
    private var oscillators = ["SIN", "TRI", "SQR", "SAW"]
    
    init(itemWidth: CGFloat) {
        super.init(items: oscillators)
        self.itemWidth = itemWidth
        initialise()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(items: oscillators)
        initialise()
    }
    
    private func initialise() {
        backgroundColor = .clear
        selectedSegmentTintColor = .clear
        translatesAutoresizingMaskIntoConstraints = false
        selectedSegmentIndex = 0
        masksToBounds = false
        
        let clear = UIImage(color: .clear, size: .init(width: 1, height: bounds.height))
        setBackgroundImage(clear, for: .normal, barMetrics: .default)
        setDividerImage(clear)
        setFontAttributes()
        
        highlight.translatesAutoresizingMaskIntoConstraints = false
        highlight.backgroundColor = .sineNoteColour
        highlight.layer.cornerCurve = .continuous
        highlight.layer.cornerRadius = 15
        
        addSubview(highlight)
        constrainHighlightView()
        
        DispatchQueue.main.async { self.sendActions(for: .valueChanged) }
    }
    
    private func setFontAttributes() {
        let font = UIFont.init(name: "JetBrainsMono-Regular", size: 14)
        setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .normal)
        setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        setTitleTextAttributes([.foregroundColor : UIColor.lightText], for: .highlighted)
        setTitleTextAttributes([.font : font as Any], for: .normal)
        layoutIfNeeded()
    }
    
    private func constrainHighlightView() {
        highlightX = highlight.centerXAnchor.constraint(equalTo: leadingAnchor)

        NSLayoutConstraint.activate([
            highlightX,
            highlight.widthAnchor.constraint(equalToConstant: itemWidth),
            highlight.centerYAnchor.constraint(equalTo: centerYAnchor),
            highlight.heightAnchor.constraint(equalTo: heightAnchor),
            highlight.topAnchor.constraint(equalTo: topAnchor),
            highlight.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        highlight.layoutIfNeeded()
    }
    
    override func sendActions(for controlEvents: UIControl.Event) {
        super.sendActions(for: controlEvents)
        
        if controlEvents == .valueChanged {
            let width = bounds.width / CGFloat(numberOfSegments)
            let color = UIColor.from(OscillatorShape(rawValue: selectedSegmentIndex) ?? .sine)
            DispatchQueue.main.async
            {
                UIView.animate(withDuration: 0.075, delay: .zero, options: [.curveEaseOut], animations: {
                    self.highlightX.constant = CGFloat(self.selectedSegmentIndex) * width + width * 0.5
                    self.highlight.backgroundColor = color
                    self.layoutIfNeeded()
                }, completion: nil)
            }
        }
    }

}
