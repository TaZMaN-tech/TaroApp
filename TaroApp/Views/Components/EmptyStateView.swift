//
//  EmptyStateView.swift
//  TaroApp
//
//  Created by Тадевос Курдоглян on 08.12.2025.
//

import UIKit

final class EmptyStateView: UIView {
    
    private let iconLabel = UILabel()
    private let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = Design.Spacing.m
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        
        iconLabel.font = UIFont.systemFont(ofSize: 48)
        iconLabel.textAlignment = .center
        stack.addArrangedSubview(iconLabel)
        
        titleLabel.font = Design.Fonts.title
        titleLabel.textColor = Design.Colors.textSecondary
        titleLabel.textAlignment = .center
        stack.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(icon: String, title: String) {
        iconLabel.text = icon
        titleLabel.text = title
    }
}
