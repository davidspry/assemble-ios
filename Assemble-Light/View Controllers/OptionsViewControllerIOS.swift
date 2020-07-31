//  Assemble
//  Created by David Spry on 27/7/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

class OptionsViewControlleriOS: UIViewController, UIScrollViewDelegate {

    /// The backing panel of the options menu.

    @IBOutlet weak var windowPanel: UIView!

    @IBOutlet weak var scrollView: OptionsScrollView!

    /// Translucent background layer.

    @IBOutlet weak var backgroundLayer: UIView!

    /// Theme selector

    @IBOutlet weak var themeSelector: BoxedSelector!
    
    /// Filter parameters
    
    @IBOutlet weak var frequencyParameter: NormalParameterLabel!
    @IBOutlet weak var resonanceParameter: NormalParameterLabel!

    /// Envelope selectors

    @IBOutlet weak var sinEnvelopeSelector: BoxedSelector!
    @IBOutlet weak var triEnvelopeSelector: BoxedSelector!
    @IBOutlet weak var sqrEnvelopeSelector: BoxedSelector!
    @IBOutlet weak var sawEnvelopeSelector: BoxedSelector!

    /// Effects selectors
    
    @IBOutlet weak var stereoDelayToggle:   BoxedSelector!
    @IBOutlet weak var vibratoToggle:       BoxedSelector!
    
    /// Reset patterns button

    @IBOutlet weak var clearAllPatternsButton: UIButton!

    weak var delegate: MainViewControlleriOS?
    
    private let backgroundAlpha: CGFloat = 0.75
    
    private lazy var transformHide = CGAffineTransform(translationX: self.windowPanel.bounds.width, y: 0)

    // MARK: - Lifecycle Callbacks

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialiseThemeSelector()
        initialiseFilterParameters()
        initialiseEnvelopeSelectors()
        initialiseEffectsSelectors()
        
        initialisePanelShadow()
        backgroundLayer.alpha = .zero
        windowPanel.layer.setAffineTransform(transformHide)
        
