//
//  RatingView.swift
//  MySpots
//
//  Created by cannabiolog420 on 12.10.2020.
//

import UIKit

class RatingView: UIStackView {
    
    
    var ratingStars = [UIImageView]()
    
    var rating = 0{
        didSet{
            updateRating()
        }
    }
    
    var starCount:Int = 5
    
    var starSize:CGSize = CGSize(width: 16, height: 16)
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStars()
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStars()
    }
    
    
    func setupStars(){
        
        
        for _ in 1...starCount{
            
            
            let starImage = UIImageView()
            
            starImage.translatesAutoresizingMaskIntoConstraints = false
            starImage.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            starImage.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            addArrangedSubview(starImage)
            
            ratingStars.append(starImage)
        }
        
        updateRating()
    }
    
    
    func updateRating(){
        
        for (index,star) in ratingStars.enumerated(){
            
            star.image = rating > index ? UIImage(named: "filledStar") : UIImage(named: "emptyStar")
            
        }
    }
    
}
