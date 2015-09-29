//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Sudipta Bhowmik on 9/25/15.
//  Copyright © 2015 Timothy Lee. All rights reserved.
//

import UIKit


@objc protocol FiltersViewControllerDelegate {
    optional func didUpdateFilters(controller: FiltersViewController)
    
}


class FiltersViewController: UITableViewController {
    
   
   // @IBOutlet weak var tableView: UITableView!
    var expanded = false
    
    var categories: [[String:String]]!
    var switchStates = [Int:Bool]()
    
    var delegate: FiltersViewControllerDelegate?
    var myFilters:Filters?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //Instantiate the filters object to load filters
        self.myFilters = Filters(instance: Filters.instance)
        
        //tableView.delegate = self
        //tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.myFilters!.filters.count
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("in numberOfRowsInSection")
        let filter = self.myFilters!.filters[section] as Filter
        if filter.isExpanded {
            print("Returning all opts - \(filter.options.count)")
            //filter.isExpanded = false
            return filter.options.count
        } else {
           return filter.numOptsDisplayed!
        }
        
        //return (filterFields[section].1).count
        
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.myFilters?.filters[section].name
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(" IN cellForRowAtIndexPath")
        let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: nil)
        let filter = self.myFilters!.filters[indexPath.section] as Filter
        let option = filter.options[indexPath.row]
        cell.textLabel!.text = option.optionName
        //Add UIswitch for deal & category cells
        if filter.name == "Deal" || filter.name == "Category"
        {
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            let switchView = UISwitch(frame: CGRectZero)
            switchView.on = option.selected
            switchView.onTintColor = UIColor(red: 73.0/255.0, green: 134.0/255.0, blue: 231.0/255.0, alpha: 1.0)
            switchView.addTarget(self, action: "handleSwitchValueChanged:", forControlEvents: UIControlEvents.ValueChanged)
            cell.accessoryView = switchView
        } else if filter.name == "Distance" || filter.name == "Sort By" {
            if filter.isExpanded {
                let option = filter.options[indexPath.row]
                cell.textLabel!.text = option.optionName
                if option.selected {
                    cell.accessoryView = UIImageView(image: UIImage(named: "Check"))
                } else {
                    cell.accessoryView = UIImageView(image: UIImage(named: "Uncheck"))
                }
            } else {
                var selectedIndex: Int = 0
                if filter.name == "Distance" {
                    selectedIndex = (myFilters?.selectedDistanceIndex)!
                } else if filter.name == "Sort By" {
                    selectedIndex = (myFilters?.selectedSortIndex)!
                }
                cell.textLabel!.text = filter.options[selectedIndex].optionName
                cell.accessoryView = UIImageView(image: UIImage(named: "Uncheck"))
            }

        }
        
        
        //print("Indexpath.row is \(indexPath.row)")
        //Hide cells except the 1st one in each section except the Category section
        /*if indexPath.row > 0 && filter.name != "Category" && expanded == false{
            cell.hidden = true
        } else {
            cell.hidden = false
        }*/
        
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("in didSelectRowAtIndexPath")
        let filter = self.myFilters!.filters[indexPath.section] as Filter
        
        print("Filter name -- \(filter.name)")
        if filter.name == "Distance" || filter.name == "Sort By" && !filter.isExpanded {
            filter.isExpanded = true
            print("expanded == \(expanded)")
            // Sending the results back to main queue to update UI using the fetched data
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadSections(NSMutableIndexSet(index: indexPath.section), withRowAnimation: .Automatic)
            }
            
        }
        
        
        if filter.isExpanded {
            if filter.name == "Distance" {
                let oldSelectedDistance = myFilters?.selectedDistanceIndex
                if oldSelectedDistance != indexPath.row {
                    let oldIndex = NSIndexPath(forRow: oldSelectedDistance!, inSection: indexPath.section)
                    myFilters?.selectedDistanceIndex = indexPath.row
                    let option = filter.options[indexPath.row]
                    option.selected = true
                    self.tableView.reloadRowsAtIndexPaths([indexPath, oldIndex], withRowAnimation: .Automatic)
                    
                }
            } else if filter.name == "Sort By" {
                    let oldSelectedSort = myFilters?.selectedSortIndex
                    if oldSelectedSort != indexPath.row {
                        let oldIndex = NSIndexPath(forRow: oldSelectedSort!, inSection: indexPath.section)
                        myFilters?.selectedSortIndex = indexPath.row
                        self.tableView.reloadRowsAtIndexPaths([indexPath, oldIndex], withRowAnimation: .Automatic)
                        
                    }
            }
            //filter.isExpanded = false
        }
        
        /*if filter.name == "Category" || filter.name == "Deals" {
            print("Toggle switch")
                let option = filter.options[indexPath.row]
                option.selected = !option.selected
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }*/
    }
   
    func handleSwitchValueChanged(switchView: UISwitch) -> Void {
        
            let cell = switchView.superview as! UITableViewCell
            if let indexPath = self.tableView.indexPathForCell(cell) {
                let filter = self.myFilters!.filters[indexPath.section] as Filter
                let option = filter.options[indexPath.row]
                option.selected = switchView.on
            }
        
    }
    
    
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true,completion: nil)
    }

    @IBAction func onSearchButton(sender: AnyObject) {
        Filters.instance.copyFrom(self.myFilters!)
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.delegate?.didUpdateFilters!(self)

    }
 
    
    
  
   
    func yelpCategories() -> [[String:String]] {
        return [["name" : "afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"]
        ]
    }
    
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
