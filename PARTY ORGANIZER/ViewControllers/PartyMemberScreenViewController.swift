//
//  PartyMemberScreenViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 10/01/2021.
//

import UIKit

protocol SendSelectedPartyMember {
    func sendSelectedPartyMember(membersId: [Int])
}

class PartyMemberScreenViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var partyMemberSelect: [Int] = []
    var indexOfSelectedImage: Int!
    var newDelegate: SendSelectedPartyMember!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        customInitSetup()
        registerCell()
    }
    
    private func customInitSetup() {
        
        self.title = "Members"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
    }
    
    @objc func saveTapped() {

        self.newDelegate.sendSelectedPartyMember(membersId: self.partyMemberSelect)
    
        self.navigationController?.popViewController(animated: true)
    }

    private func registerCell() {
        tableView.register(UINib(nibName: MembersTableViewCell.name, bundle: nil), forCellReuseIdentifier: MembersTableViewCell.name)
    }
    
    @objc func memberImageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        
        let tapImage = tapGestureRecognizer.view as! UIImageView
        
        indexOfSelectedImage = tapImage.tag
        
        self.performSegue(withIdentifier: "showProfileMember", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProfileMember" {
            let destinacionVC = segue.destination as! ProfileScreenViewController
            destinacionVC.profile = arrayOfMembers[self.indexOfSelectedImage]
            let backItem = UIBarButtonItem()
                backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }

}

extension PartyMemberScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MembersTableViewCell.name, for: indexPath) as? MembersTableViewCell else {
            fatalError()
        }
        
        for id in self.partyMemberSelect {
            if id == arrayOfMembers[indexPath.row].id {
                cell.accessoryType = .checkmark
            }
        }
        
        cell.selectionStyle = .none
        cell.memberNameLabel.text = arrayOfMembers[indexPath.row].username
        
        cell.memberImageView.tag = indexPath.row
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(memberImageTapped(tapGestureRecognizer:)))
        cell.memberImageView.isUserInteractionEnabled = true
        cell.memberImageView.addGestureRecognizer(tapGestureRecognizer)
        
        let url = URL(string: arrayOfMembers[indexPath.row].photo ?? "")
        let dataImage = try? Data(contentsOf: url!)
        cell.memberImageView.image = UIImage(data: dataImage ?? Data())
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
            if arrayOfMembers[indexPath.row].id != nil {
                self.partyMemberSelect = self.partyMemberSelect.filter{$0 != arrayOfMembers[indexPath.row].id!}
            }
        } else {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            if arrayOfMembers[indexPath.row].id != nil {
                self.partyMemberSelect.append(arrayOfMembers[indexPath.row].id!)
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        if arrayOfMembers[indexPath.row].id != nil {
            self.partyMemberSelect = self.partyMemberSelect.filter{$0 != arrayOfMembers[indexPath.row].id!}
        }
    }
    
}
