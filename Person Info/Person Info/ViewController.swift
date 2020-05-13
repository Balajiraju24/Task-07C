//
//  ViewController.swift
//  Person Info
//  Task 07 C
//  Created by Balaji on 25/4/20.
//  Copyright © 2020 Balaji. All rights reserved.
//
import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tablelist: UITableView!
    @IBOutlet weak var segments: UISegmentedControl!
    @IBOutlet weak var textView: UILabel!
    @IBOutlet weak var addbutton: UIBarButtonItem!
    @IBOutlet weak var editbutton: UIBarButtonItem!
    @IBOutlet weak var refreshbutton: UIBarButtonItem!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var `switch`: UIBarButtonItem!

    //var searchedData = [String]()
    var searching = false
    var addNameofPerson:  UITextField!
    var addAgeofPerson: UITextField!
    var addPlaceofPerson: UITextField!
    var searchedData: [Biodata] = []
    var bioArray = [Biodata]()
    //var sortArray = [Biodata]()
    var filterArray = [Biodata]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        copyURL()
        loadURL()
        //sort()
        sort2()
        //filter()
        tablelist.dataSource = self
        tablelist.delegate = self
        searchBar.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func refreshButton(_ sender: Any) {
        sort2()
        tablelist.reloadData()
        let alert = UIAlertController(title: "", message: "The Data has been refreshed and sorted... Thanks", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(alertAction)
        self.present(alert,animated: true, completion: nil)
    }
    
    @IBAction func segmentedControl(_ sender: Any) {
        tablelist.reloadData()
    }
    
    func displayform()
    {
        let alert = UIAlertController(title: "", message: "Add Person information", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add", style: .default)
        {
            (action) -> Void in
            if((self.addNameofPerson.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! ||
                (self.addAgeofPerson.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)! ||
                (self.addPlaceofPerson.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!)
            {
                self.addNameofPerson.text = ""
                self.addAgeofPerson.text = ""
                self.addPlaceofPerson.text = ""
                self.displayform()
            }
            else
            {
                self.bioArray.append(Biodata(name: self.addNameofPerson.text!, age: Int(self.addAgeofPerson.text!)!, place: self.addPlaceofPerson.text!))
                self.updateJSON()
                self.insertRow()
            }
        }
        alert.addAction(addAction)
        //alert.addAction(addMoreItemAction)
        alert.addAction(cancelAction)
        
        alert.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Type Name"
            self.addNameofPerson = textField})
        alert.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Type Age"
            self.addAgeofPerson = textField})
        alert.addTextField(configurationHandler: {(textField: UITextField!) in textField.placeholder = "Type Place"
            self.addPlaceofPerson = textField})
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateJSON()
    {
        let jsonURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURLpath = jsonURL.appendingPathComponent("swiftData.json")
        do{
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let jsonData =  try encoder.encode(Listthebio(bioData: bioArray))
            try jsonData.write(to: jsonURLpath)
        }
        catch
        {
            print(error)
        }
    }
    
    func insertRow()
    {
        let indexPath = IndexPath(row: bioArray.count - 1, section: 0)
        tablelist.insertRows(at: [indexPath], with: .automatic)
        tablelist.reloadData()
    }
    
    /*let segments: UISegmentedControl = {
     let sc = UISegmentedControl(items: ["Filter","Sort","Display"])
     sc.selectedSegmentIndex = 0
     sc.addTarget(self, action: #selector(segmentedcControl), for: .valueChanged)
     return sc
     }()*/
    
    //three different array for each operaitons
    
    
    //file manager of the json file
    func copyURL()
    {
        let jsonURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURLpath = jsonURL.appendingPathComponent("swiftData.json")
        
        print(jsonURLpath)
        if let path = Bundle.main.path(forResource: "swiftData", ofType: "json"),
            let data = FileManager.default.contents(atPath: path),
            FileManager.default.fileExists(atPath: jsonURLpath.path) == false
        {
            FileManager.default.createFile(atPath: jsonURLpath.path, contents: data, attributes: nil)
        }
    }
    
    //decoder
    func decodefunction()->Listthebio
    {
        let jsonURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let jsonURLpath = jsonURL.appendingPathComponent("swiftData.json")
        
        guard let data = try? Data.init(contentsOf: jsonURLpath),
            let listthebio = try? JSONDecoder().decode(Listthebio.self, from: data)
            else
        {
            return Listthebio(bioData: [Biodata(name: "", age: 0, place: "")])
        }
        return listthebio
    }
    
    //segmented view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch segments.selectedSegmentIndex {
        case 0:
            return bioArray.count
        case 1:
            if searching {
                return searchedData.count
            } else {
                return bioArray.count
            }
        case 2:
            return bioArray.count
        default:
            break
        }
        //tablelist.reloadData()
        return 0
    }
    
    //table view with respectivee cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "tablecell")
        
        if (cell == nil)
        {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "tablecell")
        }
        
        
        switch segments.selectedSegmentIndex {
        case 0:
            addbutton.isEnabled = true
            editbutton.isEnabled = true
            searchBar.isHidden = true
            refreshbutton.isEnabled = false
            cell?.textLabel?.text = "Name: \(bioArray[indexPath.row].name)"
            cell?.detailTextLabel?.text = "Age: \(bioArray[indexPath.row].age)   Place: \(bioArray[indexPath.row].place)"
            
        case 1:
            addbutton.isEnabled = false
            editbutton.isEnabled = false
            searchBar.isHidden = false
            refreshbutton.isEnabled = false
            //textView.text = "Filtered by Age - Below 35"
            if searching {
                cell?.textLabel?.text = "Place: \(searchedData[indexPath.row].place)"
                cell?.detailTextLabel?.text = "Name: \(searchedData[indexPath.row].name)   Age: \(searchedData[indexPath.row].age)"
            } else {
                //textView.text = "Filtered by Age - Below 35"
                cell?.textLabel?.text = "Place: \(bioArray[indexPath.row].place)"
                cell?.detailTextLabel?.text = "Name: \(bioArray[indexPath.row].name)   Age: \(bioArray[indexPath.row].age)"
            }
        
        case 2:
            addbutton.isEnabled = false
            editbutton.isEnabled = false
            searchBar.isHidden = true
            refreshbutton.isEnabled = true
            sort2()
            //textView.text = "Sorted by Name -> A-Z"
            //tablelist.reloadData()
            //tableView.reloadData()
            cell?.textLabel?.text = "Name: \(bioArray[indexPath.row].name)"
            cell?.detailTextLabel?.text = "Place: \(bioArray[indexPath.row].place)   Age: \(bioArray[indexPath.row].age)"
        default:
            break
        }
        
        /*cell?.textLabel?.text = "Place: \(bioArray[indexPath.row].place)"
         cell?.detailTextLabel?.text = "Name: \(bioArray[indexPath.row].name)   Age: \(bioArray[indexPath.row].age)"*/
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete){
            bioArray.remove(at: indexPath.item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            updateJSON()
            tablelist.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedOject = bioArray[sourceIndexPath.item]
        bioArray.remove(at: sourceIndexPath.item)
        bioArray.insert(movedOject, at: destinationIndexPath.item)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedData = bioArray.filter({$0.place.lowercased().prefix(searchText.count) == searchText.lowercased()})
        searching = true
        tablelist.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tablelist.reloadData()
    }
    
    /*@IBAction func editButton(_ sender: UIBarButtonItem)
     {
     let alert = UIAlertController(title: "", message: "The Edit operation is not yet done for this task... Thanks", preferredStyle: .alert)
     let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
     alert.addAction(alertAction)
     self.present(alert,animated: true, completion: nil)
     }*/
    
    //deleting and manual arranging button
    @IBAction func editButton(_ sender: UIBarButtonItem) {
        
        self.tablelist.isEditing = !self.tablelist.isEditing
        addbutton.isEnabled = (self.tablelist.isEditing) ? false : true
        sender.title = (self.tablelist.isEditing) ? "Done" : "Edit"
        
        //let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButton(_ :)))
        //self.navigationItem.rightBarButtonItem = (self.tablelist.isEditing) ? nil : addButton
    }
    
    @IBAction func addButton(_ sender: Any) {
        displayform()
    }
    
    //loading the url of the decodable function
    func loadURL()
    {
        let listthebio = decodefunction()
        bioArray.append(contentsOf: listthebio.bioData)
        //print(bioArray)
    }
    
    //sorting based on name
    /*func sort()
     {
            bioArray = bioArray.sorted
            {
                $1.name < $0.name
            }
     }*/
    //sorting by places
    
    func sort2()
    {
        bioArray = bioArray.sorted
            {
                $0.name < $1.name
        }
    }
}

