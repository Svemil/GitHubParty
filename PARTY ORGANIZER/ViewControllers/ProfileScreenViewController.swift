//
//  ProfileScreenViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 09/01/2021.
//

import UIKit

class ProfileScreenViewController: UIViewController {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileFullName: UILabel!
    @IBOutlet weak var profileGender: UILabel!
    @IBOutlet weak var profileEmail: UILabel!
    @IBOutlet weak var profileAboutMe: UITextView!
    @IBOutlet weak var addToPartyUIButton: UIButton!
    
    var profile: Profile?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        customInitSetup()
        setMemberProfile()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        profileImage.layer.cornerRadius = profileImage.frame.size.height / 2
        profileImage.layer.borderWidth = 1
    }
    
    private func setMemberProfile() {
        
        let url = URL(string: profile?.photo ?? "")
        let dataImage = try? Data(contentsOf: url!)
        profileImage.image = UIImage(data: dataImage ?? Data())
        profileFullName.text = "Full name: " + "\(profile?.username ?? "")"
        profileGender.text = "Gender: " + "\(profile?.gender ?? "")"
        profileEmail.text = "email: " + "\(profile?.email ?? "")"
        profileAboutMe.text = "\(profile?.aboutMe ?? "")"
    }
    
    func customInitSetup() {
        
        self.title = "Profile"
        addToPartyUIButton.layer.cornerRadius = 10
    }
    
    @IBAction func addToPartyButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "showPartyList", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPartyList" {
            let backItem = UIBarButtonItem()
                backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            
            let destinacionVC = segue.destination as! AddMemberToPartyScreenViewController
            destinacionVC.title = profile?.username ?? ""
            destinacionVC.memberId = profile?.id ?? 0
            
        }
    }
    

}
