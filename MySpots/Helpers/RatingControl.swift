//
//  RatingControl.swift
//  MySpots
//
//  Created by cannabiolog420 on 11.10.2020.
//

import UIKit

class RatingControl: UIStackView {
    
    var ratingButtons = [UIButton]()
    
    var rating = 0{
        
        didSet{
            updateRating()
        }
    }
    
    var starSize:CGSize = CGSize(width: 44.0, height: 44.0)
    var starCount:Int = 5
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupButtons()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    @objc func ratingButtonTapped(button:UIButton){
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        let selectedRating = index + 1
        
        if selectedRating == rating{
            rating = 0
        }else {
            rating = selectedRating
        }
        
        
    }
    
    
    func setupButtons(){
        
        for _ in 1...starCount{
            
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            let bundle = Bundle(for: type(of: self))
            let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
            let filledStar = UIImage(named: "filledStar", in: bundle, compatibleWith: self.traitCollection)
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            
            
            addArrangedSubview(button)
            
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            ratingButtons.append(button)
            
            
        }
        updateRating()
        
    }
    
    
    func updateRating(){
        
        
        for (index,button) in ratingButtons.enumerated(){
            
            
            button.isSelected = index < rating
            
        }
        
        
    }
    
    
}
