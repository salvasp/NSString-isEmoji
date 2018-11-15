//
//  ViewController.swift
//  NSString-isEmoji
//
//  Created by Salvatore Petrazzuolo on 11/11/2018.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var supportedEmojisTable: UITableView!
    @IBOutlet weak var unsupportedEmojisTable: UITableView!
    
    
    let emojis: [String] = try! PropertyListSerialization
        .propertyList(from: Data(contentsOf: Bundle.main.url(forResource: "Emojis_iOS12.1", withExtension: "plist")!), format: nil) as! [String]
    
    var supportedEmojis: [String] = []
    var unsupportedEmojis: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadEmojis()
    }
    
    
    func loadEmojis(){
        for emoji in emojis {
            DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {[weak self] in
                let (currentEmoji, isEmoji) = (emoji, (emoji as NSString).isEmoji())
                DispatchQueue.main.async {
                    guard let strongSelf = self else { return }
                    if isEmoji {
                        strongSelf.supportedEmojis.append(currentEmoji)
                        strongSelf.supportedEmojisTable.reloadData()
                    } else {
                        strongSelf.unsupportedEmojis.append(currentEmoji)
                        strongSelf.unsupportedEmojisTable.reloadData()
                    }
                }
            }
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView {
        case supportedEmojisTable:
            return "SUPPORTED \(supportedEmojis.count)"
        case unsupportedEmojisTable:
            return "NOT SUPPORTED \(unsupportedEmojis.count)"
        default:
            return nil
        }
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let view = view as? UITableViewHeaderFooterView else { return }
        view.contentView.backgroundColor = tableView == supportedEmojisTable ? .green : .red
        view.textLabel?.textAlignment = .center
        view.textLabel?.adjustsFontSizeToFitWidth = true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case supportedEmojisTable:
            return supportedEmojis.count
        case unsupportedEmojisTable:
            return unsupportedEmojis.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "emojiCell")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "emojiCell")
        }
        cell?.selectionStyle = .default
        cell?.backgroundColor = .clear
        cell?.textLabel?.textAlignment = .center
        cell?.selectionStyle = .none

        return cell!
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch tableView {
        case supportedEmojisTable:
            cell.textLabel?.text = supportedEmojis[indexPath.row]
        case unsupportedEmojisTable:
            cell.textLabel?.text = unsupportedEmojis[indexPath.row]
        default:
            break
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch tableView {
        case supportedEmojisTable:
            print("\((tableView.cellForRow(at: indexPath))!.textLabel!.text!) - \(supportedEmojis[indexPath.row])")
        case unsupportedEmojisTable:
            print("\((tableView.cellForRow(at: indexPath))!.textLabel!.text!) - \(unsupportedEmojis[indexPath.row])")
        default:
            break
        }
    }
    
}

