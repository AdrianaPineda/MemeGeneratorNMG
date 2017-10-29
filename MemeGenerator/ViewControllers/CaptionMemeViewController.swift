//
//  CaptionMemeViewController.swift
//  MemeGenerator
//
//  Created by Natasha on 10/28/17.
//  Copyright © 2017 NatashaMartinez. All rights reserved.
//

import UIKit
import Alamofire
import TwitterKit
import FacebookShare

class CaptionMemeViewController: UIViewController  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topCaption: UITextField!
    @IBOutlet weak var bottomCaption: UITextField!
    
    @IBOutlet weak var button: UIButton!
    var memeDictionary = [String: Any]()
    var captionedMemeDictionary = [String: Any]()
    var isOnPreview : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMemeView()
    }
    
    //MARK: - Setup
    
    func setupMemeView() {
        topCaption.attributedPlaceholder = NSAttributedString(string: "your text here",
                                                              attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        bottomCaption.attributedPlaceholder = NSAttributedString(string: "your text here",
                                                                  attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        topCaption.isHidden = isOnPreview
        bottomCaption.isHidden = isOnPreview
        if (!captionedMemeDictionary.isEmpty && isOnPreview) {
            imageView.af_setImage(withURL: URL(string: captionedMemeDictionary["url"]! as! String)!)
        } else {
            imageView.af_setImage(withURL: URL(string: memeDictionary["url"]! as! String)!)
        }
    }
    
    //MARK: - Services
    
    func generateCaptionedMeme(fromSocial:Int) {
        let parameters: Parameters = ["template_id":memeDictionary["id"]!,
                                      "username":"imgflip_hubot",
                                      "password":"imgflip_hubot",
                                      "text0":topCaption.text!,
                                      "text1":bottomCaption.text!]
        
        print("Request parameters: \(parameters)") // Debug
        
        let router = Router.captionImage(_: parameters)
        
        APIManager.apiRequest(url: router, success: { (responseJSON) in
            
            self.captionedMemeDictionary = responseJSON["data"] as! [String: Any]
            
            if (!self.captionedMemeDictionary.isEmpty) {
                self.topCaption.isHidden = true
                self.bottomCaption.isHidden = true
                self.imageView.contentMode = .scaleToFill
                self.isOnPreview = true
                self.setupMemeView()
                
                switch fromSocial {
                case 0:
                    //preview img, do nothing
                    break
                case 1:
                    //Facebook
                    self.shareFb()
                    break
                case 2:
                    //Twitter
                    self.shareTw()
                    break
                case 3:
                    //Whatsapp
                    self.shareWha()
                    break
                case 4:
                    //savetogallery
                    self.saveToPhotos()
                    break
                default:
                    break
                }
            }
            
        }) { (errorMessage) in
            print(errorMessage)
        }
        
    }
    
    //MARK: - Sharing
    
    func saveToPhotos() {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func shareWha() {
        
        let originalString = captionedMemeDictionary["url"]! as! String
        let escapedString = originalString.addingPercentEncoding(withAllowedCharacters:CharacterSet.urlQueryAllowed)
        let url  = URL(string: "whatsapp://send?text=\(escapedString!)")
        
        if UIApplication.shared.canOpenURL(url! as URL) {
            UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
        }
    }
    
    func shareFb() {
        
        let myContent = LinkShareContent(url: URL(string: captionedMemeDictionary["url"]! as! String)!)
        let shareDialog = ShareDialog(content: myContent)
        shareDialog.mode = .native
        shareDialog.failsOnInvalidData = true
        shareDialog.completion = { result in
            print("share results are in!")
        }
        
        try! shareDialog.show()
    }
    
    func shareTw() {
        if (Twitter.sharedInstance().sessionStore.hasLoggedInUsers()) {
            // App must have at least one logged-in user to compose a Tweet
            let composer = TWTRComposerViewController.init(initialText: "Sharing my meme from MemeGeneratorNM!", image: imageView.image, videoURL: nil)
            present(composer, animated: true, completion: nil)
        } else {
            // Log in, and then check again
            Twitter.sharedInstance().logIn { session, error in
                if session != nil { // Log in succeeded
                    let composer = TWTRComposerViewController.init(initialText: "Sharing my meme from MemeGeneratorNM!", image: self.imageView.image, videoURL: nil)
                    self.present(composer, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "No Twitter Accounts Available", message: "You must log in before presenting a composer.", preferredStyle: .alert)
                    self.present(alert, animated: false, completion: nil)
                }
            }
        }
        
    }
    
    //MARK: - Selector
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Error al guardar :(", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Listo!", message: "Tu meme se ha guardado en el carrete", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    //MARK: IBActions
    
    @IBAction func previewAction(_ sender: Any) {
        if isOnPreview {
            button.setTitle("Preview", for: .normal)
            isOnPreview = false
            setupMemeView()
        } else {
            button.setTitle("Edit", for: .normal)
            generateCaptionedMeme(fromSocial: 0)
        }
    }
    
    @IBAction func shareWithFb(_ sender: Any) {
        generateCaptionedMeme(fromSocial: 1)
    }
    
    @IBAction func shareWithTw(_ sender: Any) {
        generateCaptionedMeme(fromSocial: 2)
    }
    
    @IBAction func shareWithWha(_ sender: Any) {
        generateCaptionedMeme(fromSocial: 3)
    }
    @IBAction func saveToGallery(_ sender: Any) {
        generateCaptionedMeme(fromSocial: 4)
    }
}
