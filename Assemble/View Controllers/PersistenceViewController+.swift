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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        else { return .init() }
        
        guard let count   = Assemble.core.commander?.userPresets.count,
              let presets = Assemble.core.commander?.userPresets,
                  indexPath.row < count else { return cell }

        let preset = presets[indexPath.row]
        let isCurrentPreset = indexPath.row == Assemble.core.commander?.selectedPreset
        cell.songName.text = "\(preset.name)"
        cell.songName.textColor = isCurrentPreset ? .darkText : UIColor.init(named: "Foreground")
        cell.songName.backgroundColor = isCurrentPreset ? .offWhite : UIColor.mutedOrange

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { print("[PersistenceViewController] Delegate is nil"); return }
        guard let count   = Assemble.core.commander?.userPresets.count,
                  indexPath.row < count else { return }

        delegate.loadState(indexPath.row)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        guard let count   = Assemble.core.commander?.userPresets.count,
              let presets = Assemble.core.commander?.userPresets,
              editingStyle == .delete, indexPath.row < count else { return }
        
        let preset = presets[indexPath.row]

        Assemble.core.commander?.deletePreset(preset)
    
        DispatchQueue.main.async {
            var tries = 0
            while Assemble.core.commander?.userPresets.count == count, tries < 10 {
                Thread.sleep(forTimeInterval: 0.05)
                tries = tries + 1
            }
            
            tableView.reloadData()
            if preset == Assemble.core.commander?.currentPreset {
                self.delegate?.beginNewSong()
            }
        }
    }

}
