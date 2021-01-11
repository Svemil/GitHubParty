//
//  PartyScreenViewController.swift
//  PARTY ORGANIZER
//
//  Created by Svemil Djusic on 09/01/2021.
//

import UIKit
import CoreData

class PartyScreenViewController: UIViewController, UITextFieldDelegate, SendSelectedPartyMember {
    
    @IBOutlet weak var partyNameTextField: UITextField!
    @IBOutlet weak var partyStartDateTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var membersButton: UIButton!
    @IBOutlet weak var partyDescriptionTextView: UITextView!
    
    var partyMembers: [Profile] = []
    var selectedMembersId: [Int] = []
    let datePicker = UIDatePicker()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var commingFromCell = false
    var partyId = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        partyNameTextField.delegate = self
        partyStartDateTextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        customInitSetup()
        registerCell()
        createDatePicker()
        
    }
    
    private func customInitSetup() {
        
        self.title = "Party"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
        
        let disclosure = UITableViewCell()
        disclosure.frame = membersButton.bounds
        disclosure.accessoryType = .disclosureIndicator
        disclosure.isUserInteractionEnabled = false
        refreshMembersButton()

        membersButton.addSubview(disclosure)
        
        if partyMembers.isEmpty {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    private func registerCell() {
        tableView.register(UINib(nibName: PartyMemberTableViewCell.name, bundle: nil), forCellReuseIdentifier: PartyMemberTableViewCell.name)
    }
    
    func sendSelectedPartyMember(membersId: [Int]) {
        if !membersId.isEmpty {
            selectedMembersId = membersId
            partyMembers = arrayOfMembers.filter { fromMemoryUser in
                return membersId.contains(where: { serviceUser in
                    return serviceUser == fromMemoryUser.id
                })
            }
            refreshMembersButton()
            tableView.isHidden = false
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func createDatePicker() {

        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolBar.setItems([doneButton], animated: true)
        partyStartDateTextField.inputAccessoryView = toolBar
        datePicker.datePickerMode = .dateAndTime
        datePicker.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 250.0)
        datePicker.preferredDatePickerStyle = .wheels
        partyStartDateTextField.inputView = datePicker
    }
    
    @objc func donePressed() {

        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
        
        partyStartDateTextField.text = dateFormat.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func saveTapped() {

        if commingFromCell {
            editParty(partyId: self.partyId)
        } else {
            saveParty()
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadTableView"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func membersButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showPartyMembers", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPartyMembers" {
            let destinacionVC = segue.destination as! PartyMemberScreenViewController
            let backItem = UIBarButtonItem()
                backItem.title = ""
            navigationItem.backBarButtonItem = backItem
            destinacionVC.partyMemberSelect = selectedMembersId
            destinacionVC.newDelegate = self
            
        }
    }
    
    func refreshMembersButton() {
        membersButton.setTitle("Members (\(partyMembers.count))", for: .normal)
    }
    
    // MARK: - Core Data
    
    func saveParty() {
        
        var membersIdsData = Data()

        do {
            membersIdsData = try NSKeyedArchiver.archivedData(withRootObject: selectedMembersId, requiringSecureCoding: false)
        } catch let error {
            print(error.localizedDescription)
        }
        
        let party: Party = NSEntityDescription.insertNewObject(forEntityName: "Party", into: appDelegate.persistentContainer.viewContext) as! Party
        
        party.partyId = UUID().uuidString
        party.partyName = partyNameTextField.text ?? ""
        party.partyDateTime = partyStartDateTextField.text ?? ""
        party.partyDescription = partyDescriptionTextView.text ?? ""
        party.partyMembersIds = membersIdsData
        
        appDelegate.saveContext()
    }
    
    func editParty(partyId: String) {
        
        var party: Party?
        var membersIdsData = Data()

        do {
            membersIdsData = try NSKeyedArchiver.archivedData(withRootObject: selectedMembersId, requiringSecureCoding: false)
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
            party?.partyId = partyId
            party?.partyName = partyNameTextField.text ?? ""
            party?.partyDateTime = partyStartDateTextField.text ?? ""
            party?.partyDescription = partyDescriptionTextView.text ?? ""
            party?.partyMembersIds = membersIdsData
            appDelegate.saveContext()
        }
        
    }
    
}

extension PartyScreenViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyMembers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PartyMemberTableViewCell.name, for: indexPath) as? PartyMemberTableViewCell else {
            fatalError()
        }
        cell.contentView.backgroundColor = UIColor.systemGray5
        cell.partyMemberLabel.text = partyMembers[indexPath.row].username
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in

            self.selectedMembersId = self.selectedMembersId.filter{$0 != self.partyMembers[indexPath.row].id}
            self.partyMembers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            self.refreshMembersButton()
            completion(false)
        }
        delete.backgroundColor = UIColor.red
        let confige = UISwipeActionsConfiguration(actions: [delete])
        return confige
    }
    
}
