//
//  ProgramCollectionViewCell.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/12/2021.
//

import UIKit
import Kingfisher

final class ProgramCollectionViewCell: UICollectionViewCell {
    // L'image au format small est initialement de taille 415x233, ratio: 415/233
    @IBOutlet weak var programImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    private var viewModel: ProgramCellViewModel!
    
    func configure(with viewModel: ProgramCellViewModel) {
        self.viewModel = viewModel
        setView()
    }
    
    func setView() {
        self.titleLabel.text = viewModel.title
        self.subtitleLabel.text = viewModel.subtitle
        self.programImage.image = nil
        
        guard let imageURL = URL(string: viewModel.imageURL) else {
            // print("-> ERREUR: URL de l'image indisponible")
            self.programImage.image = UIImage(named: "ArticleImageNotAvailable")
            return
        }
        
        // Avec Kingfisher, c'est asynchrone, rapide et efficace. Le cache est géré automatiquement.
        let defaultImage = UIImage(named: "OCSImageNotAvailableSmall")
        let resource = ImageResource(downloadURL: imageURL)
        programImage.kf.indicatorType = .activity // Indicateur pendant le téléchargement
        programImage.kf.setImage(with: resource, placeholder: defaultImage)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset Thumbnail Image View
        programImage.image = nil
    }
}
