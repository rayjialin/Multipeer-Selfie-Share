//
//  PhotoDetailViewController.swift
//  Multipeer Selfie Share
//
//  Created by ruijia lin on 7/15/18.
//  Copyright © 2018 ruijia lin. All rights reserved.
//

import UIKit
import Chameleon
import GPUImage

class PhotoDetailViewController: UIViewController {
    
    let filterCell = "filterCell"
    let photoDetailView = PhotoDetailView()
    var imageData: Data? {
        didSet {
            guard let imageData = imageData else {return}
            photoDetailView.detailImage = UIImage(data: imageData)
        }
    }
    
    let filterOptions = ["Cartoon",
                         "Grayscale",
                         "Color Inversion",
                         "Sharpen",
                         "Sepia",
                         "Solarize"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoDetailView.filterCollectionView.dataSource = self
        photoDetailView.filterCollectionView.delegate = self
        
        photoDetailView.filterCollectionView.register(FilterCell.self, forCellWithReuseIdentifier: "filterCell")
        
        photoDetailView.frame = view.frame
        view.addSubview(photoDetailView)
        
        photoDetailView.backButton.addTarget(self, action: #selector(handleBackButtonPressed), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTapped))
        tapGesture.numberOfTapsRequired = 1
        let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressed))
        tapGesture.delegate = self
        longPressedGesture.minimumPressDuration = 1.0
        photoDetailView.detailImageView.addGestureRecognizer(tapGesture)
        photoDetailView.detailImageView.addGestureRecognizer(longPressedGesture)
        photoDetailView.filterButton.addTarget(self, action: #selector(handleFilterPressed), for: .touchUpInside)
    }
    
    @objc func handleBackButtonPressed() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleImageTapped(sender: UITapGestureRecognizer) {
        
        // remove all views besides the image view
        if photoDetailView.headerContainerView.isHidden == true && photoDetailView.footerContainerView.isHidden == true {
            [photoDetailView.headerContainerView, photoDetailView.footerContainerView].forEach { $0.isHidden = false }
        }else {
            [photoDetailView.headerContainerView, photoDetailView.footerContainerView, photoDetailView.footerDetailContainer].forEach { $0.isHidden = true }
        }
    }
    
    @objc func handleLongPressed(longPressed: UILongPressGestureRecognizer){
        guard longPressed.state == UIGestureRecognizerState.began else {return}
        //Chaining alerts with messages on button click
        SweetAlert().showAlert("Save Photo", subTitle: "Do you want to save this photo to Photo Album?", style: AlertStyle.success, buttonTitle:"Yes", buttonColor: UIColor.flatGreen(), otherButtonTitle:  "No", otherButtonColor: UIColor.flatGreen()) { (isOtherButton) -> Void in
            if isOtherButton == true {
                
                guard let image = self.photoDetailView.detailImageView.image else {return}
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
                
                let _ = self.photoDetailView.sweetAlert.showAlert("Saved", subTitle: "Photo has been saved", style: AlertStyle.success)
            }
            else {
                let _ = self.photoDetailView.sweetAlert.showAlert("Cancelled", subTitle: "Action Cancelled", style: AlertStyle.error)
            }
        }
    }
    
    @objc func handleFilterPressed(){
        print("filter tapped")
        
        // toggle filter selection bar on/off
        if photoDetailView.footerDetailContainer.isHidden == true{
            photoDetailView.footerDetailContainer.isHidden = false
            photoDetailView.filterCollectionView.isHidden = false
            photoDetailView.filterCollectionView.reloadData()
        }else {
            photoDetailView.footerDetailContainer.isHidden = true
            photoDetailView.filterCollectionView.isHidden = true
        }
        
        //        guard let filteringImage = photoDetailView.detailImageView.image else {return}
        //        let toonFilter = SmoothToonFilter()
        //        photoDetailView.detailImage = filteringImage.filterWithOperation(toonFilter)
    }
    
    func applyFilter(filter: String) {
        var filterEffect: BasicOperation!
        switch filter {
        case "Cartoon":
            filterEffect = ToonFilter()
            break
        case "Grayscale":
            filterEffect = Luminance()
            break
        case "Color Inversion":
            filterEffect = ColorInversion()
            break
        case "Sharpen":
            filterEffect = Sharpen()
            break
        case "Sepia":
            filterEffect = SepiaToneFilter()
            break
        case "Solarize":
            filterEffect = Solarize()
            break
        default:
            // do nothing
            print("Default")
        }
        
        guard let imageData = imageData else {return}
        guard let filteredImage = UIImage(data: imageData) else {return}
        let pictureInput = PictureInput(image: filteredImage)
        let pictureOutput = PictureOutput()
        pictureOutput.imageAvailableCallback = {image in
            self.photoDetailView.detailImage = image
        }
        pictureInput --> filterEffect --> pictureOutput
        pictureInput.processImage(synchronously:true)
    }
    
    func removeFilter(){
        guard let imageData = imageData else {return}
        self.photoDetailView.detailImage = UIImage(data: imageData)
    }
    
}
