//
//  extension+ViewController.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import UIKit

extension UIViewController {
    public func showErrorAlertMessage(title: String, message: String) {
        // create alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        //add btn action
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        //show
        self.present(alert, animated: true, completion: nil)
    }
}
