//
//  ViewController.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/12/2021.
//

import UIKit
import Combine

class ProgramViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noResultLabel: UILabel!
    @IBOutlet weak var searchSuggestionLabel: UILabel!
    
    private var selectedIndex = 0
    var search = ""
    
    var subscriptions: Set<AnyCancellable> = []
    @Published var searchKey = ""
    
    let viewModel = ProgramViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setBindings()
        setSearchBar()
        setLabels()
        setCollectionView()
    }
}

extension ProgramViewController {
    // C'est ici que la programmation réactive se met en place
    private func setBindings() {
        $searchKey.receive(on: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] searchValue in
                print(searchValue)
                self?.viewModel.searchQuery = searchValue
        }.store(in: &subscriptions)
        
        viewModel.error.sink { [weak self] message in
            if message == "Contenu vide" {
                self?.noResultLabel.isHidden = true
                self?.searchSuggestionLabel.isHidden = true
            } else {
                self?.noResultLabel.isHidden = false
                self?.searchSuggestionLabel.isHidden = false
                self?.noResultLabel.text = message
            }
        }.store(in: &subscriptions)
        
        viewModel.updated
            .receive(on: RunLoop.main)
            .sink { [weak self] updated in
                if updated {
                    self?.updateCollectionView()
                } else {
                    self?.collectionView.isHidden = true
                }
            }.store(in: &subscriptions)
    }
    
    private func setLabels() {
        self.noResultLabel.isHidden = true
        self.searchSuggestionLabel.isHidden = true
    }
    
    private func setSearchBar() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Annuler"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .label
        searchBar.backgroundImage = UIImage() // Supprimer le fond par défaut
        searchBar.showsCancelButton = false
        searchBar.delegate = self
    }
    
    private func setCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayoutDifferentSection()
    }
    
    private func updateCollectionView() {
        collectionView.reloadData()
        collectionView.isHidden = false
    }
}

extension ProgramViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.searchBar.setShowsCancelButton(true, animated: true) // Afficher le bouton d'annulation
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchKey = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchKey = ""
        self.searchBar.text = ""
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Masquer le clavier et stopper l'édition du texte
        self.searchBar.setShowsCancelButton(false, animated: true) // Masquer le bouton d'annulation
    }
}

extension ProgramViewController: UICollectionViewDataSource {
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

extension ProgramViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        guard let viewController = storyboard?.instantiateViewController(withIdentifier: "programDetailViewController") as? ProgramDetailViewController else {
            print("Erreur instanciation vue.")
            return
        }
        
        // Injection de dépendance, on exploite le contenu du programme sélectionné, stockée dans la vue modèle associée à la cellule du CollectionView.
        viewController.prepareView(with: viewModel.programCellViewModels[indexPath.row])
        viewController.modalPresentationStyle = .fullScreen
        present(viewController, animated: true, completion: nil)
    }
}

// Ces 2 méthodes adoptant le protocole UICollectionViewDelegateFlowLayout permettent l'affiche du CollectionView sous forme de grille à 2 colonnes, adapté à tout format d'écran.
// Source: https://morioh.com/p/e468fe7e7488
extension ProgramViewController: UICollectionViewDelegateFlowLayout {
    private func createLayout() -> UICollectionViewLayout {
        // iOS 13 requis
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(CGFloat(10))
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    func createLayoutDifferentSection() -> UICollectionViewLayout {
        // iOS 13 requis
        let layout = UICollectionViewCompositionalLayout { (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
            var columns = 1
            switch sectionIndex{
            case 1:
                columns = 2
            case 2:
                columns = 5
            default:
                columns = 2
                
            }
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
            let groupHeight = columns == 1 ? NSCollectionLayoutDimension.absolute(44) : NSCollectionLayoutDimension.fractionalWidth(0.47)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: groupHeight)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: columns)
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 10, bottom: 20, trailing: 10)
            return section
        }
        
        return layout
    }
}
