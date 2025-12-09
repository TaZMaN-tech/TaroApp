//
//  GradientView.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class GradientView: UIView {
    
    private let gradientLayer = CAGradientLayer()
    
    var colors: [UIColor] = [Design.Colors.gradientStart, Design.Colors.gradientEnd] {
        didSet { updateGradient() }
    }
    
    var startPoint: CGPoint = CGPoint(x: 0, y: 0) {
        didSet { gradientLayer.startPoint = startPoint }
    }
    
    var endPoint: CGPoint = CGPoint(x: 1, y: 1) {
        didSet { gradientLayer.endPoint = endPoint }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        layer.insertSublayer(gradientLayer, at: 0)
        updateGradient()
    }
    
    private func updateGradient() {
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradient()
        }
    }
}
