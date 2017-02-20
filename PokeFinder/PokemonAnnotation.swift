//
//  PokemonAnnotation.swift
//  PokeFinder
//
//  Created by Blake Fischer on 2/20/17.
//  Copyright © 2017 Blake Fischer. All rights reserved.
//

import Foundation

let pokemonDict = [
    1:"arbok",
    2:"ekans",
    3:"charizard",
    4:"squirtle",
    5:"pikachu",
    6:"ditto",
    7:"mew"]


class PokemonAnnotation: NSObject, MKAnnotation {
    var coordinate = CLLocationCoordinate2D()
    var pokemonId: Int
    var pokemonName: String
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, pokemonId: Int) {
        self.coordinate = coordinate
        self.pokemonId = pokemonId
        self.pokemonName = pokemonDict[pokemonId]!.capitalized
        self.title = pokemonName
    }
}
