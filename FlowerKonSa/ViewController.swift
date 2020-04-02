//
//  ViewController.swift
//  FlowerKonSa
//
//  Created by Fahad Tariq on 06/10/2018.
//  Copyright © 2018 Fahad Tariq. All rights reserved.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON
import SDWebImage

class ViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var Label: UILabel!
    
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    


    
    var camera = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.delegate = self
        camera.allowsEditing = false
        camera.sourceType = .photoLibrary
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            //imageView.image = userPickedImage
            
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Unable to Convert the UIimage into CIImage")
            }
            detectImage(imaga: ciimage)
            
            camera.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func detectImage(imaga : CIImage){
        
        guard let model = try? VNCoreMLModel(for: flowerClassifier().model) else {
            fatalError("Error while modleing")
        }
        
        let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
            guard let result = request.results?.first as? VNClassificationObservation else {
                fatalError("Error While requesting")
            }
              self.navigationItem.title = result.identifier.capitalized
            
            self.gettingData(flowerName: result.identifier)
        })
        
        let handler = VNImageRequestHandler(ciImage: imaga)
        do{
            try handler.perform([request])
            
        }catch{
            fatalError("Error While Handluing")
            
        }
        
        
        
    }
    

    @IBAction func cameraPressed(_ sender: UIBarButtonItem) {
        present(camera,animated: true,completion: nil)
    }
    
    
    func gettingData(flowerName : String){
        let parameters : [String:String] = [
            "format" : "json",
            "action" : "query",
            "prop" : "extracts|pageimages",
            "exintro" : "",
            "explaintext" : "",
            "titles" : flowerName,
            "indexpageids" : "",
            "redirects" : "1",
            "pithumbsize" : "500"
            ]


        Alamofire.request(wikipediaURl, method: .get, parameters: parameters).responseJSON { (response) in
            
            if response.result.isSuccess {
                print("Got the Results")
                let flowerJSON : JSON = JSON(response.result.value!)
                
                let pageID = flowerJSON["query"]["pageids"][0].stringValue
                
                let flowerDiscription = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
                
                let flowerImageURL = flowerJSON["query"]["pages"][pageID]["thumbnail"]["source"].stringValue
                
                self.Label.text = flowerDiscription
                
                self.imageView.sd_setImage(with: URL(string: flowerImageURL))
                
            }
        }
        
        
    }
    
    
}

