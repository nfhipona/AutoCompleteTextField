//
//  AutoCompleteTextField.swift
//  Pods
//
//  Created by Neil Francis Hipona on 19/03/2016.
//  Copyright (c) 2016 Neil Francis Ramirez Hipona. All rights reserved.
//

import Foundation
import UIKit


public class AutoCompleteTextField: UITextField {
    
    /// AutoCompleteTextField data source
    weak public var dataSource: ACTFDataSource?
    
    /// AutoCompleteTextField data source accessible through IB
    @IBOutlet weak internal var actfDataSource: AnyObject? {
        didSet {
            dataSource = actfDataSource as? ACTFDataSource
        }
    }
    
    fileprivate var actfLabel: ACTFLabel!
    fileprivate var delimiter: CharacterSet?
    
    fileprivate var xOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .bezel, .roundedRect:
                return 6.0
            case .line:
                return 1.0
                
            default:
                return 0.0
            }
        }
    }
    
    fileprivate var yOffsetCorrection: CGFloat {
        get {
            switch borderStyle {
            case .line, .roundedRect:
                return 0.5
                
            default:
                return 0.0
            }
        }
    }
    
    /// Auto completion flag
    public var autoCompleteDisabled: Bool = false
    
    /// Case search
    public var ignoreCase: Bool = true
    
    /// Randomize suggestion flag. Default to ``false, will always use first found suggestion
    public var isRandomSuggestion: Bool = false
    
    /// Supported domain names
    static public let domainNames: [ACTFDomain] = {
        return SupportedDomainNames
    }()
    
    /// Text font settings
    override public var font: UIFont? {
        didSet { actfLabel.font = font }
    }
    
    public var suggestionColor: UIColor? {
        didSet {
            actfLabel.textColor = suggestionColor
        }
    }
    
    // MARK: - Initialization
    
    override fileprivate init(frame: CGRect) {
        super.init(frame: frame)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        prepareLayers()
        setupTargetObserver()
    }
    
    /// Initialize `AutoCompleteTextField` with `AutoCompleteTextFieldDataSource` and optional `AutoCompleteTextFieldDelegate`
    convenience public init(frame: CGRect, dataSource source: ACTFDataSource? = nil, delegate d: UITextFieldDelegate? = nil) {
        self.init(frame: frame)
        
        dataSource = source
        delegate = d
        
        prepareLayers()
        setupTargetObserver()
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        prepareLayers()
        setupTargetObserver()
    }
    
    // MARK: - Responders
    
    override public func becomeFirstResponder() -> Bool {
        let becomeFirstResponder = super.becomeFirstResponder()
        
        if !autoCompleteDisabled {
            actfLabel.isHidden = false
            
            if clearsOnBeginEditing {
                actfLabel.text = ""
            }
            
            processAutoCompleteEvent()
        }
        
        return becomeFirstResponder
    }
    
    override public func resignFirstResponder() -> Bool {
        let resignFirstResponder = super.resignFirstResponder()
        
        if !autoCompleteDisabled {
            actfLabel.isHidden = true
            
            commitAutocompleteText()
        }
        
        return resignFirstResponder
    }
    
    // MARK: - Private Funtions
    
    fileprivate func prepareLayers() {
        
        actfLabel = ACTFLabel(frame: .zero)
        addSubview(actfLabel)
        
        actfLabel.font = font
        actfLabel.backgroundColor = .clear
        actfLabel.textColor = .lightGray
        actfLabel.lineBreakMode = .byClipping
        actfLabel.baselineAdjustment = .alignCenters
        actfLabel.isHidden = true
    }
    
    fileprivate func setupTargetObserver() {
        
        addTarget(self, action: #selector(autoCompleteTextFieldDidChanged(_:)), for: .editingChanged)
    }
    
    fileprivate func performDomainSuggestionsSearch(_ queryString: String) -> ACTFDomain? {
        
        guard let dataSource = dataSource else { return processSourceData(SupportedDomainNames, queryString: queryString) }
        let sourceData = dataSource.autoCompleteTextFieldDataSource(self)
        
        return processSourceData(sourceData, queryString: queryString)
    }
    
    fileprivate func processSourceData(_ dataSource: [ACTFDomain], queryString: String) -> ACTFDomain? {
        
        let stringFilter = ignoreCase ? queryString.lowercased() : queryString
        let suggestedDomains = dataSource.filter { (domain) -> Bool in
            if ignoreCase {
                return domain.text.lowercased().hasPrefix(stringFilter)
            }else{
                return domain.text.hasPrefix(stringFilter)
            }
        }
        
        if suggestedDomains.isEmpty {
            return nil
        }
        
        if isRandomSuggestion {
            let maxCount = suggestedDomains.count
            let randomIdx = arc4random_uniform(UInt32(maxCount))
            let suggestedDomain = suggestedDomains[Int(randomIdx)]
            
            return suggestedDomain
        }else{
            
            guard let suggestedDomain = suggestedDomains.sorted(by: { (domain1, domain2) -> Bool in
                return domain1.weight > domain2.weight && domain1.text < domain2.text
            }).first else { return nil }
            
            return suggestedDomain
        }
    }
    
    fileprivate func performTextCull(domain: ACTFDomain, stringFilter: String) -> String {
        guard let filterRange = ignoreCase ? domain.text.lowercased().range(of: stringFilter) : domain.text.range(of: stringFilter) else { return "" }
        
        let culledString = domain.text.replacingCharacters(in: filterRange, with: "")
        return culledString
    }
    
    fileprivate func actfBoundingRect(_ autocompleteString: String) -> CGRect {
        
        // get bounds for whole text area
        let textRectBounds = textRect(forBounds: bounds)
        
        // get rect for actual text
        guard let textRange = textRange(from: beginningOfDocument, to: endOfDocument) else { return .zero }
        
        let tRect = firstRect(for: textRange).integral
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping
        
        let textAttributes: [NSAttributedString.Key: Any] = [.font: font!, .paragraphStyle: paragraphStyle]
        
        let drawingOptions: NSStringDrawingOptions = [.usesLineFragmentOrigin, .usesFontLeading]
        
        let prefixTextRect = (text ?? "").boundingRect(with: textRectBounds.size, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let autoCompleteRectSize = CGSize(width: textRectBounds.width - prefixTextRect.width, height: textRectBounds.height)
        let autoCompleteTextRect = autocompleteString.boundingRect(with: autoCompleteRectSize, options: drawingOptions, attributes: textAttributes, context: nil)
        
        let xOrigin = tRect.maxX + xOffsetCorrection
        let actfLabelFrame = actfLabel.frame
        let finalX = xOrigin + autoCompleteTextRect.width
        let finalY = textRectBounds.minY + ((textRectBounds.height - actfLabelFrame.height) / 2) - yOffsetCorrection
        
        if finalX >= textRectBounds.width {
            let autoCompleteRect = CGRect(x: textRectBounds.width, y: finalY, width: 0, height: actfLabelFrame.height)
            
            return autoCompleteRect
        }else{
            let autoCompleteRect = CGRect(x: xOrigin, y: finalY, width: autoCompleteTextRect.width, height: actfLabelFrame.height)
            
            return autoCompleteRect
        }
    }
    
    fileprivate func processAutoCompleteEvent() {
        if autoCompleteDisabled { return }
        
        guard let textString = text else { return }
        
        if let delimiter = delimiter {
            guard let _ = textString.rangeOfCharacter(from: delimiter) else { return }
            
            let textComponents = textString.components(separatedBy: delimiter)
            
            if textComponents.count > 2 { return }
            
            guard let textToLookFor = textComponents.last else { return }
            
            let domain = performDomainSuggestionsSearch(textToLookFor)
            updateAutocompleteLabel(domain: domain, originalString: textToLookFor)
        }else{
            let domain = performDomainSuggestionsSearch(textString)
            updateAutocompleteLabel(domain: domain, originalString: textString)
        }
    }
    
    fileprivate func updateAutocompleteLabel(domain: ACTFDomain?, originalString stringFilter: String) {
        
        guard let domain = domain else {
            actfLabel.text = ""
            actfLabel.sizeToFit()
            
            return
        }
        
        let culledString = performTextCull(domain: domain, stringFilter: stringFilter)
        
        actfLabel.domain = domain
        actfLabel.text = culledString
        actfLabel.sizeToFit()
        actfLabel.frame = actfBoundingRect(culledString)
    }
    
    fileprivate func commitAutocompleteText() {
        guard let autoCompleteString = actfLabel.text , !autoCompleteString.isEmpty else { return }
        let originalInputString = text ?? ""
        
        actfLabel.text = ""
        actfLabel.sizeToFit()
        actfLabel.domain.updateWeightUsage()
        actfLabel.domain = nil
        
        text = originalInputString + autoCompleteString
        sendActions(for: .valueChanged)
    }
}

// MARK: - Internal Controls

extension AutoCompleteTextField {
    
    @objc internal func autoCompleteButtonDidTapped(_ sender: UIButton) {
        endEditing(true)
        
        commitAutocompleteText()
    }
    
    @objc internal func autoCompleteTextFieldDidChanged(_ textField: UITextField) {
        
        if !autoCompleteDisabled {
            processAutoCompleteEvent()
        }
    }
}

// MARK: - Public Controls

extension AutoCompleteTextField {
    
    /// Set delimiter. Will perform search if delimiter is found
    public func setDelimiter(_ delimiterString: String) {
        delimiter = CharacterSet(charactersIn: delimiterString)
    }
    
    /// Show complete button with custom image
    public func showAutoCompleteButtonWithImage(_ image: UIImage? = UIImage(named: "checked", in: Bundle(for: AutoCompleteTextField.self), compatibleWith: nil), viewMode: AutoCompleteButtonViewMode) {
        
        var buttonFrameH: CGFloat = 0.0
        var buttonOriginY: CGFloat = 0.0
        
        if frame.height > DefaultButtonHeight {
            buttonFrameH = DefaultButtonHeight
            buttonOriginY = (frame.height - DefaultButtonHeight) / 2
        }else{
            buttonFrameH = frame.height
            buttonOriginY = 0
        }
        
        let buttonFrame = CGRect(x: 0, y: buttonOriginY, width: DefaultButtonWidth, height: buttonFrameH)
        let autoCompleteButton = UIButton(frame: buttonFrame)
        autoCompleteButton.setImage(image, for: .normal)
        autoCompleteButton.addTarget(self, action: #selector(autoCompleteButtonDidTapped(_:)), for: .touchUpInside)
        
        let containerFrame = CGRect(x: 0, y: 0, width: DefaultButtonWidth, height: frame.height)
        let autoCompleteButtonContainerView = UIView(frame: containerFrame)
        autoCompleteButtonContainerView.addSubview(autoCompleteButton)
        
        rightView = autoCompleteButtonContainerView
        rightViewMode = viewMode
    }
    
    /// Force text completion event
    public func forceRefresh() {
        
        processAutoCompleteEvent()
    }
}
