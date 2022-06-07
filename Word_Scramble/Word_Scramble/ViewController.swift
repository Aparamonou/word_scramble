//
//  ViewController.swift
//  Word_Scramble
//
//  Created by Alex Paramonov on 7.03.22.
//

import UIKit

class ViewController: UITableViewController {
     
     var allWords = [String]()
     var usedWords = [String]()
     var defaults = UserDefaults.standard
     
     override func viewDidLoad() {
          super.viewDidLoad()
          getArrayWords()
          setRightButtonItem()
          setLeftBarItem()
          navigationController?.navigationBar.prefersLargeTitles = true
         print("Hello")
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          guard let word = defaults.object(forKey: "word") as? String else {
               startGame()
               return
          }
          
          guard let arrayWords = defaults.object(forKey: "arrayWords") as? [String] else {
               startGame()
               return
          }
          
          title = word
          usedWords = arrayWords
     }
     
     override func viewDidDisappear(_ animated: Bool) {
          let value = title
          defaults.set(usedWords, forKey: "arrayWords")
          defaults.set(value, forKey: "word")
     }
     
     private func getArrayWords() {
          if let startWordUrl = Bundle.main.url(forResource: "start", withExtension: "txt") {
               if let startWordUrl = try? String(contentsOf: startWordUrl) {
                    allWords = startWordUrl.components(separatedBy: "\n")
               }
          }
          if allWords.isEmpty {
               allWords = ["silkworm"]
          }
     }
     
     private func startGame() {
          title = allWords.randomElement()
          usedWords.removeAll(keepingCapacity: true)
          tableView.reloadData()
     }
     
     private func setRightButtonItem() {
          navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
     }
     
     private func setLeftBarItem() {
          navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(reloadGame))
     }
     
     
     private func submit(_ answer: String) {
          let lowerAnswer = answer.lowercased()
          
          if isPossible(word: lowerAnswer) {
               if isOriginal(word: lowerAnswer) {
                    if isReal(word: lowerAnswer){
                         usedWords.insert(answer, at: 0)
                         
                         let indexPath = IndexPath(row: 0, section: 0)
                         tableView.insertRows(at: [indexPath], with: .automatic)
                         return
                    } else {
                         showErrorMessage(message: "You can't just make them up, you know!", title: "Word not recognised")
                    }
               } else {
                    showErrorMessage(message: "Be more original!", title: "Word used already")
               }
          } else {
               guard let title = title?.lowercased() else {return}
               showErrorMessage(message: "You can't spell that word from \(title)", title: "Word not possible")
          }
     }
     
     private func isOriginal(word: String) -> Bool {
          return !usedWords.contains(word)
     }
     
     private func isPossible(word: String) -> Bool {
          
          guard var tempWord = title?.lowercased() else {return false}
          for letter in word {
               if let position = tempWord.firstIndex(of: letter) {
                    tempWord.remove(at: position)
               } else {
                    return false
               }
          }
          return true
     }
     
     private func isReal(word: String) -> Bool {
          
          guard let gameWord = title?.lowercased() else {return false}
          if word.count >= 3  || word == gameWord || word == "" {
               return false
          } else {
               let checker = UITextChecker()
               let range = NSRange(location: 0, length: word.utf16.count)
               let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
               return misspelledRange.location == NSNotFound
          }
          
          
     }
     
     private func showErrorMessage(message errorMessage: String, title errorTitle: String) {
          
          let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
          alertController.addAction(UIAlertAction(title: "Ok", style: .default))
          present(alertController, animated: true)
     }
     
     @objc func promptForAnswer() {
          let alertController = UIAlertController(title: "Enter Answer", message: nil, preferredStyle: .alert)
          alertController.addTextField()
          
          let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self, weak alertController] action in
               guard let answer = alertController?.textFields?[0].text else { return  }
               self?.submit(answer)
          }
          alertController.addAction(submitAction)
          present(alertController, animated: true)
     }
     
     @objc func reloadGame() {
          usedWords.removeAll()
          startGame()
     }
     
     
     
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          usedWords.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
          cell.textLabel?.text = usedWords[indexPath.row]
          return cell
     }
}

