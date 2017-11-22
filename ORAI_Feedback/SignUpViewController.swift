//
//  SignUpViewController.swift
//  ORAI_Feedback
//
//  Created by Chris Thompson on 11/19/17.
//  Copyright © 2017 Chris Thompson. All rights reserved.
//

import UIKit
import Parse

class SignUpViewController: UIViewController {
    

    

    
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var signUpOutlet: UIButton!
    
    @objc func exit() {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signUpAction(_ sender: Any) {
        if username.text != "" && email.text != "" && password.text != ""{

            let user = PFUser()
            user.username = username.text
            user.password = password.text
            user.email = email.text
            
            user.signUpInBackground(block: { (success, errorMessage) in
                
                if success == true && errorMessage == nil {
                self.dismiss(animated: true, completion: nil)
                } else {
                    
                    let errorAlert = UIAlertController(title: "Login Problem", message: errorMessage as! String, preferredStyle: UIAlertControllerStyle.alert)

                    
                    errorAlert.addAction(UIAlertAction(title: "tryAgain", style: UIAlertActionStyle.default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                    
                }
            })
            
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: .exit)

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
