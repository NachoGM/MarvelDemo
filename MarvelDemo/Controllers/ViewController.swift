//
//  ViewController.swift
//  MarvelDemo
//
//  Created by Nacho González Miró on 27/6/18.
//  Copyright © 2018 Nacho González Miró. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON
import SwiftHash

class ViewController: UIViewController {

    @IBOutlet weak var comicTableView: UITableView!
    
    var comics = [Comics]()
    var comicsArray = [Any]()
    var helper = Helper()
    
    // MARK: - Display LifeCycle Methods here
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initComicsJson()
        initTableViewMethods()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        initTableViewMethods()
    }
    
    //  Handle TableView Methods and load Xib
    func initTableViewMethods() {
        comicTableView.dataSource = self
        comicTableView.delegate = self
        registerXibCell()
    }
    
    func registerXibCell() {
        comicTableView.register(UINib(nibName: "ComicCell", bundle: nil), forCellReuseIdentifier: "comicCell")
    }
    
    //  Handle API Response
    func initComicsJson() {
        let mergeStrings = helper.ts + helper.privateKey + helper.publicKey
        let hash = MD5(mergeStrings).lowercased()
        let URL_AUTH = helper.BASE_URL + "/v1/public/comics?ts=\(helper.ts)&apikey=\(helper.publicKey)&hash=\(hash)"
        
        SVProgressHUD.show(withStatus: "Loading Comics")
        Alamofire.request(URL_AUTH, method: .get).responseData { response in
            
            switch response.response?.statusCode {
            case 200:
                let jsonData = JSON(response.result.value!)
                self.handleError200(jsonData: jsonData)
            case 401:
                self.helper.handleError401(hash: hash)
            case 403:
                self.helper.handleError403()
            case 405:
                self.helper.handleError405()
            case 409:
                self.helper.handleError409(hash: hash)
            default:
                NSLog(" Error in jsonAuth")
            }
        SVProgressHUD.dismiss()
        }
    }
    
    //  Handle Errors in API Request
    func handleError200(jsonData: JSON) {
        if let arrJSON = jsonData["data"]["results"].arrayObject {
            for i in 0...arrJSON.count-1 {
                let aObject = arrJSON[i] as? [String: Any]
                let comicDict = Comics(with: aObject!)
                self.comics.append(comicDict)
            }
            self.comicTableView.reloadData()

        } else {
            helper.displayAlertMessage(userTitle: "Ups...", userMessage: "We couldn't load info. Please try it again")
            return
        }
    }
    
    // MARK:  Display Button Actions
    @IBAction func searcherButtonTapped(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        present(searchController, animated: true, completion: nil)
    }
}

// MARK:-  Display TableView Extensions
extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.comics.count > 0 {
            return self.comics.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let format = self.comics[indexPath.row].format
        let name = self.comics[indexPath.row].title
        let imageURL = self.comics[indexPath.row].thumbnail.values.reversed().first ?? ""
        let thumbnail = "\(imageURL)" + ".jpg"
        let title = self.comics[indexPath.row].series["name"] ?? ""
        return handleCell(indexPath: indexPath, title: title as! String, name: name!, format: format!, thumbnail: thumbnail)
    }
    
    //  Custom Cell
    func handleCell(indexPath: IndexPath, title: String, name: String, format: String, thumbnail: String) -> UITableViewCell {
        //let cell = comicTableView.dequeueReusableCell(withIdentifier: "comicCell") as! ComicCell
        let cell = comicTableView.dequeueReusableCell(withIdentifier: "comicCell", for: indexPath) as! ComicCell
        let imgURL = NSURL(string: thumbnail)
        
        if imgURL != nil {
            let data = NSData(contentsOf: (imgURL as URL?)!)
            cell.titleComicLabel.text = title
            cell.titleNameLabel.text = name
            cell.formatLabel.text = format
            cell.comicImage.image = UIImage(data: data! as Data)
        } else {
            cell.titleComicLabel.text = " Error"
            cell.titleNameLabel.text = " Error"
            cell.formatLabel.text = " Error"
            cell.comicImage.backgroundColor = .black
        }
        cell.whiteView.layer.cornerRadius = 5
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailed") as! DetailedViewController
        vc.comics = comics[indexPath.row]
        vc.poster = displayThumbnailURL(indexPath: indexPath)
        self.present(vc, animated: true, completion: nil)
    }
    
    func displayDescription(v_description: String) -> String {
        var descrString = String()
        if v_description.isEmpty {
            descrString = "Description not founded"
        } else {
            descrString = v_description
        }
        return descrString
    }
    
    func displayThumbnailURL(indexPath: IndexPath) -> String {
        let imageURL = comics[indexPath.row].thumbnail.values.reversed().first ?? ""
        let thumbnail = "\(imageURL)" + ".jpg"
        return thumbnail
    }
}

// MARK:-  Display SearchBar Extension
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        UIApplication.shared.beginIgnoringInteractionEvents()
        searchBar.placeholder = "Search by title"
        let activityIndicator = UIActivityIndicatorView()
        displayActivityIndicator(activityIndicator: activityIndicator)
        
        searchBar.resignFirstResponder()
        
        dismiss(animated: true, completion: nil)
        
        if searchBar.text?.isEmpty != true {
            for i in 0...comics.count {
                for comic in comics {
                    if comic.title!.contains(searchBar.text!) {
                        activityIndicator.stopAnimating()
                        let thumbnail: String = comic.thumbnail.reversed().first?.value as! String
                        let comicObject = Comics(title: comic.title, description: comic.variantDescription, format: comic.format, image: thumbnail + ".jpg", creators: comic.creators)
                        
                        sendComicInfoToDetailed(object: comicObject, thumbnail: thumbnail + ".jpg")
                        break
                    }
                    if i == comics.count && !(comic.title!.contains(searchBar.text!)) {
                        activityIndicator.stopAnimating()
                        helper.displayAlertMessage(userTitle: "Comic not found",
                                                   userMessage: "Please try it with another name")
                        return
                    }
                }
            }
        }
    }
    
    //  Handle Activity Indicator
    func displayActivityIndicator(activityIndicator: UIActivityIndicatorView) {
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
    }
    
    //  Send Info to next ViewController
    func sendComicInfoToDetailed(object: Comics, thumbnail: String) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "detailed") as! DetailedViewController
        vc.comics = object
        vc.poster = thumbnail
        present(vc, animated: true, completion: nil)
    }

}
