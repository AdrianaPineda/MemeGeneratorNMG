//
//  LaunchViewController.swift
//  MemeGenerator
//
//  Created by Natasha on 10/29/17.
//  Copyright © 2017 NatashaMartinez. All rights reserved.
//

import UIKit
class LaunchViewController : UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    var hasLoadedBefore : Bool = false
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
         _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(launchHome), userInfo: nil, repeats: false)
        
        UIView.animate(withDuration: 2.0, animations: {
           
            if (self.hasLoadedBefore) {
                self.imageView.image = UIImage(named: "trollFace")
            }
            self.hasLoadedBefore = true
            self.imageView.alpha = 1.0
            self.label.alpha = 1.0
        })
    }
    
    @objc func launchHome() {
        self.performSegue(withIdentifier: "launchHome", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "launchHome" {
            let destination : HomeViewController = segue.destination as! HomeViewController
            destination.navigationController?.navigationBar.backItem?.setHidesBackButton(true, animated: false)
        }
    }
}
