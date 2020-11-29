//
//  AddNewSpotController.swift
//  MySpots
//
//  Created by cannabiolog420 on 09.10.2020.
//

import UIKit
import MapKit

class AddNewSpotController: UITableViewController {
    
    
    var currentSpot:Spot!
    var imageIsChanged = false
    
    
    @IBOutlet weak var spotImage: UIImageView!
    @IBOutlet weak var spotNameTF: UITextField!
    @IBOutlet weak var spotLocationTF: UITextField!
    @IBOutlet weak var spotTypeTF: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var ratingStackView: RatingControl!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.isEnabled = false
        spotNameTF.addTarget(self, action: #selector(saveButtonStatusUpdate), for: .editingChanged)
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: tableView.frame.size.height))
        
        setupEditingScreen()
        
        
        
        
    }
    
    //MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.row == 0{
            
            let cameraImg = UIImage(systemName: "camera")
            let photoImg = UIImage(systemName: "photo")
            let trashImg = UIImage(systemName: "trash")
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            let takePhoto = UIAlertAction(title: "Take photo", style: .default) { _ in
                            
                self.chooseImagePicker(source: .camera)
            }
            
            takePhoto.setValue(cameraImg, forKey: "image")
            takePhoto.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photos = UIAlertAction(title: "Choose photo", style: .default) { _ in
                
                self.chooseImagePicker(source: .photoLibrary)
            }
            
            photos.setValue(photoImg, forKey: "image")
            photos.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let removePhoto = UIAlertAction(title: "Remove photo", style: .destructive) { _ in
                
                self.spotImage.image = UIImage(named: "Photo")
                self.spotImage.contentMode = .center
                self.spotImage.clipsToBounds = true
                
                self.imageIsChanged = false
            }
        
            removePhoto.setValue(trashImg, forKey: "image")
            removePhoto.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            actionSheet.addAction(takePhoto)
            actionSheet.addAction(photos)
            actionSheet.addAction(removePhoto)
            actionSheet.addAction(cancelAction)
            actionSheet.view.tintColor = .black
            
            let image = UIImage(named: "imagePlaceholder")
            let imageData = image?.pngData()
            
            if imageIsChanged == false || currentSpot.imageData == imageData{
                
                actionSheet.actions[2].isEnabled = false
            }
            
            present(actionSheet, animated: true, completion: nil)
            
        }else{
            
            view.endEditing(true)
        }
        
        
        
    }
    
    //MARK:- Navigation
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let mapVC = segue.destination as? MapViewController,let identifier = segue.identifier else { return }
        
        mapVC.segueIdentifier = identifier
        mapVC.mapViewControllerDelegate = self
        
        if identifier == "showSpotOnMap"{
            
            mapVC.spot.name = spotNameTF.text!
            mapVC.spot.location = spotLocationTF.text!
            mapVC.spot.type = spotTypeTF.text!
            mapVC.spot.imageData = spotImage.image?.pngData()
        }
    }
    
    
    @objc func saveButtonStatusUpdate(){
        
        saveButton.isEnabled = !spotNameTF.text!.isEmpty
        
    }
    
    
    func saveNewSpot(){
        
        let image = imageIsChanged ? spotImage.image : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()
        
        let newSpot = Spot(name: spotNameTF.text!, location: spotLocationTF.text!, type: spotTypeTF.text!, imageData:imageData!,rating: Double(ratingStackView.rating))
        
        if currentSpot != nil {
            
            try! realm.write{
                
                currentSpot.name = newSpot.name
                currentSpot.location = newSpot.location
                currentSpot.type = newSpot.type
                currentSpot.imageData = newSpot.imageData
                currentSpot.rating = newSpot.rating
            }
        }else{
            StorageManager.saveObject(newSpot)
        }
    }
    
    
    private func setupEditingScreen(){
        
        if let spot = currentSpot{
            
            setupNavigationBar()
            imageIsChanged = true
            let image = UIImage(data: spot.imageData!)
            spotImage.image = image
            spotImage.contentMode = .scaleToFill
            
            spotNameTF.text = spot.name
            spotLocationTF.text = spot.location
            spotTypeTF.text = spot.type
            spotImage.image = UIImage(data: currentSpot.imageData!)
            ratingStackView.rating = Int(spot.rating)
            
        }
    }
    
    private func setupNavigationBar(){
        
        if let topItem = navigationController?.navigationBar.topItem{
            
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
            topItem.backBarButtonItem?.tintColor = .black
        }
        navigationItem.leftBarButtonItem = nil
        title = currentSpot.name
        
        saveButton.isEnabled = true
    }
    
    
    

    
    
    
}

//MARK: - Text Field Delegate

extension AddNewSpotController:UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
}

//MARK: - Work with image

extension AddNewSpotController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
    
    
    func chooseImagePicker(source:UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source){
        
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            
            present(imagePicker, animated: true, completion: nil)

        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        spotImage.image = info[.editedImage] as? UIImage
        spotImage.contentMode = .scaleAspectFill
        spotImage.clipsToBounds = true
    
        imageIsChanged = true
        
        dismiss(animated: true)
    }
    
    
}


extension AddNewSpotController:MapViewControllerDelegate{
    
    
    func getAddress(_ address: String?) {
        spotLocationTF.text = address
    }

}
