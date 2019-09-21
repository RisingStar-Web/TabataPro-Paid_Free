//
//  TableViewController.swift
//  TabataPro
//
//  Created by Роман Кабиров on 10.06.2018.
//  Copyright © 2018 Logical Mind. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    private var selectedPath: IndexPath?
    private var picker: UIPickerView?
    @IBOutlet weak var labelRoundsCount: UILabel!
    @IBOutlet weak var labelCyclesCount: UILabel!
    @IBOutlet weak var labelPrepareSec: UILabel!
    @IBOutlet weak var labelWorkSec: UILabel!
    @IBOutlet weak var labelRestSec: UILabel!
    
    var roundsCount = 8
    var cyclesCount = 1
    var timePrepare = 10
    var timeWork = 20
    var timeRest = 10
    
    private var showSeconds = false
    private var selectedRowIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let u = UserDefaults.standard
        if let i = u.value(forKey: "roundsCount") as? Int {
            roundsCount = i
        }
        if let i = u.value(forKey: "cyclesCount") as? Int {
            cyclesCount = i
        }
        if let i = u.value(forKey: "timePrepare") as? Int {
            timePrepare = i
        }
        if let i = u.value(forKey: "timeWork") as? Int {
            timeWork = i
        }
        if let i = u.value(forKey: "timeRest") as? Int {
            timeRest = i
        }
        
        updateLabels()
    }
    
    func saveDefaults() {
        UserDefaults.standard.set(roundsCount, forKey: "roundsCount")
        UserDefaults.standard.set(cyclesCount, forKey: "cyclesCount")
        UserDefaults.standard.set(timePrepare, forKey: "timePrepare")
        UserDefaults.standard.set(timeWork, forKey: "timeWork")
        UserDefaults.standard.set(timeRest, forKey: "timeRest")
    }
    
    func updateLabels() {
        labelRoundsCount.text = String(roundsCount)
        labelCyclesCount.text = String(cyclesCount)
        labelPrepareSec.text = String(timePrepare)
        labelWorkSec.text = String(timeWork)
        labelRestSec.text = String(timeRest)
    }

    func getComponentValue(by index: Int) -> Int {
        switch index {
        case 0: return roundsCount
        case 1: return cyclesCount
        case 2: return timePrepare
        case 3: return timeWork
        case 4: return timeRest
        default: return 0
        }
    }

    func setComponentValue(index: Int, value: Int) {
        switch index {
        case 0: roundsCount = value
        case 1: cyclesCount = value
        case 2: timePrepare = value
        case 3: timeWork = value
        case 4: timeRest = value
        default:
            return
        }
    }

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return 3
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedPath == indexPath {
            tableView.beginUpdates()
            tableView.deselectRow(at: indexPath, animated: true)
            selectedPath = nil
            tableView.reloadData()
            tableView.endUpdates()
            return
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedPath = indexPath
        let selectedCell: UITableViewCell = tableView.cellForRow(at: indexPath)!
        selectedCell.contentView.backgroundColor = .clear

        picker?.removeFromSuperview()
        picker = UIPickerView(frame: CGRect(x: 50, y: 50, width: tableView.frame.width - 100, height: 150))
        showSeconds = indexPath.section > 0
        picker?.dataSource = self
        picker?.delegate = self
        
        // picker?.backgroundColor = .red
        
        selectedRowIndex = (indexPath.section * 2) + indexPath.row
        picker?.selectRow(getComponentValue(by: selectedRowIndex) - 1, inComponent: 0, animated: true)

        tableView.beginUpdates()
        selectedCell.addSubview(picker!)
        tableView.reloadData()
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let selected = selectedPath {
            if selected == indexPath {
                return 180.0
            } else {
                return 64.0
            }
            
        } else {
            return 64.0
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TableViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 300
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if !showSeconds {
            return "\(row + 1)"
        }
        let sec = row + 1
        if sec < 60 {
            return "\(sec) " + "sec".localized
        } else {
            let min = Int(sec / 60)
            let secCount = sec % 60
            if secCount > 0 {
                return "\(min) " + "min".localized + " \(sec % 60) " + "sec".localized
            } else {
                return "\(min) " + "min".localized
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        setComponentValue(index: selectedRowIndex, value: row + 1)
        updateLabels()
    }
}
