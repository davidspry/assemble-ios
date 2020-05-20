//  Assemble
//  Created by David Spry on 21/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension PersistenceViewController : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presets = Assemble.core.commander?.userPresets else { return 0 }
        return    presets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath)
        
        guard let count   = Assemble.core.commander?.userPresets.count,
              let presets = Assemble.core.commander?.userPresets else { return cell }

        let preset = presets[indexPath.row]
        cell.textLabel?.text = "\(preset.name)"
        
        
//        if let label = cell.parameter {
//            let parameter = menu.parameterFor(indexPath)
//            label.initialise(with: parameter.address,
//                             increment: parameter.increment,
//                             and: parameter.type)
//        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { return }
        guard let count   = Assemble.core.commander?.userPresets.count,
              let presets = Assemble.core.commander?.userPresets else { return }

        delegate.loadState(indexPath.row)
    }
    
    
}
