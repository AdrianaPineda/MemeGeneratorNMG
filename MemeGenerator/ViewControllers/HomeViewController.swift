//
//  HomeViewController.swift
//  MemeGenerator
//
//  Created by Natasha on 10/28/17.
//  Copyright © 2017 NatashaMartinez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class HomeViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    var memesArray = [[String: Any]]()
    var filteredMemesArray = [[String: Any]]()
    var selectedMeme = [String:Any]()
    var currentArray = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getMemes()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getMemes() {
        
        let router = Router.getMemes()
        
        APIManager.apiRequest(url: router, success: { (responseJSON) in
            
            self.memesArray = (responseJSON["data"] as! [String: Any])["memes"] as! [[String:Any]]
            
            self.collectionView.reloadData()
        }) { (errorMessage) in
            print(errorMessage)
        }
    }
    @IBAction func addImage(_ sender: Any) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "captionMeme" {
            let destination: CaptionMemeViewController = segue.destination as! CaptionMemeViewController;            destination.memeDictionary = selectedMeme
        }
    }
}

extension HomeViewController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMemesArray = memesArray.filter { memes in
            return ((memes["name"]! as! String).lowercased().contains(searchText.lowercased()))
        }
        collectionView.reloadData()
    }
}

extension HomeViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let cellImage = cell.viewWithTag(1) as! UIImageView
        let cellLbl = cell.viewWithTag(2) as! UILabel
        
        cellImage.af_setImage(withURL: URL(string: currentArray[indexPath.row]["url"]! as! String)!)
        cellLbl.text = currentArray[indexPath.row]["name"]! as? String
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchBar.isFirstResponder && searchBar.text != ""{
            currentArray = filteredMemesArray
            return filteredMemesArray.count
        }else{
            currentArray = memesArray
            return memesArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedMeme = currentArray[indexPath.row]
        performSegue(withIdentifier: "captionMeme", sender: self)
    }
}

