//
//  ToDoListViewController.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 18/02/18.
//  Copyright © 2018 Raghavendra Shedole. All rights reserved.
//

import UIKit
import CoreData

class ToDoListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var todoTableView: UITableView!
    var notes:[NoteClass] = []
    var selectedIndex = -1
    var ascending =  true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        todoTableView.rowHeight = 50
        todoTableView.estimatedRowHeight = UITableViewAutomaticDimension
        fetchData()
    }
    
    
    
    func deleteData(atIndex index:Int) {
        //Fetch request
        PesistentStore.context.delete(notes[index])
        PesistentStore.saveContext()
        //        context.delete(notes[index])
        notes.remove(at: index)
    }
    
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: String(describing:NoteDetailsViewController.self), sender: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func unwindSegue(segue:UIStoryboardSegue) {
        
        
        
        let noteDetailsVC = segue.source as! NoteDetailsViewController
        
        
        let noteClass = NoteClass(context:PesistentStore.context)
        noteClass.note_title = noteDetailsVC.noteTitle
        noteClass.date = noteDetailsVC.date as NSDate
        noteClass.priority = noteDetailsVC.priority.rawValue
        
        PesistentStore.saveContext()
        self.notes.append(noteClass)
        
        let when = DispatchTime.now() + 1.0
        DispatchQueue.main.asyncAfter(deadline: when){
            self.todoTableView.beginUpdates()
            self.todoTableView.insertRows(at: [IndexPath(row: self.notes.count-1, section: 0)], with: .top)
            self.todoTableView.endUpdates()
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
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
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:HeaderCell.self)) as! HeaderCell
        cell.priorityButton.addTarget(self, action: #selector(setPriority(sender:)), for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (rowAction, indexPath) in
            //TODO: edit the row at indexPath here
            self.selectedIndex = indexPath.row
            self.performSegue(withIdentifier: String(describing:NoteDetailsViewController.self), sender: true)
            
        }
        editAction.backgroundColor = .blue
        
        let deleteAction = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction, indexPath) in
            //TODO: Delete the row at indexPath here
            self.deleteData(atIndex: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        deleteAction.backgroundColor = .red
        
        return [editAction,deleteAction]
    }
    
    @objc func setPriority(sender:UIButton) {
        let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()
        
        if  ascending {
            ascending = false
        }else {
            ascending = true
        }
        
        // Add Sort Descriptor
        let sortDescriptor = NSSortDescriptor(key: "priority", ascending: ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {
            let records = try PesistentStore.context.fetch(fetchRequest)
            notes = records
            todoTableView.reloadData()
            
//            for record in records {
//                print(record.value(forKey: "name") ?? "no name")
//            }
            
        } catch {
            print(error)
        }
    }
    
}

extension ToDoListViewController:UISearchBarDelegate {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When there is no text, filteredData is the same as the original data
        // When user has entered text into the search box
        // Use the filter method to iterate over all items in the data array
        // For each item, return true if the item should be included and false if the
        // item should NOT be included
        
        if (searchBar.text?.isEmpty)! {
            self.fetchData()
        }else {
            
            let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "note_title CONTAINS[c] %@", searchBar.text!)
            do{
                let results = try  PesistentStore.context.fetch(fetchRequest)
                notes = results
                
            } catch let error{
                print(error)
            }
        }
        
       
        
    

        self.todoTableView.reloadData()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
    }
    
    
}


// MARK: - Core Data
extension ToDoListViewController {
    private static let fetchRequest:NSFetchRequest<NoteClass> = NoteClass.fetchRequest()
    
    func fetchData() {
        //Fetch request
        
        //let results = PresistentStore.
        
        do {
            let notes = try PesistentStore.context.fetch(ToDoListViewController.fetchRequest)
            self.notes = notes
            //            self.notesTableView.reloadData()
        } catch  {
            
        }
    }
}
