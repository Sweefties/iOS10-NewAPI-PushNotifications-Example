//
//  MainVC.swift
//  iOS10-NewAPI-PushNotifications-Example
//
//  Created by Wlad Dicario on 24/09/2016.
//  Copyright © 2016 Sweefties. All rights reserved.
//
import UIKit
import UserNotifications
import UserNotificationsUI
import CoreLocation


// ********************************
//
// MARK: - Typealias
//
// ********************************

/// `UITableViewDataSource` protocol typealias
typealias MainTableViewDataSource   = MainVC
/// `UITableViewDelegate` protocol typealias
typealias MainTableViewDelegate     = MainVC
/// `UNUserNotificationCenterDelegate` protocol typealias
typealias UNCenterDelegate          = MainVC



/// `MainVC` class as `UIViewController`
///
/// a controller class to manage list of User Notifications and display them.
///
class MainVC: UIViewController {
    
    
    
    // ********************************
    //
    // MARK: - Properties
    //
    // ********************************
    let cellID      = "DefaultCell"
    let location    = CLLocationManager()
    var content     = [UNContent]()
    
    
    // ********************************
    //
    // MARK: - Interface
    //
    // ********************************
    @IBOutlet weak var tableView: UITableView!
    
    
    // ********************************
    //
    // MARK: - Lifecycle
    //
    // ********************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setTableView()
        setRegisterCell()
    }
    
    
    /// Set Table View
    func setTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView()
        self.tableView.rowHeight = 70
        self.tableView.estimatedRowHeight = UITableViewAutomaticDimension
    }
    
    
    /// Set Register Cell for Nib files.
    func setRegisterCell() {
        self.tableView.register(UINib.init(nibName: cellID, bundle: nil), forCellReuseIdentifier: cellID)
    }
    
    
    /// Add Notification to list
    ///
    /// - Parameter data: `UNContent` Model Collection
    ///
    func addNotificationModel(data: UNContent) {
        DispatchQueue.main.async {
            let indexPath = [IndexPath(item: 0, section: 0)]
            self.content.insert(data, at: 0)
            self.tableView.insertRows(at: indexPath, with: .bottom)
            self.tableView.reloadData()
        }
    }
    
    
    // ********************************
    //
    // MARK: - Memory Warning
    //
    // ********************************
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


/// UITableViewDataSource Extension.
extension MainTableViewDataSource : UITableViewDataSource {
    
    
    /// Asks the data source to return the number of sections in the table view.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content.count
    }
    
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! DefaultCell
        
        let row = content[indexPath.row]
        cell.configureCell(data: row)
        return cell
    }
}


/// UITableViewDelegate Extension.
extension MainTableViewDelegate : UITableViewDelegate {
    
    
    /// Tells the delegate that the specified row is now selected.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.row {
        default: print(indexPath.row)
        }
    }
}


/// UNUserNotificationCenterDelegate Extension.
/// Handles notification-related interactions for your app or app extension.
extension UNCenterDelegate: UNUserNotificationCenterDelegate {
    
    
    /// Called when a notification is delivered to a foreground app
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler( [.alert, .badge, .sound])
    }
    
    
    /// Called to let your app know which action was selected by the user for a given notification.
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        print("action selected for notification : \(response.actionIdentifier)")
    }
}
