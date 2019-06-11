//
//  ViewController.swift
//  QuestRentaTeam
//
//  Created by Евгений Бейнар on 11/06/2019.
//  Copyright © 2019 zuk. All rights reserved.
//

import UIKit

private enum Constans: String {
    case fullImageSegue
    case listTableViewCell
}

final class ImageListViewController: UIViewController {
    
//MARK: - Variable
    private let model = ImageListModel()
    private var pageNumber = 1
    private var wallpapers = [Wallpaper]()
    private var waiting = false
    private var selectedImage: Wallpaper?
    private var refreshControl: UIRefreshControl!
    
    private let activityIndicator: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        return spinner
    }()
    
//MARK: - IB O
    @IBOutlet private weak var imageListTableView: UITableView! {
        didSet {
            imageListTableView.tableFooterView = UIView()
        }
    }
    
//MARK: - life C
    override func viewDidLoad() {
        super.viewDidLoad()
        showIndicator()
        setupTableView()
        setupRefresh()
        getPopularWallpapers(page: pageNumber, false)
    }
    
//MARK: - private func
    private func setupTableView() {
        imageListTableView.delegate = self
        imageListTableView.dataSource = self
    }
    
    private func getPopularWallpapers(page: Int, _ flag: Bool) {
        model.getPopularWallpapers(page: page) { (result) in
            switch result {
            case .success(let response):
                if flag { self.wallpapers.removeAll() }
                self.pageNumber += 1
                self.wallpapers.append(contentsOf: response)
                self.imageListTableView.reloadData()
                self.hideIndicator()
                self.refreshControl.endRefreshing()
                break
            case .failure(let error):
                if error._code == NSURLErrorTimedOut {
                    self.hideIndicator()
                    self.refreshControl.endRefreshing()
                    self.showErrorAlertMessage(title: "Error", message: "проверьте подключение")
                } else {
                    self.hideIndicator()
                    self.refreshControl.endRefreshing()
                    self.showErrorAlertMessage(title: "Error", message: error.localizedDescription)
                }
                break
            }
        }
        waiting = false
    }
    
    private func setupRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        imageListTableView.refreshControl = refreshControl
    }
    
    @objc private func refresh() {
        pageNumber = 1
        getPopularWallpapers(page: pageNumber, true)
    }
    
    private func showIndicator() {
        self.navigationItem.titleView = self.activityIndicator
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    private func hideIndicator() {
        self.navigationItem.titleView = nil
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constans.fullImageSegue.rawValue {
            let controller = segue.destination as! FullImageViewController
            controller.wallpaper = selectedImage
        }
    }
    
}

//MARK: - UITableViewDelegate
extension ImageListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if wallpapers.count > 0 {
            selectedImage = wallpapers[indexPath.row]
            performSegue(withIdentifier: Constans.fullImageSegue.rawValue, sender: self)
        }
        tableView.cellForRow(at: indexPath)?.isSelected = false
    }
}

//MARK: - UITableViewDataSource
extension ImageListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wallpapers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constans.listTableViewCell.rawValue, for: indexPath) as! ImageListTableViewCell
        if wallpapers.count > 0 {
            cell.configureCell(img: wallpapers[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == wallpapers.count - 1 && !self.waiting {
            waiting = true
            self.getPopularWallpapers(page: pageNumber, false)
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

