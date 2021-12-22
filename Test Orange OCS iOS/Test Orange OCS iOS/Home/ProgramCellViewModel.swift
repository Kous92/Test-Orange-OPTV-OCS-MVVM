//
//  ProgramCellViewModel.swift
//  Test Orange OCS iOS
//
//  Created by Koussaïla Ben Mamar on 20/12/2021.
//

import Foundation
import Combine

class ProgramCellViewModel {
    public private(set) var title: String
    public private(set) var subtitle: String
    public private(set) var imageURL: String
    public private(set) var fullScreenImageURL: String
    public private(set) var detaillink: String
    
    /*
     -> Concernant l'URL de l'image, il y a un problème, si on commence par le nom de domaine https://api.ocs.fr suivi de /data_plateforme/program/..., le code 503 sera retourné.
     -> La solution est d'utiliser le nom de domaine https://statics.ocs.fr à la place pour obtenir les images.
     -> Les données de l'API sont réelles et sont celles de la version mise en production.
     */
    private let baseURL = "https://statics.ocs.fr"
    
    // Injection de dépendance
    init(with content: Content) {
        self.title = content.title?[0].value ?? "Titre inconnu"
        self.subtitle = content.subtitle ?? "Sous-titre inconnu"
        self.imageURL = baseURL + (content.imageurl ?? "")
        self.fullScreenImageURL = baseURL + (content.fullscreenimageurl ?? "")
        self.detaillink = content.detaillink ?? ""
    }
    
    // Injection de dépendance
    func configure(with content: Content) {
        self.title = content.title?[0].value ?? "Titre inconnu"
        self.subtitle = content.subtitle ?? "Sous-titre inconnu"
        self.imageURL = baseURL + (content.imageurl ?? "")
        self.fullScreenImageURL = baseURL + (content.fullscreenimageurl ?? "")
        self.detaillink = content.detaillink ?? ""
    }
}
