//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

/// A menu of parameters representing an audio effect.

protocol ParameterMenu {
    
    /// The name to be associated with the menu

    var name: String { get }
    
    /// The address of a toggle parameter for the menu if one exists

    var toggle: Int32? { get }
    
    /// The number of sections in the menu

    var sections: Int { get }
    
    /// The number of items in the given section
    /// - Parameter section: A zero-based section index

    func itemsInSection(_ section: Int) -> Int
    
    /// The label to be used for the item at the given index.
    /// - Parameter path: The index of the item whose label is being requested

    func labelFor(_ path: IndexPath) -> String
    
    /// The parameter to be used with the item at the given index
    /// - Parameter path: The index of the item whose parameter is being requested
    /// - Returns: A tuple describing a parameter: a hexadecimal address, an increment amount, and a `ParameterLabelScale`.

    func parameterFor(_ path: IndexPath) -> (address: Int32, increment: Float, type: ParameterLabelScale)
    
    /// The header cell to be used for the given index path.
    /// - Parameter table: The table who should dequeue the cell.
    /// - Parameter path: The index of the header cell

    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell
}
