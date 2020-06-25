//  Assemble
//  Created by David Spry on 13/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension ParametersViewController : UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        switch (tableView)
        {
        case tableOscillators: return menuOscillators.sections
        case tableDelay:       return menuDelay.sections
        case tableVibrato:     return menuVibrato.sections
        default:               fatalError()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch (tableView)
        {
        case tableOscillators: return menuOscillators.itemsInSection(section)
        case tableDelay:       return menuDelay.itemsInSection(section)
        case tableVibrato:     return menuVibrato.itemsInSection(section)
        default:               fatalError()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 { return headerForMenu(table: tableView, at: indexPath) }

        let cell = tableDelay.dequeueReusableCell(withIdentifier: "parameterCell", for: indexPath) as! ParameterCell
        var menu: ParameterMenu

        switch (tableView)
        {
        case tableOscillators: menu = menuOscillators; break
        case tableDelay:       menu = menuDelay;       break
        case tableVibrato:     menu = menuVibrato;     break
        default: fatalError("[ParametersViewController] Unknown UITableView instance")
        }

        cell.title.text = menu.labelFor(indexPath)
        if let label = cell.parameter {
            let parameter = menu.parameterFor(indexPath)
            label.initialise(with: parameter.address,
                             increment: parameter.increment,
                             and: parameter.type)
        }

        return cell
    }
    
    private func headerForMenu(table: UITableView, at path: IndexPath) -> UITableViewCell {
        switch (table)
        {
        case tableOscillators:
            let cell = menuOscillators.headerFor(table: table, path: path)
            if let cell = cell as? OscillatorsHeaderCell {
                cell.selector.addTarget(self, action: #selector(didSelectOscillator), for: .valueChanged)
                return cell
            }

            else { preconditionFailure("[ParametersViewController+] Cast to OscillatorsHeaderCell failed") }

        case tableDelay:
            let cell = menuDelay.headerFor(table: table, path: path)
            if let cell = cell as? MenuHeaderCell {
                cell.toggle.tag = 0x1
                cell.title.text = menuDelay.name
                cell.initialise(with: kStereoDelayToggle)
                cell.toggle.addTarget(self, action: #selector(didToggle(_:)), for: .touchUpInside)
                return cell
            }
            
            else { preconditionFailure("[ParametersViewController+] 1. Cast to MenuHeaderCell failed") }
            
        case tableVibrato:
            let cell = menuVibrato.headerFor(table: tableDelay, path: path)
            if let cell = cell as? MenuHeaderCell {
                cell.toggle.tag = 0x2
                cell.title.text = menuVibrato.name
                cell.initialise(with: kVibratoToggle)
                cell.toggle.addTarget(self, action: #selector(didToggle(_:)), for: .touchUpInside)
                return cell
            }
            
            else { preconditionFailure("[ParametersViewController+] 2. Cast to MenuHeaderCell failed") }
    
        default: preconditionFailure("[ParametersViewController] Unknown UITableView instance.")
        }
    }

}
