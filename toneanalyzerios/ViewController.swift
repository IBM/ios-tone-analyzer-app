/**
 * Copyright IBM Corporation 2018
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import ToneAnalyzerV3
import SwiftSpinner
import KTCenterFlowLayout
import BMSCore







class ViewController: UIViewController {

    // UICollectionViews containing tags
    @IBOutlet weak var emotionsCollectionView: UICollectionView!
    @IBOutlet weak var languageStyleCollectionView: UICollectionView!
    @IBOutlet weak var socialTendenciesCollectionView: UICollectionView!

    // UIButton that will call Watson Tone Analyzer
    @IBOutlet weak var analyzeToneButton: UIButton!

    // UITextView that will hold text to be analyzed
    @IBOutlet weak var toneInputText: UITextView!

    // ToneAnalyzer Object
    var toneAnalyzer: ToneAnalyzer?

    // Array of analyzedTones
    var analyzedCategoriesArray: [ToneCategory] = []

    

    override func viewDidLoad() {

        super.viewDidLoad()

        // Add a done button to the keyboard
        let toolbar = UIToolbar()
        let doneBtn = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneHandler))
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbar.sizeToFit()
        toolbar.items = [spacer, doneBtn]
        toneInputText.inputAccessoryView = toolbar

        // Setup collection views
        self.setupCollectionViews()

        // Configure tone analyzer sdk
        self.configureToneAnalyzer()

        // Register did become active observer
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)

        
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function called when analyzeToneButton pressed. Will make a call to analyze tone of input text
    @IBAction func analyzeToneButton(_ sender: AnyObject) {
        if !toneInputText.text.isEmpty {
            // Make a call to analyze the text if input is not empty
            self.analyzeTone(toneInputText.text)
        } else {
            // Show alert if textbox is empty
            self.showAlert(.error("Text was not provided"))
        }
    }

    @objc func didBecomeActive(_ notification: Notification) {
        
        
    }

    // Resign text view when complete
    @objc func doneHandler() {
        toneInputText.resignFirstResponder()
    }

    // Method to configure the Tone Analyzer SDK
    func configureToneAnalyzer() {

        // Set date string for version of Watson service to use
        let versionDate = "2017-09-20"

        // Create a configuration path for the BMSCredentials.plist file then read in the Watson credentials
        guard let configurationPath = Bundle.main.path(forResource: "BMSCredentials", ofType: "plist"),
              let configuration = NSDictionary(contentsOfFile: configurationPath) else {

            self.showAlert(.missingCredentials)
            return
        }

        // Set the Watson credentials for Tone Analyzer service from the BMSCredentials.plist
        // If using IAM authentication
        if let apikey = configuration["toneanalyzerApikey"] as? String,
           let url = configuration["toneanalyzerUrl"] as? String {

           // Initialize Tone Analyzer object
           toneAnalyzer = ToneAnalyzer(version: versionDate, apiKey: apikey)

           // Set the URL for the Assistant Service
           toneAnalyzer?.serviceURL = url

           // If using user/pwd authentication
       } else if let password = configuration["toneanalyzerPassword"] as? String,
           let username = configuration["toneanalyzerUsername"] as? String,
           let url = configuration["toneanalyzerUrl"] as? String {

           // Initialize Watson Assistant object
           toneAnalyzer = ToneAnalyzer(username: username, password: password, version: versionDate)

           // Set the URL for the Assistant Service
           toneAnalyzer?.serviceURL = url

       } else {
           showAlert(.invalidCredentials)
       }
    }

    // Method to configure the three collection views
    func setupCollectionViews() {
        // Create and initialize nib and TagCollectionViewCell
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TagCollectionViewCell", bundle: bundle)

        /// Configure and register collection views
        self.registerCollectionView(emotionsCollectionView, nib: nib)
        self.registerCollectionView(languageStyleCollectionView, nib: nib)
        self.registerCollectionView(socialTendenciesCollectionView, nib: nib)

    }

    // Method to register collection views
    func registerCollectionView(_ view: UICollectionView, nib: UINib) {
        // Set background color for collection views to clear
        view.backgroundColor = .clear

        // Setup the View Layour
        let layout = KTCenterFlowLayout()
        layout.minimumInteritemSpacing = 5.0
        layout.minimumLineSpacing = 5.0
        view.collectionViewLayout = layout

        view.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
    }

    // Method to analyze tone using the Watson Tone Analyzer
    func analyzeTone(_ textToAnalyze: String) {

        // Ensure tone analyzer has been instantiated
        guard let sdk = toneAnalyzer else {
            showAlert(.missingCredentials)
            return
        }

        SwiftSpinner.show("Watson is Analyzing Tone")

        // Use Watson Tone Analyzer to analyze input text. Call error function if failure
        let input = ToneInput(text: textToAnalyze)
        sdk.tone(toneContent: .toneInput(input)) { response, error in
            if let error = error {
                self.failToneAnalyzerWithError(error)
                return
            }

            guard let tones = response?.result else {
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                    self.showAlert(.failedToAnalyzeTone)
                }
                return
            }

            // Loop through sentence tones
            self.analyzedCategoriesArray = []
            guard let categories = tones.documentTone.toneCategories else {
                DispatchQueue.main.async {
                    SwiftSpinner.hide()
                    self.showAlert(.noData)
                }
                return
            }

            // Loop through document tones
            for documentTone in categories {
                // Set tone category parameters
                let toneCategoryId = documentTone.categoryID
                let toneCategoryName = documentTone.categoryName
                let tones = documentTone.tones
                // Create new tone category with information provided by document tone
                let newToneCategory = ToneCategory(toneCategoryId: toneCategoryId, toneCategoryName: toneCategoryName, tones: tones)
                // Add new tone category to array
                self.analyzedCategoriesArray.append(newToneCategory)
            }

            // Update the UI from the main thread
            DispatchQueue.main.async {
                // Reload each collection view with new data
                self.emotionsCollectionView.reloadData()
                self.languageStyleCollectionView.reloadData()
                self.socialTendenciesCollectionView.reloadData()

                SwiftSpinner.hide()
            }
        }
    }

    // Method handling errors returned by Tone Analyzer
    func failToneAnalyzerWithError(_ error: Error) {
        // Print the error to the console
        print(error)
        // Update the UI from the main thread
        DispatchQueue.main.async {
            // Hide the spinner
            SwiftSpinner.hide()
            let errorMsg = error.localizedDescription
            let error: AnalyzerError = errorMsg == "Not Authorized" ? .invalidCredentials : .error(errorMsg)
            // Present an alert to the user descirbing what the problem may be
            self.showAlert(error)
        }
    }

    // Method to show an alert with an alertTitle String and alertMessage String
    func showAlert(_ error: AnalyzerError) {
        // If an alert is not currently being displayed
        if self.presentedViewController == nil {
            // Set alert properties
            let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            // Show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
}

extension ViewController: UICollectionViewDataSource {

    // Method to handle the number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        if analyzedCategoriesArray.indices.contains(collectionView.tag) {
            // If the analyzed catagories array contains an object at the given index return the number of tones it contains
            return self.analyzedCategoriesArray[collectionView.tag].tones.count
        } else {
            // Otherwise return 0 since it does not contain any items
            return 0
        }
    }

    // Method to get the cell for item at index path in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell that will reference the TagCollectionViewCell that is created
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
        // Set the cell's tagLabel text to the watson result name. Using the collection views tag to choose the correct array location
        if analyzedCategoriesArray.indices.contains(collectionView.tag) {
            // Set the tag label text to the tone's name
            cell.tagLabel.text = self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].toneName
            // Create a scaled tone score based on the percentage retured by watson
            let toneScore = ((self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].score * 0.7) + 0.3)
            // Set the alpha of the cell to the scaled tone score
            cell.alpha = CGFloat(toneScore)
        } else {
            // Otherwise set the tag label text to an empty string
            cell.tagLabel.text = ""
        }
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {

    // Method that handles actions when the user selects an item in the collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // Get the selected cell
        let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell
        // If the cell text is currently the watson tone name, change the text to the corresponding percentage
        if cell?.tagLabel.text == self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].toneName {
            // Convert the tone score to a percentage value by multiplying by 100
            let toneScore = Int(self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].score*100)
            // Convert the tone score to a string and add a percentage sign
            let toneScoreString = String(toneScore) + "%"
            // Set the cell's tage label text
            cell?.tagLabel.text = toneScoreString
        }
        // Otherwise change the text to the watson tone name
        else {
            cell?.tagLabel.text = self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].toneName
        }

    }

}

extension ViewController: UICollectionViewDelegateFlowLayout {

    // Method that creates the collection view layout based on the size of each text string
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Get the size based on the text string
        let size = NSString(string: self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].toneName).size(withAttributes: nil)

        // Return the given width and height
        return CGSize(width: size.width + 60, height: 30.0)
    }

}


