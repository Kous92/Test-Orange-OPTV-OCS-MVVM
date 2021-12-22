//
//  ProgramViewModel.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/12/2021.
//

import Foundation
import Combine
import UIKit

class ProgramViewModel {
    var sut = false // Si c'est par le biais d'un test ou non. SUT: System Under Test
    var cancellables = Set<AnyCancellable>()
    private let apiService: APIService?
    
    @Published var searchQuery = ""
    var error = CurrentValueSubject<String?, Never>(nil)
    var updated = CurrentValueSubject<Bool, Never>(false)
    var isLoading = PassthroughSubject<Bool, Never>()
    
    // C'est cette vue modèle qui a un contact avec le modèle. La vue ne doit pas connaître le modèle.
    private var programsData: Programs?
    
    // Chaque cellule a sa vue modèle, la vue ne doit rien savoir du modèle.
    var programCellViewModels = [ProgramCellViewModel]()
    
    // Injection de dépendance de l'objet qui gère l'appel de l'API
    init(apiService: APIService = OCSAPIService(), sut: Bool = false) {
        self.apiService = apiService
        self.sut = sut
        setBindings()
    }
    
    private func setBindings() {
        // Un puissant élément de la programmation réactive avec debounce, la recherche ne se déclenche qu'après une temporisation de 0,5 secondes. De plus, ça rend l'interface fluide et dynamique lorsque l'utilisateur recherche son contenu avec une actualisation automatique en temps réel.
        $searchQuery.receive(on: RunLoop.main)
            .removeDuplicates()
            .debounce(for: .seconds(0.8), scheduler: RunLoop.main)
            .filter { !$0.isEmpty }
            .sink { [weak self] _ in
                self?.fetchOCSPrograms()
            }.store(in: &cancellables)
    }
    
    func fetchOCSPrograms() {
        guard !self.searchQuery.isEmpty && self.searchQuery.count > 1 else {
            self.error.send("Contenu vide")
            return
        }
        
        apiService?.fetchPrograms(query: searchQuery, completion: { [weak self] result in
            self?.programCellViewModels.removeAll()
            
            switch result {
            case .success(let data):
                self?.programsData = data
                self?.parseData()
            case .failure(let error):
                print(error.rawValue)
                self?.error.send(error.rawValue)
            }
        })
    }
    
    private func parseData() {
        guard let contents = programsData?.contents else {
            self.error.send("Aucun résultat pour \"\(self.searchQuery)\"")
            // self.updated.send(false)
            return
        }

        programCellViewModels.removeAll()
        programCellViewModels = contents.compactMap { ProgramCellViewModel(with: $0) }
        print("Succès: \(contents.count) programmes obtenus.")
        print("Cellules: \(self.programCellViewModels.count)")
        self.updated.send(true)
    }
}
