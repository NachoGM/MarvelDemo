//
//  DetailedViewController.swift
//  MarvelDemo
//
//  Created by Nacho González Miró on 28/6/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import SVProgressHUD

class DetailedViewController: UIViewController {

    // MARK: Declare Outlets
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var detailedTableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var formatLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var infoView: UIView!
    
    @IBOutlet weak var titleComicLabel: UILabel!
    @IBOutlet weak var descriptionComicLabel: UILabel!
    
    
    var comics: Comics?
    var titles = ["TITLE", "DESCRIPTION", "PRICE"]
    var poster: String!
    var numberOfCreators: Int?
    
    // MARK: - Display LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        configUI()
        initTableViewMethods()
    }
    
    func initTableViewMethods() {
        detailedTableView.dataSource = self
        detailedTableView.delegate = self
        registerXibCells()
    }
    
    func registerXibCells() {
        detailedTableView.register(UINib(nibName: "DetailedCell", bundle: nil), forCellReuseIdentifier: "detailedCell")
    }
    
    func configUI() {
        loadLabels()
        initCreatorRowsInTableView()
        configImageDetailed()
        configViewIfImageNotAvaiable()
    }
    
    func loadLabels() {
        formatLabel.text = comics?.format
        titleComicLabel.text = comics?.title
        descriptionComicLabel.text = comics?.description
    }
    
    func configViewIfImageNotAvaiable() {
        if poster.contains("image_not_available") {
            formatLabel.textColor = .white
            backButton.setBackgroundImage(UIImage(named: "ic_back-w"), for: .normal)
        } else {
            formatLabel.textColor = .black
            backButton.setBackgroundImage(UIImage(named: "ic_back-b"), for: .normal)
        }
    }
    
    func initCreatorRowsInTableView() {
        let numberOfCreators = comics?.creators!.value(forKey: "returned") as? NSNumber
        let creator: Int = numberOfCreators as! Int
        self.numberOfCreators = creator
    }
    
    func configImageDetailed() {
        let imgURL = NSURL(string: poster)
        let data = NSData(contentsOf: (imgURL as URL?)!)
        thumbnail.image = UIImage(data: data! as Data)
    }
    
    // MARK: - Display Button Actions
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        switch segmentedControl.selectedSegmentIndex {
        case Position.Info.hashValue:
            initInfoView()
        case Position.CreatedBy.hashValue:
            infoView.isHidden = true
        default:
            initInfoView()
        }
    }
    
    func initInfoView() {
        infoView.isHidden = false
        titleComicLabel.text = comics?.title
        descriptionComicLabel.text = comics?.description
    }
    
}

// MARK: -  Extensions: TableView Methods
extension DetailedViewController: UITableViewDataSource {
    
    enum Position {
        case Info
        case CreatedBy
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if numberOfCreators == 0 {
            return 1
        } else {
            return numberOfCreators!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if numberOfCreators == 0 {
            return handleCreatorsCell(name: "Name not found", job: "Job not found", thumbnail: "Thumbnail not found")
        } else {
            let items = comics?.creators.value(forKey: "items") as! NSArray
            let name = displayCreatorsName(items: items, indexPath: indexPath)
            let job = displayCreatorsRole(items: items, indexPath: indexPath)
            let thumbnail = displayCreatorsImage(items: items, indexPath: indexPath)
            return handleCreatorsCell(name: name, job: job, thumbnail: thumbnail)
        }
    }
    
    // MARK:  Handle Cell Information
    func displayCreatorsName(items: NSArray, indexPath: IndexPath) -> String {
        let nameArray = items.value(forKey: "name") as! NSArray
        let name = nameArray[indexPath.row] as! String
        return name
    }
    
    func displayCreatorsRole(items: NSArray, indexPath: IndexPath) -> String {
        let jobArray = items.value(forKey: "role") as! NSArray
        let job = jobArray[indexPath.row] as! String
        return job
    }
    
    func displayCreatorsImage(items: NSArray, indexPath: IndexPath) -> String {
        let thumbnailArray = items.value(forKey: "resourceURI") as! NSArray
        let thumbnail = thumbnailArray[indexPath.row] as! String
        return thumbnail
    }
    
    // MARK:  Configure Cells
    func handleCreatorsCell(name: String, job: String, thumbnail: String) -> UITableViewCell {
        let cell = detailedTableView.dequeueReusableCell(withIdentifier: "detailedCell") as! DetailedCell
        let posterURL: String = poster
        let imgURL = NSURL(string: posterURL)
        let data = NSData(contentsOf: (imgURL as URL?)!)
        
        if imgURL != nil {
            cell.nameLabel.text = name
            cell.jobLabel.text = job
            cell.thumbnailImage.image = UIImage(data: data! as Data)
        } else {
            cell.nameLabel.text = " Error"
            cell.jobLabel.text = " Error"
            cell.thumbnailImage.backgroundColor = .black
        }
        cell.selectionStyle = .none
        
        return cell
    }
}

extension DetailedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120.00
    }
}