        scrollView.delegate = self
        scrollView.canCancelContentTouches = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25) {
                self.backgroundLayer.alpha = self.backgroundAlpha
                self.windowPanel.layer.setAffineTransform(.identity)
            }
        }
    }
    
    // MARK: - traitCollectionDidChange
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        clearAllPatternsButton.layer.borderColor = UIColor.systemRed.cgColor//UIColor.init(named: "Foreground")?.cgColor
        clearAllPatternsButton.setNeedsDisplay()
    }

    // MARK: - Menu Component Initialisers

    private func initialiseThemeSelector() {
        guard let delegate = delegate else {
            return print("[OptionsViewControlleriOS] Delegate is nil.")
        }

        DispatchQueue.main.async {
            let index: Int = delegate.usingDarkTheme ? 0 : 1
            self.themeSelector.selectedSegmentIndex = index
            self.themeSelector.sendActions(for: .valueChanged)
        }
    }

    private func initialiseFilterParameters() {
        frequencyParameter.setter = { value in
            Assemble.core.setParameter(kSinFilterFrequency, to: value)
            Assemble.core.setParameter(kTriFilterFrequency, to: value)
            Assemble.core.setParameter(kSqrFilterFrequency, to: value)
            Assemble.core.setParameter(kSawFilterFrequency, to: value)
        }
        
        frequencyParameter.getter = {
            var value: Float = 0.0
            value = max(value, Assemble.core.getParameter(kSinFilterFrequency))
            value = max(value, Assemble.core.getParameter(kTriFilterFrequency))
            value = max(value, Assemble.core.getParameter(kSqrFilterFrequency))
            value = max(value, Assemble.core.getParameter(kSawFilterFrequency))
            return value
        }
        
        resonanceParameter.setter = { value in
            Assemble.core.setParameter(kSinFilterResonance, to: value)
            Assemble.core.setParameter(kTriFilterResonance, to: value)
            Assemble.core.setParameter(kSqrFilterResonance, to: value)
            Assemble.core.setParameter(kSawFilterResonance, to: value)
        }
        
        resonanceParameter.getter = {
            var value: Float = 0.0
            value = max(value, Assemble.core.getParameter(kSinFilterResonance))
            value = max(value, Assemble.core.getParameter(kTriFilterResonance))
            value = max(value, Assemble.core.getParameter(kSqrFilterResonance))
            value = max(value, Assemble.core.getParameter(kSawFilterResonance))
            return value
        }
    }

    private func initialiseEnvelopeSelectors() {
        guard let delegate = delegate else {
            return print("[OptionsViewControlleriOS] Delegate is nil.")
        }
        
        DispatchQueue.main.async {
            self.sinEnvelopeSelector.setSelectionWithoutAction(to: delegate.envelopePresets[0])
            self.triEnvelopeSelector.setSelectionWithoutAction(to: delegate.envelopePresets[1])
            self.sqrEnvelopeSelector.setSelectionWithoutAction(to: delegate.envelopePresets[2])
            self.sawEnvelopeSelector.setSelectionWithoutAction(to: delegate.envelopePresets[3])
        }
    }

    private func initialiseEffectsSelectors() {
        DispatchQueue.main.async {
            self.vibratoToggle.setSelectionWithoutAction(to: Int(Assemble.core.getParameter(kVibratoToggle)))
            self.stereoDelayToggle.setSelectionWithoutAction(to: Int(Assemble.core.getParameter(kStereoDelayToggle)))
        }
    }

    // MARK: - Window Panel Shadow

    internal func initialisePanelShadow() {
        let rect = CGRect(x: windowPanel.bounds.minX, y: windowPanel.bounds.minY,
                          width: 10.0, height: windowPanel.bounds.height)
        let shadowPath = UIBezierPath(rect: rect)

        windowPanel.layer.shadowOffset  = .zero
        windowPanel.layer.shadowRadius  = 10.0
        windowPanel.layer.shadowOpacity = 0.20
        windowPanel.layer.shadowColor = UIColor.black.cgColor
        windowPanel.layer.shadowPath  = shadowPath.cgPath
        windowPanel.layer.rasterizationScale = UIScreen.main.scale
    }
    
    // MARK: - Menu Component Actions

    @IBAction func didSetTheme(_ sender: UISegmentedControl) {
        guard let delegate = delegate else {
            print("[OptionsViewControlleriOS] Delegate is nil.")
            return
        }

        let isDarkTheme = sender.selectedSegmentIndex == 0
        delegate.usingDarkTheme = isDarkTheme ? true : false
        delegate.loadVisualTheme()
    }

    @IBAction func didSetEnvelope(_ sender: UISegmentedControl) {
        guard let delegate = delegate else {
            return print("[OptionsViewControlleriOS] Delegate is nil.")
        }

        let preset = sender.selectedSegmentIndex

        switch sender {
        case sinEnvelopeSelector:
            delegate.envelopePresets[0] = preset
            setEnvelope(to: preset, for: .sine)
        case triEnvelopeSelector:
            delegate.envelopePresets[1] = preset
            setEnvelope(to: preset, for: .triangle)
        case sqrEnvelopeSelector:
            delegate.envelopePresets[2] = preset
            setEnvelope(to: preset, for: .square)
        case sawEnvelopeSelector:
            delegate.envelopePresets[3] = preset
            setEnvelope(to: preset, for: .sawtooth)
        default: return
        }
    }

    private func setEnvelope(to preset: Int, for oscillator: OscillatorShape) {
        let filter:    [(a: Float, h: Float, r: Float)]!
        let amplitude: [(a: Float, h: Float, r: Float)]!
            filter    = [(15.0, 0.0, 250.0), (35.0, 0.0, 1450.0)]
            amplitude = [( 5.0, 0.0, 450.0), (10.0, 0.0, 1600.0)]

        if preset >= filter.count || preset >= amplitude.count {
            return print("[OptionsViewControlleriOS] Unknown preset.")
        }

        switch oscillator {
        case .sine:
            Assemble.core.setParameter(kSinAmpAttack,  to: amplitude[preset].a)
            Assemble.core.setParameter(kSinAmpHold,    to: amplitude[preset].h)
            Assemble.core.setParameter(kSinAmpRelease, to: amplitude[preset].r)
            Assemble.core.setParameter(kSinFilterAttack,  to: filter[preset].a)
            Assemble.core.setParameter(kSinFilterHold,    to: filter[preset].h)
            Assemble.core.setParameter(kSinFilterRelease, to: filter[preset].r)
        case .square:
            Assemble.core.setParameter(kSqrAmpAttack,  to: amplitude[preset].a)
            Assemble.core.setParameter(kSqrAmpHold,    to: amplitude[preset].h)
            Assemble.core.setParameter(kSqrAmpRelease, to: amplitude[preset].r)
            Assemble.core.setParameter(kSqrFilterAttack,  to: filter[preset].a)
            Assemble.core.setParameter(kSqrFilterHold,    to: filter[preset].h)
            Assemble.core.setParameter(kSqrFilterRelease, to: filter[preset].r)
        case .triangle:
            Assemble.core.setParameter(kTriAmpAttack,  to: amplitude[preset].a)
            Assemble.core.setParameter(kTriAmpHold,    to: amplitude[preset].h)
            Assemble.core.setParameter(kTriAmpRelease, to: amplitude[preset].r)
            Assemble.core.setParameter(kTriFilterAttack,  to: filter[preset].a)
            Assemble.core.setParameter(kTriFilterHold,    to: filter[preset].h)
            Assemble.core.setParameter(kTriFilterRelease, to: filter[preset].r)
        case .sawtooth:
            Assemble.core.setParameter(kSawAmpAttack,  to: amplitude[preset].a)
            Assemble.core.setParameter(kSawAmpHold,    to: amplitude[preset].h)
            Assemble.core.setParameter(kSawAmpRelease, to: amplitude[preset].r)
            Assemble.core.setParameter(kSawFilterAttack,  to: filter[preset].a)
            Assemble.core.setParameter(kSawFilterHold,    to: filter[preset].h)
            Assemble.core.setParameter(kSawFilterRelease, to: filter[preset].r)
        default: return
        }
    }

    @IBAction func didToggleEffect(_ sender: BoxedSelector) {
        switch sender {
        case stereoDelayToggle:
            let state = Bool(Int(Assemble.core.getParameter(kStereoDelayToggle)))
            Assemble.core.setParameter(kStereoDelayToggle, to: !(state))
        case vibratoToggle:
            let state = Bool(Int(Assemble.core.getParameter(kVibratoToggle)))
            Assemble.core.setParameter(kVibratoToggle, to: !(state))
        default: return
        }
    }

    @IBAction func didPressClearAllPatterns(_ sender: UIButton) {
        guard let delegate = delegate else {
            print("[OptionsViewControlleriOS] Delegate is nil.")
            return
        }
        
        delegate.didResetAllPatterns()
    }
    
    // MARK: - Close Options Menu

    @IBAction func didPressClose(_ sender: UIButton) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundLayer.alpha = .zero
                self.windowPanel.layer.setAffineTransform(self.transformHide)
            }) { complete in self.dismiss(animated: false, completion: nil) }
        }
    }
    
    // MARK: - UIScrollView Delegate
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let recogniser = scrollView.panGestureRecognizer
        let usingParameter = frequencyParameter.point(inside: recogniser.location(in: frequencyParameter), with: nil) ||
                             resonanceParameter.point(inside: recogniser.location(in: resonanceParameter), with: nil)

        scrollView.isScrollEnabled = !(usingParameter)
    }

    // MARK: - Touch Callbacks

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let touch = touches.first else { return }
        let location = touch.location(in: windowPanel)
        let shouldDismiss  = !(windowPanel.point(inside: location, with: nil))
        if  shouldDismiss {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.25, animations: {
                    self.backgroundLayer.alpha = .zero
                    self.windowPanel.layer.setAffineTransform(self.transformHide)
                }) { complete in self.dismiss(animated: false, completion: nil) }
            }
        }
    }

}
