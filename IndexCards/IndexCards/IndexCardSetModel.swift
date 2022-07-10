//
//  IndexCardSetModel.swift
//  IndexCards
//
//  Created by Yannick Opp on 07.04.22.
//

import Foundation
import CoreData

class IndexCardSetModel: ObservableObject {
    @Published var indexCardSets: [IndexCardSet]
    private let persistence = PersistenceController.shared
    
    init() {
        indexCardSets = []
        loadData()
    }
    
    func loadData() {
        let request = NSFetchRequest<IndexCardSet>(entityName: "IndexCardSet")
        do {
            indexCardSets = try persistence.container.viewContext.fetch(request)
            //TODO: Sort results by name
        } catch {
            //TODO: Error Handling
        }
    }
    
    func saveSets() {
        persistence.saveData()
        loadData()
    }
    
    func deleteSet(_ icSet: IndexCardSet) {
        persistence.container.viewContext.delete(icSet)
        saveSets()
    }
    
    func createSet(title: String) -> IndexCardSet {
        let newSet = IndexCardSet(context: persistence.container.viewContext)
        newSet.title = title
        newSet.id = UUID()
        return newSet
    }
    
    func getSetByID(id: UUID) -> IndexCardSet? {
        return indexCardSets.first(where: {$0.id == id})
    }
}

extension IndexCardSet {
    
    var cardsAsArray: [IndexCard] {
        get {
            if let cardArray =  cards?.array as? [IndexCard] {
                return cardArray
            } else {
                return []
            }
        }
    }
}
