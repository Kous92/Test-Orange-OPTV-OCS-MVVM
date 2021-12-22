//
//  ProgramDataSource.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/12/2021.
//

import Foundation
import UIKit

final class ProgramDataSource: NSObject, UICollectionViewDataSource {
    
    private var viewModel: ProgramViewModel
    
    init(viewModel: ProgramViewModel) {
        self.viewModel = viewModel
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.programCellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "programCell", for: indexPath) as? ProgramCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModel.programCellViewModels[indexPath.row])
        return cell
    }
}
