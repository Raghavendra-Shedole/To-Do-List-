//
//  ToDoListViewController.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 20/02/18.
//  Copyright © 2018 Raghavendra Shedole. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var todoTableView: UITableView!
    
    var headerCell:HeaderCell!
    var notes:[NoteClass] = []
    var selectedIndex = -1
    var ascending =  true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        todoTableView.rowHeight = UITableViewAutomaticDimension
        todoTableView.estimatedRowHeight = 80
        fetchData()
    }
    
   
    /// Right navigation button method
    ///
    /// - Parameter sender: right navigation bar button item
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: String(describing:NoteDetailsViewController.self), sender: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /// Unwind segue method
    ///
    /// - Parameter segue: segue from NoteDetailsViewController
    @IBAction func unwindSegue(segue:UIStoryboardSegue) {
        
        let noteDetailsVC = segue.source as! NoteDetailsViewController
        
        
        if selectedIndex >= 0 {
            deleteData(atIndex: selectedIndex)
            deleteRow(atIndex: selectedIndex)
            selectedIndex = -1
        }
        
        let  note = NoteClass(context:PesistentStore.context)
        note.note_title = noteDetailsVC.noteTitle
        note.date = noteDetailsVC.date as NSDate
        note.priority = noteDetailsVC.priority.rawValue
        
        PesistentStore.saveContext()
        if self.notes.count == 0 {
            self.notes.append(note)
        }else {
            self.notes.insert(note, at: 0)
        }
        
        //waiting for 1.0 second to insert the row
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when){
           self.insertRow()
        }
    }
    
    /// Prepare for segue Method
    ///
    /// - Parameters:
    ///   - segue: present NoteDetailsViewController segue
    ///   - sender: boolean value if true means editing the existing entry else adding new one
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
         reloadData()
        if let sender = sender as? Bool {
            if sender == true {
                let notesdetailsVC = segue.destination as! NoteDetailsViewController
                notesdetailsVC.noteTitle = notes[selectedIndex].note_title!
                notesdetailsVC.date = notes[selectedIndex].date! as Date
                notesdetailsVC.priority = notes[selectedIndex].priority == NotePriority.High.rawValue ? .High : .Low
            }
        }
    }
}




// MARK: - UITableViewDataSource and Delegate
extension ToDoListViewController:UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:NoteCell.self), for: indexPath) as! NoteCell
        cell.noteTitle.text = notes[indexPath.row].note_title
        cell.datelable.text = notes[indexPath.row].date?.showDate()
        cell.priority.text = notes[indexPath.row].priority == NotePriority.High.rawValue ? "High" : "Low" as String
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerCell == nil {
            headerCell = tableView.dequeueReusableCell(withIdentifier: String(describing:HeaderCell.self)) as! HeaderCell
            headerCell.priorityButton.addTarget(self, action: #selector(setPriority(sender:)), for: .touchUpInside)
            headerCell.noteTitleButton.addTarget(self, action: #selector(setPriority(sender:)), for: .touchUpInside)
            headerCell.dueDateButton.addTarget(self, action: #selector(setPriority(sender:)), for: .touchUpInside)

        }
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        self.view.endEditing(true)
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            
            //Show all the data before moving to next view controller
            
            //TODO: edit the row at indexPath here
            self.selectedIndex = indexPath.row
            self.performSegue(withIdentifier: String(describing:NoteDetailsViewController.self), sender: true)
            
        }
        editAction.backgroundColor = UIColor.colorWithHex(color: "78D3FA")
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
            self.deleteData(atIndex: indexPath.row)
            self.deleteRow(atIndex: indexPath.row)
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }
    
    /// Method to delete a row of a table
    ///
    /// - Parameter index: row index to be deleted
    func deleteRow(atIndex index:Int) {
        todoTableView.beginUpdates()
        todoTableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        todoTableView.endUpdates()
    }
    
    /// inserting cell at a index = 0
    func insertRow() {
        self.todoTableView.beginUpdates()
        self.todoTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
        self.todoTableView.endUpdates()
    }
    
    func reloadData() {
        self.fetchData()
        self.searchBar.text = ""
        self.todoTableView.reloadData()
    }
}


// MARK: - Search bar delegate
extension ToDoListViewController:UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text?.isEmpty)! {
            self.fetchData()
        }else {
            searchNote(noteTitle: searchBar.text!)
        }
        self.todoTableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
}


// MARK: - Core Data
extension ToDoListViewController {
    
    /// get all data stored in core data
    func fetchData() {
        let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()
        do {
            let notes = try PesistentStore.context.fetch(fetchRequest)
            self.notes = notes
            //            self.notesTableView.reloadData()
        } catch  {
            
        }
    }
    
    /// Delete data at a index in core data
    ///
    /// - Parameter index: row index to be deleted
    func deleteData(atIndex index:Int) {
        //Fetch request
        PesistentStore.context.delete(notes[index])
        PesistentStore.saveContext()
        notes.remove(at: index)
    }
    
    /// Method to filter the core data with given text
    ///
    /// - Parameter title: text to be searched
    func searchNote(noteTitle title:String) {
        let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()

        fetchRequest.predicate = NSPredicate(format: "note_title CONTAINS[c] %@", searchBar.text!)
        do{
            let results = try  PesistentStore.context.fetch(fetchRequest)
            notes = results
            
        } catch let error{
            print(error)
        }
    }
    
    /// setting table view on priority
    ///
    /// - Parameter sender: header view cell button
    @objc func setPriority(sender:UIButton) {
        
        let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()
        var sortDescriptor:NSSortDescriptor
        var key = "" //Key to be sort
        switch sender {
        case headerCell.noteTitleButton:
            key = "note_title"
            headerCell.dueDateButton.isSelected = false
            headerCell.priorityButton.isSelected = false
            
        case headerCell.priorityButton:
            key = "priority"
            headerCell.dueDateButton.isSelected = false
            headerCell.noteTitleButton.isSelected = false

        case headerCell.dueDateButton:
            key = "date"
            headerCell.noteTitleButton.isSelected = false
            headerCell.priorityButton.isSelected = false

        default:
           return
        }
        sender.isSelected = sender.isSelected ? false : true
        sortDescriptor = NSSortDescriptor(key: key, ascending: sender.isSelected)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        do {
            let records = try PesistentStore.context.fetch(fetchRequest)
            notes = records
            todoTableView.reloadData()
            
        } catch {
            print(error)
        }
    }
}
