//
//  DatePickerViewController.swift
//  Transitions
//
//  Created by Tian Tong on 2019/6/24.
//  Copyright © 2019 TTDP. All rights reserved.
//

import UIKit

fileprivate let redColor = UIColor(hexString: "F54C53")

fileprivate enum TransitionType {
    case presentation, dismissal
}

protocol DatePickerViewControllerDelegate {
    func datePicker(didSelect date: Date)
}

class DatePickerViewController: UIViewController {
    
    fileprivate var transitionType: TransitionType? = .presentation
    
    fileprivate static let overlayerBackgroundColor = UIColor.black.withAlphaComponent(0.4)
    
    var delegate: DatePickerViewControllerDelegate?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.transitioningDelegate = self
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    // MARK: Views
    
    lazy var blurView: UIView = {
        let view = UIView()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cancelDate))
        view.addGestureRecognizer(tapGesture)
        return view
    }()
    
    lazy var dateView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        return view
    }()
    
    let pickerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.text = "Choose Date"
        label.textColor = .lightGray
        return label
    }()
    
    lazy var todayButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Today", for: .normal)
        button.setTitleColor(redColor, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(selectToday), for: .touchUpInside)
        return button
    }()
    
    lazy var pickerView: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        return picker
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.layer.borderColor = redColor?.cgColor
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(redColor, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(cancelDate), for: .touchUpInside)
        button.addTarget(self, action: #selector(cancelDown), for: .touchDown)
        button.addTarget(self, action: #selector(cancelDown), for: .touchDragEnter)
        button.addTarget(self, action: #selector(cancelDragExit), for: .touchDragExit)
        return button
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 5
        button.layer.borderColor = redColor?.cgColor
        button.setTitle("Select", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = redColor
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(selectDate), for: .touchUpInside)
        button.addTarget(self, action: #selector(selectDown), for: .touchDown)
        button.addTarget(self, action: #selector(selectDown), for: .touchDragEnter)
        button.addTarget(self, action: #selector(selectDragExit), for: .touchDragExit)
        return button
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 30
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(cancelButton)
        stackView.addArrangedSubview(selectButton)
        return stackView
    }()
    
    func setupViews() {
        let bottomEdge = ScreenUtility.hasNotch ? 34 : 0
        
        view.addSubview(blurView)
        view.addConstraints(format: "H:|[v0]|", views: blurView)
        view.addConstraints(format: "V:|[v0]|", views: blurView)
        
        view.addSubview(dateView)
        view.addConstraints(format: "H:|-10-[v0]-10-|", views: dateView)
        
        let bottomPadding = 10 + bottomEdge
        view.addConstraints(format: "V:[v0(360)]-\(bottomPadding)-|", views: dateView)
        
        dateView.addSubview(todayButton)
        dateView.addConstraints(format: "H:[v0]-20-|", views: todayButton)
        dateView.addConstraints(format: "V:|-10-[v0]", views: todayButton)
        
        dateView.addSubview(pickerLabel)
        dateView.addConstraints(format: "H:|-20-[v0]", views: pickerLabel)
        pickerLabel.centerYAnchor.constraint(equalTo: todayButton.centerYAnchor).isActive = true
        
        dateView.addSubview(pickerView)
        dateView.addConstraints(format: "H:|[v0]|", views: pickerView)
        dateView.addConstraints(format: "V:|-60-[v0(220)]", views: pickerView)
        
        dateView.addSubview(stackView)
        dateView.addConstraints(format: "H:|-20-[v0]-20-|", views: stackView)
        dateView.addConstraints(format: "V:[v0(44)]-20-|", views: stackView)
    }
    
    // MARK: Actions
    
    @objc func selectToday() {
        pickerView.setDate(Date(), animated: true)
    }
    
    @objc func cancelDate() {
        cancelButton.backgroundColor = .white
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc func cancelDown() {
        cancelButton.backgroundColor = redColor?.withAlphaComponent(0.1)
    }
    
    @objc func cancelDragExit() {
        cancelButton.backgroundColor = .white
    }
    
    @objc func selectDate() {
        selectButton.backgroundColor = redColor
        presentingViewController?.dismiss(animated: true)

        let date = pickerView.date
        delegate?.datePicker(didSelect: date)
    }
    
    @objc func selectDown() {
        selectButton.backgroundColor = redColor?.withAlphaComponent(0.8)
    }
    
    @objc func selectDragExit() {
        selectButton.backgroundColor = redColor
    }
    
}

extension DatePickerViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = (presented == self) ? self : nil
        result?.transitionType = .presentation
        return result
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = (dismissed == self) ? self : nil
        result?.transitionType = .dismissal
        return result
    }
    
}

extension DatePickerViewController: UIViewControllerAnimatedTransitioning {
    
    private var duration: TimeInterval {
        guard let type = transitionType else { fatalError() }
        
        switch type {
        case .presentation:
            return 0.44
        case .dismissal:
            return 0.32
        }
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let type = transitionType else { fatalError() }
        
        let offScreenState = {
            let offScreenY = self.view.bounds.height - self.dateView.frame.minY + 20
            self.dateView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offScreenY)
            self.view.backgroundColor = .clear
        }
        
        let onScreenState = {
            self.dateView.transform = CGAffineTransform.identity
            self.view.backgroundColor = DatePickerViewController.overlayerBackgroundColor
        }
        
        let animator: UIViewPropertyAnimator
        switch type {
        case .presentation:
            animator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.82)
        case .dismissal:
            animator = UIViewPropertyAnimator(duration: duration, curve: .easeIn)
        }
        
        let tabBar: TabBarController?
        switch type {
        case .presentation:
            tabBar = transitionContext.viewController(forKey: .from) as? TabBarController
            tabBar?.setTabBar(hidden: true, animated: true, alongside: animator)
        case .dismissal:
            tabBar = transitionContext.viewController(forKey: .to) as? TabBarController
            tabBar?.setTabBar(hidden: false, animated: true, alongside: animator)
        }
        
        switch type {
        case .presentation:
            let toView = transitionContext.view(forKey: .to)!
            UIView.performWithoutAnimation(offScreenState)
            transitionContext.containerView.addSubview(toView)
            animator.addAnimations(onScreenState)
        case .dismissal:
            animator.addAnimations(offScreenState)
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
            self.transitionType = nil
        }
        
        animator.startAnimation()
    }
    
}
