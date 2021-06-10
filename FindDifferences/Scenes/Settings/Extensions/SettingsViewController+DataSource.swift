//
//  SettingsViewController+DataSource.swift
//  FindDifferences
//
//  Created by Nikolay Chepizhenko on 30.05.2021.
//

import UIKit

extension SettingsViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let type = dataSource[indexPath.section][indexPath.row]
        switch type {
        case .switch:
            return switchCell(type: type, indexPath: indexPath, tableView: tableView)

        case .text:
            return cell(with: type, indexPath: indexPath, tableView: tableView)
        }
    }

    private func cell(with cellType: CellType,
                      indexPath: IndexPath,
                      tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsCell.identifier, for: indexPath) as! SettingsCell
        let rowsCount = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        let isLast = (rowsCount - 1) == indexPath.row
        cell.configure(with: cellType, delegate: self, isLast: isLast)
        cell.selectedBackgroundView = UIView()
        return cell
    }

    private func switchCell(type: CellType,
                            indexPath: IndexPath,
                            tableView: UITableView) -> UITableViewCell {
        let cell = cell(with: type, indexPath: indexPath, tableView: tableView) as! SettingsCell
        if case let .switch(_, value, _) = type {
            cell.configureSwitch(with: value)
        }
        return cell
    }
}
