//
//  SpotListController.swift
//  MySpots
//
//  Created by cannabiolog420 on 08.10.2020.
//
import UIKit
import RealmSwift


class SpotListController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    
    private var spots:Results<Spot>!
    private var ascendingSorting = true
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredSpots:Results<Spot>!
    private var searchBarIsEmpty:Bool{
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering:Bool{
        
        return searchController.isActive && !searchBarIsEmpty
        
    }
    
    @IBOutlet weak var filterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sortingBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "My Spots"
        spots = realm.objects(Spot.self)
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.tintColor = .black
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    
        
    }

    // MARK: - Table view data source


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return isFiltering ? filteredSpots.count : spots.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "spotCell", for: indexPath) as! SpotCell
        
        let spot = isFiltering ? filteredSpots[indexPath.row] : spots[indexPath.row]
        
        cell.setSpot(spot: spot)
        
        return cell
    }
    
    //MARK: - Table view delegate
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete{
        
        let spot = spots[indexPath.row]
        StorageManager.deleteObject(spot)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
    }
    
    //MARK: - Navigation
    
    @IBAction func unwinsegue(segue:UIStoryboardSegue){
        
        guard segue.identifier == "saveSegue" else { return }
        
        guard let newSpotVC = segue.source as? AddNewSpotController else { return }
        newSpotVC.saveNewSpot()
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "editSegue" else { return }
        let addSpotVC = segue.destination as! AddNewSpotController
        let selectedPath = tableView.indexPathForSelectedRow
        let spot = isFiltering ? filteredSpots[selectedPath!.row] : spots[selectedPath!.row]
        addSpotVC.currentSpot = spot
    }
    
    
    
    
    @IBAction func sortingSelection(_ sender: UISegmentedControl) {
        
        sorting()
        
    }
    
    
    @IBAction func reversedSorting(_ sender: UIBarButtonItem) {
        
        ascendingSorting.toggle()
        
        sortingBarButtonItem.style = ascendingSorting ? .plain : .done
        
        sorting()
        
        
    }
    
    
    private func sorting(){
        
        
        if filterSegmentedControl.selectedSegmentIndex == 0{
            
            spots = spots.sorted(byKeyPath: "date", ascending: ascendingSorting)
            
        }else {
            
            spots = spots.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        tableView.reloadData()
    }
    

}


extension SpotListController:UISearchResultsUpdating{
    
    
    func updateSearchResults(for searchController: UISearchController) {
        
        filterContentForSearchText(searchController.searchBar.text!)
        
    }
    
    private func filterContentForSearchText(_ searchText:String){
        
        filteredSpots = spots.filter("name CONTAINS[c] %@",searchText)
        tableView.reloadData()
    }
    
    
}
