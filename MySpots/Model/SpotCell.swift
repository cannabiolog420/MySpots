//
//  SpotCell.swift
//  MySpots
//
//  Created by cannabiolog420 on 09.10.2020.
//

import UIKit

class SpotCell: UITableViewCell {


    @IBOutlet weak var spotName: UILabel!
    @IBOutlet weak var spotLocation: UILabel!
    @IBOutlet weak var spotType: UILabel!
    @IBOutlet weak var spotImage: UIImageView!{
        didSet{
            
            spotImage.layer.cornerRadius = spotImage.frame.size.height / 2
            spotImage.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var ratingStars: RatingView!
    
    func setSpot(spot:Spot){
        
        spotName.text = spot.name
        spotLocation.text = spot.location
        spotType.text = spot.type
        spotImage.image = UIImage(data: spot.imageData!)
        ratingStars.rating = Int(spot.rating)
    
    }
    
    
}
