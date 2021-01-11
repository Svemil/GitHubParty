//
//  MembersViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 08/01/2021.
//

import UIKit

class MembersViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var indexOfSelectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Members"

        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: MembersTableViewCell.name, bundle: nil), forCellReuseIdentifier: MembersTableViewCell.name)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMemberProfile" {
            let destinacionVC = segue.destination as! ProfileScreenViewController
            destinacionVC.profile = arrayOfMembers[self.indexOfSelectedRow]
            let backItem = UIBarButtonItem()
                backItem.title = ""
            navigationItem.backBarButtonItem = backItem
        }
    }

}

extension MembersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MembersTableViewCell.name, for: indexPath) as? MembersTableViewCell else {
            fatalError()
        }
        
        cell.memberNameLabel.text = arrayOfMembers[indexPath.row].username
        
        let url = URL(string: arrayOfMembers[indexPath.row].photo ?? "")
        let dataImage = try? Data(contentsOf: url!)
        cell.memberImageView.image = UIImage(data: dataImage ?? Data())
        
        cell.selectionStyle = .none
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.indexOfSelectedRow = indexPath.row
        self.performSegue(withIdentifier: "showMemberProfile", sender: self)
    }
    
    
}
