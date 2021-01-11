//
//  AddMemberToPartyScreenViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 10/01/2021.
//

import UIKit
import CoreData

class AddMemberToPartyScreenViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var results: [Party] = []
    var memberId: Int!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var indexOfSelectedRow: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        registerCell()
        fetchRequestCoreData()
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: PartyMemberTableViewCell.name, bundle: nil), forCellReuseIdentifier: PartyMemberTableViewCell.name)
    }
    
    private func fetchRequestCoreData() {
        
        let request: NSFetchRequest<Party> = Party.fetchRequest()
        
        do {
            
            results = try appDelegate.persistentContainer.viewContext.fetch(request) as [Party]
            
        } catch {
            print("Error: \(error)")
        }
        
        checkResultsArray()
        
        tableView.reloadData()
    }
    
    func addRemoveMemberToParty(partyId: String, indexOfSelectedRow: Int, addRemove: Bool) {
        
        var partyMembersIds: [Int] = []
        
        do {
            partyMembersIds = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData((self.results[indexOfSelectedRow].partyMembersIds ?? Data()) as Data) as? [Int] ?? []
        } catch {
            print("Error")
        }
        
        if addRemove {
            partyMembersIds.append(memberId)
        } else {
            partyMembersIds = partyMembersIds.filter{$0 != memberId}
        }
        
        var party: Party?
        var membersIdsData = Data()

        do {
            membersIdsData = try NSKeyedArchiver.archivedData(withRootObject: partyMembersIds, requiringSecureCoding: false)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let request: NSFetchRequest<Party> = Party.fetchRequest()
        let predicate = NSPredicate(format: "partyId == %@", partyId)
        
        request.predicate = predicate
        
        do {
            party = try appDelegate.persistentContainer.viewContext.fetch(request).first
            
        } catch let error{
            print(error.localizedDescription)
        }

        if party != nil {
            party?.partyMembersIds = membersIdsData
            appDelegate.saveContext()
        }
        
    }
    
    func checkResultsArray() {
        DispatchQueue.main.async {
            if self.results.isEmpty {
                self.infoLabel.isHidden = false
                self.tableView.isHidden = true
            } else {
                self.infoLabel.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }

}

extension AddMemberToPartyScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PartyMemberTableViewCell.name, for: indexPath) as? PartyMemberTableViewCell else {
            fatalError()
        }
        
        var partyMembersIds: [Int] = []
        
        do {
            partyMembersIds = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData((self.results[indexPath.row].partyMembersIds ?? Data()) as Data) as? [Int] ?? []
        } catch {
            print("Error")
        }
        
        if partyMembersIds.contains(memberId) {
            cell.accessoryType = .checkmark
        }
        
        cell.partyMemberLabel.text = results[indexPath.row].partyName
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
            if results[indexPath.row].partyId != nil {
                self.addRemoveMemberToParty(partyId: self.results[indexPath.row].partyId!, indexOfSelectedRow: indexPath.row, addRemove: false)
            }
        } else {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            if results[indexPath.row].partyId != nil {
                self.addRemoveMemberToParty(partyId: self.results[indexPath.row].partyId!, indexOfSelectedRow: indexPath.row, addRemove: true)
            }
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
        if results[indexPath.row].partyId != nil {
            self.addRemoveMemberToParty(partyId: self.results[indexPath.row].partyId!, indexOfSelectedRow: indexPath.row, addRemove: false)
        }
    }
    
}
