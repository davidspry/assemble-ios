//  Assemble
//  Created by David Spry on 21/5/20.
//  Copyright © 2020 David Spry. All rights reserved.

import UIKit

extension PersistenceViewController : UITableViewDelegate, UITableViewDataSource {
    
    private func noSavedSongsCell(from cell: SongCell) -> SongCell {
        cell.songName.text = "There are no saved sequences."
        cell.songName.textColor = UIColor.init(named: "BackgroundLight")
        cell.songName.backgroundColor = UIColor.init(named: "Foreground")
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let presets = Assemble.core.commander?.songs,
                !(presets.isEmpty) else { return 1 }
        return    presets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "songCell", for: indexPath) as? SongCell
        else { return .init() }
        
        guard let count   = Assemble.core.commander?.songs.count,
              let presets = Assemble.core.commander?.songs,
              (count == 0 || indexPath.row < count) else { return cell }

        if  presets.isEmpty { return noSavedSongsCell(from: cell) }
        let preset = presets[indexPath.row]
        let isCurrentPreset = indexPath.row == Assemble.core.commander?.selectedPreset
        cell.songName.text = "\(preset.name)"
        cell.songName.textColor = isCurrentPreset ? .darkText : UIColor.init(named: "Foreground")
        cell.songName.backgroundColor = isCurrentPreset ? .offWhite : UIColor.mutedOrange

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = delegate else { print("[PersistenceViewController] Delegate is nil"); return }
        guard let count = Assemble.core.commander?.songs.count,
                  count > 0, indexPath.row < count else { return }

        delegate.loadState(indexPath.row)
        dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let presets = Assemble.core.commander?.songs,
                  presets.count > 0 else { return nil }

        let delete = UIContextualAction(style: .destructive, title: "Delete") { action, view, didComplete in
            let result = self.deleteRow(from: tableView, at: indexPath)
            didComplete(result)
        }

        let foreground = UIColor.darkGray
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        delete.image = UIImage(systemName: "trash", withConfiguration: configuration)?.coloured(in: foreground)
        delete.backgroundColor = UIColor.init(named: "BackgroundLight") ?? .clear
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    /// Delete the preset represented at the given `IndexPath` and update the table and the sequencer as appropriate to reflect the change.

    private func deleteRow(from table: UITableView, at path: IndexPath) -> Bool {
        guard let count   = Assemble.core.commander?.songs.count,
              let presets = Assemble.core.commander?.songs,
                !(presets.isEmpty), path.row < count else { return false }
            
        let preset = presets[path.row]

        guard let result = Assemble.core.commander?.deletePreset(preset) else { return false }

        DispatchQueue.main.async {
            var tries = 0
            while Assemble.core.commander?.songs.count == count, tries < 25 {
                Thread.sleep(forTimeInterval: 0.05)
                tries = tries + 1
            }

            /// If the currently selected song was deleted, then begin a new song.
            /// If the deleted preset is listed above the selected preset in the table, then decrement the selected preset index.

            if let selectedPreset = Assemble.core.commander?.selectedPreset {
                if selectedPreset == path.row { self.delegate?.beginNewSong() }
                else if selectedPreset > path.row {
                    Assemble.core.commander?.selectedPreset = selectedPreset - 1
                }
            }

            table.reloadData()
        }

        return result
    }

}
