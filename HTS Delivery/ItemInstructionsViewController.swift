//
//  ItemInstructionsViewController.swift
//  FlickrSearch
//
//  Created by Moussa Dembele on 1/25/23.
//  Copyright © 2023 Moussa Hamet DEMBELE. All rights reserved.
//

import UIKit

class ItemInstructionsViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.layer.cornerRadius=5
        textView.delegate=self
        textView.text = "Provide special instructions(e.g., food allergies,extra sauce,...) and our partner will do its best to accommodate you."
        textView.textColor=UIColor.darkGray
        //textView.becomeFirstResponder()
        textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)

        // Do any additional setup after loading the view.
    }
    
    @IBAction func done(_ sender: Any) {
       
        if let presentingVC = presentingViewController as? UINavigationController
        {
            print(presentingVC.viewControllers)
            if let addOnsViewController = presentingVC.viewControllers[0] as? AddOnsTableViewController
            {
                addOnsViewController.textView=textView
            }
            
        }
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension ItemInstructionsViewController:UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.darkGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Provide special instructions(e.g., food allergies,extra sauce,...) and our partner will do its best to accommodate you."
            textView.textColor = UIColor.darkGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = "Provide special instructions(e.g., food allergies,extra sauce,...) and our partner will do its best to accommodate you."
            textView.textColor = UIColor.darkGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to black then set its text to the
        // replacement string
        else if textView.textColor == UIColor.darkGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }

        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
}
