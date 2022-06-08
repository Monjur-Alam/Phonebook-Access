//
//  ContactListTableViewCell.swift
//  Phonebook Access
//
//  Created by MacBook Pro on 8/6/22.
//

import UIKit

class ContactListTableViewCell: UITableViewCell {

    @IBOutlet weak var number: UILabel!

    func UpdateCellView(numberText: String) {
        number.text = numberText
    }

}
