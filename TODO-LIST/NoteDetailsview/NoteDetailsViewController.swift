//
//  NoteDetailsViewController.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 19/02/18.
//  Copyright © 2018 Raghavendra Shedole. All rights reserved.
//

import UIKit

enum NotePriority:Int16 {
    case High = 2
    case Low = 1
    case None = 0
}

class NoteDetailsViewController: UIViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var lowPriorityButton: UIButton!
    @IBOutlet weak var highPriorityButton: UIButton!
    
    var noteTitle = ""
    var date = Date()
    var priority:NotePriority = .None
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        // Do any additional setup after loading the view.
    }
    
    func setData(){
        if noteTitle.count > 0 {
            self.titleTextField.text = noteTitle
            self.datePicker.date = date
            if self.priority == .High {
                priorityButtonAction(highPriorityButton)
            }else {
                priorityButtonAction(lowPriorityButton)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
}

// MARK: - Button Methods
extension NoteDetailsViewController {
    @IBAction func doneButtonAction(_ sender: UIButton) {
        if titleTextField.text?.count == 0 {
            self.showAlert(withMessage: "Please enter the \"Note Title\".")
        }else if priority == .None {
            self.showAlert(withMessage: "Please set the priority.")
        }else {
            date = self.datePicker.date
            noteTitle = titleTextField.text!
            performSegue(withIdentifier: String(describing:ToDoListViewController.self), sender: nil)
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton)  {
        dismiss(animated: false, completion: nil)
    }
    
    /// Priority buttons Action method (common for both the buttons)
    ///
    /// - Parameter sender: High priority or Low Priority
    @IBAction func priorityButtonAction(_ sender: UIButton) {
        
        if sender == lowPriorityButton {
            self.lowPriorityButton.backgroundColor = .red
            self.highPriorityButton.backgroundColor = .white
            priority = .Low
            
        }else {
            self.lowPriorityButton.backgroundColor = .white
            self.highPriorityButton.backgroundColor = .red
            priority = .High
        }
    }
}

extension NoteDetailsViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
