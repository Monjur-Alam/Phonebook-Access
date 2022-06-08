//
//  ViewController.swift
//  Phonebook Access
//
//  Created by MacBook Pro on 8/6/22.
//

import UIKit
import ContactsUI

struct Person {
    let name: String
    let id: String
    let source: CNContact
}

protocol getData {
    func setContact(name: String, number: String)
}

class ViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, getData {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var recipientName: UITextField!
    @IBOutlet weak var saveContactButton: UIButton!
    @IBOutlet weak var phoneNumberBack: UIView!
    
    @IBAction func getContact(_ sender: Any) {
        recipientName.resignFirstResponder()
        phoneNumber.resignFirstResponder()
        let cnPicker = CNContactPickerViewController()
        cnPicker.delegate = self
        self.present(cnPicker, animated: true, completion: nil)
    }
    
    @IBAction func saveContact(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidDisapear), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        recipientName.layer.cornerRadius = 5.0
        recipientName.layer.borderWidth = 0.5
        recipientName.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
        let leftView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 16.0, height: 0.0))
        let rightView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 50.0, height: 0.0))
        recipientName.leftView = leftView
        recipientName.rightView = rightView
        recipientName.leftViewMode = .always
        recipientName.rightViewMode = .always
        recipientName.delegate = self
        recipientName.addTarget(self, action: #selector(nameFieldDidChange), for: .editingChanged)
        phoneNumberBack.layer.cornerRadius = 5.0
        phoneNumberBack.layer.borderWidth = 0.5
        phoneNumber.layer.masksToBounds = true
        phoneNumberBack.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
        phoneNumber.addTarget(self, action: #selector(phoneNumberFieldDidChange), for: .editingChanged)
        phoneNumber.delegate = self
    }
    
    var isExpand: Bool = false
    @objc private func keyboardAppear() {
        if !isExpand {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.frame.height + 100)
            self.isExpand = true
        }
    }
    
    @objc private func keyboardDidDisapear() {
        if isExpand {
            self.scrollView.contentSize = CGSize(width: self.view.frame.width, height: self.scrollView.frame.height - 100)
            self.isExpand = false
        }
    }
    
    @objc private func nameFieldDidChange(textField: UITextField) {
        if (textField.text!.count > 0) {
            recipientName.layer.borderColor = UIColor(red: 91/255, green: 6/255, blue: 151/255, alpha: 1.0).cgColor
            if (phoneNumber.text!.count > 9) {
                saveContactButton.isEnabled = true
            } else {
                saveContactButton.isEnabled = false
            }
        } else {
            recipientName.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
            saveContactButton.isEnabled = false
        }
    }
    
    @objc private func phoneNumberFieldDidChange(textField: UITextField) {
        
        if (textField.text!.count > 0) {
            phoneNumberBack.layer.borderColor = UIColor(red: 91/255, green: 6/255, blue: 151/255, alpha: 1.0).cgColor
        } else {
            phoneNumberBack.layer.borderColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1.0).cgColor
        }
        if (textField.text!.count > 9) {
            if (recipientName.text!.count > 0) {
                saveContactButton.isEnabled = true
            } else {
                saveContactButton.isEnabled = false
            }
        } else {
            saveContactButton.isEnabled = false
        }
    }
    
    func setContact(name: String, number: String) {
        recipientName.text = name
        nameFieldDidChange(textField: recipientName)
        if number.starts(with: "+880") {
            phoneNumber.text = String(number.suffix(10))
            phoneNumberFieldDidChange(textField: phoneNumber)
        } else if number.starts(with: "0") {
            phoneNumber.text = String(number.suffix(10))
            phoneNumberFieldDidChange(textField: phoneNumber)
        } else {
            phoneNumber.text = number
            phoneNumberFieldDidChange(textField: phoneNumber)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: CNContact) {
        
        var models = [Person]()
        var name = ""
        if contacts.givenName != "" {
            name = contacts.givenName
        }
        if contacts.middleName != "" {
            name = name + " " + contacts.middleName
        }
        if contacts.familyName != "" {
            name = name + " " + contacts.familyName
        }
        if contacts.nameSuffix != "" {
            name = name + " " + contacts.nameSuffix
        }
        dismiss(animated: true, completion: nil)
        if contacts.phoneNumbers.count > 1 {
            let model = Person(name: name, id: contacts.identifier, source: contacts)
            
            models.append(model)
            
            let viewController:
            ContactDialogViewController = UIStoryboard(
                name: "Main", bundle: nil
            ).instantiateViewController(withIdentifier: "ContactDialogViewController") as! ContactDialogViewController
            
            viewController.delegate = self
            viewController.modalPresentationStyle = .overCurrentContext
            viewController.numbers = models
            
            self.present(viewController, animated: false, completion: nil)
        } else {
            if contacts.phoneNumbers.count != 0 {
                setContact(name: name, number: (contacts.phoneNumbers[0].value).value(forKey: "digits") as! String)
            } else {
                self.recipientName.text = name
                self.phoneNumber.text = ""
            }
        }
    }
    
    func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
        print("Cancel Contact Picker")
    }
}

