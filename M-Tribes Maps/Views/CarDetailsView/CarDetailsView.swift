//
//  CarDetailsView.swift
//  M-Tribes Maps
//
//  Created by Michael Attia on 8/14/18.
//  Copyright © 2018 Mike Attia. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CarDetailsView: UIView {

    // MARK: - Constants
    let nibFileName = String(describing: CarDetailsView.self)
    
    // MARK: - View Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backContainer: UIView!{
        didSet{
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goBackToList))
            backContainer.addGestureRecognizer(tapGesture)
        }
    }
    @IBOutlet weak var backLabel: UILabel!
    @IBOutlet weak var backArrow: UIImageView!{
        didSet{
            backArrow.image = backArrow.image?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    // Car info
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var engineTypeLabel: UILabel!
    @IBOutlet weak var fuelLabel: UILabel!
    @IBOutlet weak var internalStatusLabel: TagLabel!
    @IBOutlet weak var externalStatusLabel: TagLabel!
    @IBOutlet weak var vinLabel: UILabel!
    
    var onBack: (()->())?
    
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView(){
        Bundle.main.loadNibNamed(nibFileName, owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
    
    // MARK: - View configurations
    
    @objc private func goBackToList(){
        onBack?()
    }
    
    func configureCell(with placemark: Placemark){
        nameLabel.text = placemark.name
        addressLabel.text = placemark.address
        engineTypeLabel.text = placemark.engineType?.uppercased()
        fuelLabel.text = String(placemark.fuel ?? 0)
        vinLabel.text = placemark.vin
        
        switch placemark.interior{
        case .good?:
            internalStatusLabel.text = placemark.interior?.rawValue.uppercased()
            internalStatusLabel.set(backgroundColor: .green, textColor: .white)
        case .unacceptable?:
            internalStatusLabel.text = placemark.interior?.rawValue.uppercased()
            internalStatusLabel.set(backgroundColor: .red, textColor: .white)
        default:
            internalStatusLabel.text = nil
        }
        
        switch placemark.exterior {
        case .good?:
            externalStatusLabel.text = placemark.exterior?.rawValue.uppercased()
            externalStatusLabel.set(backgroundColor: .green, textColor: .white)
        case .unacceptable?:
            externalStatusLabel.text = placemark.exterior?.rawValue.uppercased()
            externalStatusLabel.set(backgroundColor: .red, textColor: .white)
        default:
            externalStatusLabel.text = nil
        }
    }

}
