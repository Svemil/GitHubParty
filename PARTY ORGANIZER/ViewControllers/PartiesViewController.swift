//
//  PartiesViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 08/01/2021.
//

import UIKit
import CoreData

class PartiesViewController: UIViewController {

    
    @IBOutlet weak var createPartyButton: UIButton!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var results: [Party] = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indexOfSelectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customInitSetup()
        fetchRequestCoreData()

        tableView.delegate = self
        tableView.dataSource = self
        
        registerCell()
        getAllAvailablePartyMembers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(fetchRequestCoreData), name: NSNotification.Name("reloadTableView"), object: nil)
    }
    

    private func registerCell() {
        tableView.register(UINib(nibName: PartiesTableViewCell.name, bundle: nil), forCellReuseIdentifier: PartiesTableViewCell.name)
    }
    
    private func customInitSetup() {
        
        self.title = "Parties"
        self.infoLabel.text = "You have no party.\nCreate some!"
        self.createPartyButton.layer.cornerRadius = 10
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addTapped))
    }
    
    @objc private func fetchRequestCoreData() {
        
        let request: NSFetchRequest<Party> = Party.fetchRequest()
        
        do {
            
            results = try appDelegate.persistentContainer.viewContext.fetch(request) as [Party]
            
        } catch {
            print("Error: \(error)")
        }
        
        checkResultsArray()
        
        tableView.reloadData()
    }
    
    @objc func addTapped() {
        print("Addddddd")
        self.performSegue(withIdentifier: "showPartyScreen", sender: self)
    }
    
    @IBAction func createPartyButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showPartyScreen", sender: self)
    }
    
    
    private func getAllAvailablePartyMembers() {
        
        let url = String(format: "https://api-coin.quantox.tech/profiles.json")
        guard let serviceUrl = URL(string: url) else { return }
        
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "GET"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            
            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    
                    if let data = data {
                        
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary

                            guard let dictionary = json?["profiles"] as? NSArray else { return }
                            
                            for member in dictionary {
                                
                                if let info = member as? NSDictionary {
                                    
                                    arrayOfMembers.append(Profile(id: info["id"] as? Int, username: info["username"] as? String, cell: info["cell"] as? String, photo: info["photo"] as? String, email: info["email"] as? String, gender: info["gender"] as? String, aboutMe: info["aboutMe"] as? String))
                                }
                            }
                            
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
            
        }.resume()
    }
    
    func checkResultsArray() {
        DispatchQueue.main.async {
            if self.results.isEmpty {
                self.infoLabel.isHidden = false
                self.createPartyButton.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.infoLabel.isHidden = true
                self.createPartyButton.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }
    
    func deletePartyFromCoreData(partyId: String) {
        
        var party: Party?
        
        let request: NSFetchRequest<Party> = Party.fetchRequest()
        let predicate = NSPredicate(format: "partyId == %@", partyId)
        
        request.predicate = predicate
        
        do {
            party = try appDelegate.persistentContainer.viewContext.fetch(request).first
            
        } catch let error{
            print(error.localizedDescription)
        }

        if party != nil {
            appDelegate.persistentContainer.viewContext.delete(party!)
        }
        appDelegate.saveContext()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showPartyScreen" {
            let backItem = UIBarButtonItem()
                backItem.title = "Home"
            navigationItem.backBarButtonItem = backItem
            
            let destinacionVC = segue.destination as! PartyScreenViewController
            destinacionVC.commingFromCell = false
        }
        
        if segue.identifier == "showPartyScreenFromCell" {
            
            let backItem = UIBarButtonItem()
                backItem.title = "Home"
            navigationItem.backBarButtonItem = backItem
        
            let destinacionVC = segue.destination as! PartyScreenViewController
            DispatchQueue.main.async {
                
                var partyMembersIds: [Int] = []
                
                do {
                    partyMembersIds = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData((self.results[self.indexOfSelectedRow].partyMembersIds ?? Data()) as Data) as? [Int] ?? []
                } catch {
                    print("Error")
                }
                
                destinacionVC.commingFromCell = true
                destinacionVC.partyId = self.results[self.indexOfSelectedRow].partyId ?? ""
                destinacionVC.partyNameTextField.text = self.results[self.indexOfSelectedRow].partyName ?? ""
                destinacionVC.partyStartDateTextField.text = self.results[self.indexOfSelectedRow].partyDateTime ?? ""
                destinacionVC.partyDescriptionTextView.text = self.results[self.indexOfSelectedRow].partyDescription ?? ""
                destinacionVC.sendSelectedPartyMember(membersId: partyMembersIds)
            }
        }
    }

}

extension PartiesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PartiesTableViewCell.name, for: indexPath) as? PartiesTableViewCell else {
            fatalError()
        }
        
        cell.namePartyLabel.text = results[indexPath.row].partyName
        cell.startDatePartyLabel.text = results[indexPath.row].partyDateTime
        cell.descriptionOfPartyLabel.text = results[indexPath.row].partyDescription
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexOfSelectedRow = indexPath.row
        self.performSegue(withIdentifier: "showPartyScreenFromCell", sender: self)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in

            self.deletePartyFromCoreData(partyId: self.results[indexPath.row].partyId ?? "")
                self.results.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.checkResultsArray()
            
            completion(false)
        }
        delete.backgroundColor = UIColor.red
        let confige = UISwipeActionsConfiguration(actions: [delete])
        return confige
    }
    
}
