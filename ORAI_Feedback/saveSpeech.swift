//
//  saveSpeech.swift
//  ORAI_Feedback
//
//  Created by Chris Thompson on 11/20/17.
//  Copyright © 2017 Chris Thompson. All rights reserved.
//

import UIKit
import Parse

class saveSpeech: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    var speech = PFObject(className: "speech")
    @IBOutlet weak var speechName: UITextField!
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        saveSpeechNow()
        return true
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        saveSpeechNow()
    }
    
    func saveSpeechNow(){
        if speechName.text != "" {
            activity.isHidden = false
            activity.startAnimating()
            view.isUserInteractionEnabled = false
            speech["name"] = speechName.text
            speech["user"] = PFUser.current()
            speech["file"] = PFUser.current()!["currentAudio"]
            speech.saveInBackground {
                (success: Bool, error: Error?) in
                if (success) {
                    // The object has been saved.
                    self.dismiss(animated: true, completion: nil)
                    self.view.isUserInteractionEnabled = true

                    
                } else {
                    // There was a problem, check error.description
                    let errorAlert = UIAlertController(title: "Login Problem", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                    
                    
                    errorAlert.addAction(UIAlertAction(title: "tryAgain", style: UIAlertActionStyle.default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    self.view.isUserInteractionEnabled = true

                }
            }
        }
    }
    
    @objc func keyboardWillShow(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height/3
            }
        }
        
    }
    @objc func keyboardWillHide(sender: NSNotification) {
        if let keyboardSize = (sender.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y += keyboardSize.height/3
            }
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: .exit)
        NotificationCenter.default.addObserver(self, selector: #selector(saveSpeech.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(saveSpeech.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    

            speechName.delegate = self

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

private extension Selector {
    static let exit = #selector(SignUpViewController.exit)
}
