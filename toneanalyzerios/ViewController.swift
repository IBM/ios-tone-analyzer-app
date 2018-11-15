//
//  ViewController.swift
//  toneanalyzerios
//

import UIKit
import ToneAnalyzerV3
import SwiftSpinner
import KTCenterFlowLayout
import BMSCore




class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

    // UIButton that will call Watson Tone Analyzer
    @IBOutlet weak var analyzeToneButton: UIButton!
    // UITextView that will hold text to be analyzed
    @IBOutlet weak var toneInputText: UITextView!
    // UICollectionViews that will hold tag cells
    @IBOutlet weak var emotionsCollectionView: UICollectionView!
    @IBOutlet weak var languageStyleCollectionView: UICollectionView!
    @IBOutlet weak var socialTendenciesCollectionView: UICollectionView!

    // ToneAnalyzer Object
    var toneAnalyzer: ToneAnalyzer!
    // Array of analyzedTones
    var analyzedCategoriesArray:[ToneCategory] = []

    override func viewDidLoad() {
      
        super.viewDidLoad()
        self.setupCollectionViews()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        // Create a configuration path for the BMSCredentials.plist file to read in Watson credentials
        let configurationPath = Bundle.main.path(forResource: "BMSCredentials", ofType: "plist")
        let configuration = NSDictionary(contentsOfFile: configurationPath!)
        // Set the Watson credentials for Tone Analyzer service from the BMSCredentials.plist
        let toneanalyzerApikey = configuration?["toneanalyzerApikey"] as! String
        // Set date string for version of Watson service to use
        let versionDate = "2017-09-21"
        // Initialize Tone Analyzer object
         // Initialize Tone Analyzer object
        toneAnalyzer = ToneAnalyzer(version: versionDate, apiKey: toneanalyzerApikey)
        toneAnalyzer.serviceURL = configuration?["toneanalyzerUrl"] as! String
        super.viewDidAppear(animated)

    }

    @objc func didBecomeActive(_ notification: Notification) {
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Function that will setup the three collection views
    func setupCollectionViews(){
        // Set background color for collection views to clear
        self.emotionsCollectionView.backgroundColor = UIColor.clear
        self.languageStyleCollectionView.backgroundColor = UIColor.clear
        self.socialTendenciesCollectionView.backgroundColor = UIColor.clear

        // Create and initialize nib and TagCollectionViewCell
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "TagCollectionViewCell", bundle: bundle)

        // Initialize KTCenterFlowLayout and minimum spacing elements for each collection view
        // Setup emotionsCollectionView
        let emotionsLayout = KTCenterFlowLayout()
        emotionsLayout.minimumInteritemSpacing = 5.0
        emotionsLayout.minimumLineSpacing = 5.0
        emotionsCollectionView.collectionViewLayout = emotionsLayout
        // Setup languageStyleCollectionView
        let languageStyleLayout = KTCenterFlowLayout()
        languageStyleLayout.minimumInteritemSpacing = 5.0
        languageStyleLayout.minimumLineSpacing = 5.0
        languageStyleCollectionView.collectionViewLayout = languageStyleLayout
        // Setup socialTendenciesCollectionView
        let socialTendenciesLayout = KTCenterFlowLayout()
        socialTendenciesLayout.minimumInteritemSpacing = 5.0
        socialTendenciesLayout.minimumLineSpacing = 5.0
        socialTendenciesCollectionView.collectionViewLayout = socialTendenciesLayout

        // Register nibs for each collection view
        emotionsCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
        languageStyleCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
        socialTendenciesCollectionView.register(nib, forCellWithReuseIdentifier: "TagCollectionViewCell")
    }

    // Function called when analyzeToneButton pressed. Will make a call to analyze tone of input text
    @IBAction func analyzeToneButton(_ sender: AnyObject) {
        // Make a call to analyze text if input text box is not empty
        if(toneInputText.text != ""){
            self.analyzeTone(toneInputText.text)
        }
        // Show alert if textbox is empty
        else{
            self.showAlert("Failed to Analyze Tone", alertMessage: "Cannot use Tone Analyzer on an empty string. Please include a string in the input textbox in order to use the service.")
        }
    }

    // Function that will analyze tone using the Watson Tone Analyzer
    func analyzeTone(_ textToAnalyze: String){

        SwiftSpinner.show("Watson is Analyzing Tone")

        // Use Watson Tone Analyzer to analyze input text. Call error function if failure
        let textString = ToneContent.text(textToAnalyze)
         toneAnalyzer.tone(toneContent: textString,failure:failToneAnalyzerWithError ) { (tones) in
          
          
           DispatchQueue.main.async {
         // Loop through sentence tones
            self.analyzedCategoriesArray = []
            // Loop through document tones
             for documentTone in tones.documentTone.tones! {
                // Set tone category parameters
                let toneId = documentTone.toneID
                let toneName = documentTone.toneName
                let toneScore = documentTone.score
                // Create new tone category with information provided by document tone
                 let newToneCategory = ToneCategory(toneId: toneId, toneName: toneName, toneScore: toneScore)
                // Add new tone category to array
                self.analyzedCategoriesArray.append(newToneCategory)
            }

            // Reload each collection view with new data
            self.emotionsCollectionView.reloadData()
            self.languageStyleCollectionView.reloadData()
            self.socialTendenciesCollectionView.reloadData()

            SwiftSpinner.hide()
        }
      }
    }

    // Function handling errors with Tone Analyzer
    func failToneAnalyzerWithError(_ error: Error) {
        // Print the error to the console
        print(error)
        // Hide the spinner
        SwiftSpinner.hide()
        // Present an alert to the user descirbing what the problem may be
        showAlert("Tone Analyzer Failed", alertMessage: "The Tone Analyzer service failed to analyze the given text. This could be due to invalid credentials, internet connection or other errors. Please verify your credentials in the WatsonCredentials.plist and rebuild the application. See the README for further assistance.")

    }

    // Function to show an alert with an alertTitle String and alertMessage String
    func showAlert(_ alertTitle: String, alertMessage: String){
        // If an alert is not currently being displayed
        if(self.presentedViewController == nil){
            // Set alert properties
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
            // Add an action to the alert
            alert.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            // Show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }

    // Function to handle the number of items in the collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        // If the analyzed catagories array contains an object at the given index return the number of tones it contains
        if(analyzedCategoriesArray.indices.contains(collectionView.tag)){
            return self.analyzedCategoriesArray.count
        }
        // Otherwise return 0 since it does not contain any items
        else{
            return 0
        }
    }

    // Funtion to get the cell for item at index path in the collection view
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // Create the cell that will reference the TagCollectionViewCell that is created
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCollectionViewCell", for: indexPath) as? TagCollectionViewCell else {
            return UICollectionViewCell()
        }
        // Set the cell's tagLabel text to the watson result name. Using the collection views tag to choose the correct array location
        if(analyzedCategoriesArray.indices.contains(collectionView.tag)){
            // Set the tag label text to the tone's name
             cell.tagLabel.text = self.analyzedCategoriesArray[collectionView.tag].toneName
            // Create a scaled tone score based on the percentage retured by watson
            let toneScore = ((self.analyzedCategoriesArray[collectionView.tag].toneScore * 0.7) + 0.3)
            // Set the alpha of the cell to the scaled tone score
            cell.alpha = CGFloat(toneScore)
        }
        // Otherwise set the tag label text to an empty string
        else{
            cell.tagLabel.text = ""
        }
        return cell
    }

    // Function that creates the collection view layout based on the size of each text string
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
            // Get the size based on the text string
        #if swift(>=4.0)
            let size = NSString(string: self.analyzedCategoriesArray[collectionView.tag].tones[indexPath.item].name).size(withAttributes: nil)
        #else
             let size = NSString(string: self.analyzedCategoriesArray[collectionView.tag].toneName).size(attributes: nil)
        #endif
            // Return the given width and height
        return CGSize(width: size.width + 60, height: 30.0)
    }

    // Function that handles actions when the user selects an item in the collection view
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){

        // Get the selected cell
        let cell = collectionView.cellForItem(at: indexPath) as? TagCollectionViewCell
        // If the cell text is currently the watson tone name, change the text to the corresponding percentage
         if(cell?.tagLabel.text == self.analyzedCategoriesArray[collectionView.tag].toneName){
            // Convert the tone score to a percentage value by multiplying by 100
             let toneScore = Int(self.analyzedCategoriesArray[collectionView.tag].toneScore * 100)
            // Convert the tone score to a string and add a percentage sign
            let toneScoreString = String(toneScore) + "%"
            // Set the cell's tage label text
            cell?.tagLabel.text = toneScoreString
        }
        // Otherwise change the text to the watson tone name
        else{
              cell?.tagLabel.text = self.analyzedCategoriesArray[collectionView.tag].toneName
        }

    }

}
