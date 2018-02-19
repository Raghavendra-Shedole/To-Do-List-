//
//  NoteDetailsViewController.swift
//  TODO-LIST
//
//  Created by Raghavendra Shedole on 20/02/18.
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
    
    @IBOutlet weak var backgroundView: CustomView!
    var note:NoteClass?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        
        self.datePicker.minimumDate = Date()
        setInitialState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showAnimation()
    }
    
    func setInitialState() {
        self.backgroundView.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        self.backgroundView.layer.opacity = 0.01
    }
    
    /// Presenting view animation
    func showAnimation() {
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.layer.opacity = 1.0
            self.backgroundView.layer.transform = CATransform3DMakeScale(1,1,1)
        })
    }
    
    /// Hide view controller
    func hideAnimation() {
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.layer.opacity = 0.1
            self.backgroundView.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        }) { _ in
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Setting data to edit
    func setData(){
        if let note = note  {
            self.titleTextField.text = note.note_title
            self.datePicker.date = note.date! as Date
            if note.priority == NotePriority.High.rawValue {
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
        }else if !highPriorityButton.isSelected && !lowPriorityButton.isSelected {
            self.showAlert(withMessage: "Please set the priority.")
        }else {
            note?.note_title = titleTextField.text
            note?.priority = highPriorityButton.isSelected ? NotePriority.High.rawValue : NotePriority.Low.rawValue
            note?.date = datePicker.date as NSDate
            performSegue(withIdentifier: String(describing:ToDoListViewController.self), sender: nil)
        }
    }
    
    @IBAction func cancelButtonAction(_ sender: UIButton)  {
        hideAnimation()
    }
    
    /// Priority buttons Action method (common for both the buttons)
    ///
    /// - Parameter sender: High priority or Low Priority
    @IBAction func priorityButtonAction(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender == lowPriorityButton {
            self.lowPriorityButton.backgroundColor = .red
            self.highPriorityButton.backgroundColor = .white
            
        }else {
            self.lowPriorityButton.backgroundColor = .white
            self.highPriorityButton.backgroundColor = .red
        }
    }
}

// MARK: - UITextFieldDelegate
extension NoteDetailsViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
