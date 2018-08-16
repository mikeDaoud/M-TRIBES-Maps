//
//  CarsListViewController.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import UIKit
import Pulley
import RxSwift
import RxCocoa

class CarsListViewController: UIViewController {
    
    // MARK: - Constants
    private let carCellId = "carCell"

    // MARK: - View Outlets
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var gripView: UIView!{
        didSet{
            gripView.layer.cornerRadius = gripView.frame.height / 2
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!{
        didSet{
            searchBar.delegate = self
            searchBar.showsScopeBar = false
        }
    }
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var carsListTableView: UITableView!
    
    // MARK: - View Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindToCarsFullList()
        bindTableViewSelection()
        startObservingSelectedCar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let hapticFeedbackSelection = UISelectionFeedbackGenerator()
        self.pulleyViewController?.feedbackGenerator = hapticFeedbackSelection
    }
    
    // MARK: - Binding to cars list
    
    fileprivate var locationsStore = LocationsDataStore.shared
    private let disposeBag = DisposeBag()
    
    private func bindToCarsFullList(){
        carsListTableView.delegate = nil
        carsListTableView.dataSource = nil
        locationsStore.placemarks
            .bind(to: carsListTableView.rx.items(cellIdentifier: carCellId)){ _ , location, cell in
                cell.textLabel?.text = location.placemark.name
                cell.detailTextLabel?.text = location.placemark.address
                cell.contentView.backgroundColor = .clear
                cell.backgroundView = UIView()
        }.disposed(by: disposeBag)
    }
    
    private func bindToFilteredList(){
        carsListTableView.delegate = nil
        carsListTableView.dataSource = nil
        locationsStore.filteredPlacemarks
            .bind(to: carsListTableView.rx.items(cellIdentifier: carCellId)){ _ , location, cell in
                cell.textLabel?.text = location.placemark.name
                cell.detailTextLabel?.text = location.placemark.address
                cell.contentView.backgroundColor = .clear
                cell.backgroundView = UIView()
            }.disposed(by: disposeBag)
    }
    
    private func bindTableViewSelection(){
        carsListTableView.rx.modelSelected(MapPlacemarker.self)
            .subscribe(onNext: { (selectedCar) in
                self.locationsStore.select(selectedCar)
                if let index = self.carsListTableView.indexPathForSelectedRow{
                    self.carsListTableView.deselectRow(at: index, animated: true)
                }
            }).disposed(by: disposeBag)
    }
    
    private func startObservingSelectedCar(){
        locationsStore.selectedMark.asObservable()
            .subscribe(onNext: { (selectedMarker) in
                if let marker = selectedMarker{
                    self.showCarDetails(with: marker.placemark)
                    self.view.endEditing(true)
                }else{
                    self.hideCarDetails()
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Car details view
    
    lazy var detailsView = CarDetailsView(frame: self.containerView.bounds)
    
    private func showCarDetails(with placemark: Placemark){
        detailsView.configureCell(with: placemark)
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromRight
        containerView.layer.add(transition, forKey: nil)
        containerView.addSubview(self.detailsView)
        carsListTableView.isHidden = true
        searchBar.isHidden = true
        separatorView.isHidden = true
        detailsView.onBack = { [unowned self] in
            self.locationsStore.select(nil)
            self.hideCarDetails()
        }
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: true)
    }
    
    private func hideCarDetails(){
        guard detailsView.superview != nil else {return}
        let transition = CATransition()
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        containerView.layer.add(transition, forKey: nil)
        detailsView.removeFromSuperview()
        carsListTableView.isHidden = false
        searchBar.isHidden = false
        separatorView.isHidden = false
    }
    
}

// MARK: - SearchBar delegate

extension CarsListViewController: UISearchBarDelegate{
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        pulleyViewController?.setDrawerPosition(position: .open, animated: true)
        bindToFilteredList()
        searchBar.rx.text
            .throttle(1, scheduler: MainScheduler.instance)
            .subscribe(onNext: { (keyword) in
            if let keyword = keyword{
                self.locationsStore.filterMarks(with: keyword)
            }
        }).disposed(by: disposeBag)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.view.endEditing(true)
        pulleyViewController?.setDrawerPosition(position: .collapsed, animated: true)
        bindToCarsFullList()
    }
    
}
