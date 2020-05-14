//  Assemble
//  Created by David Spry on 14/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

protocol ParameterMenu {
    
    var sections: Int { get }
    
    func itemsInSection(_ section: Int) -> Int
    
    func labelFor(_ path: IndexPath) -> String
    
    func parameterFor(_ path: IndexPath) -> (address: Int32, type: ParameterLabelScale)
    
    func headerFor(table: UITableView, path: IndexPath) -> UITableViewCell
}
