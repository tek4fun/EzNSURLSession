//
//  EditContactVC.swift
//  NSURLSession
//
//  Created by iOS Student on 3/2/17.
//  Copyright © 2017 Vinh The. All rights reserved.
//

import UIKit
protocol EditContactDelegate {
    func dismissEditContactController(editVC : EditContactVC)
}
class EditContactVC: UIViewController {

    var information = [Person]()

    @IBOutlet weak var bannerView: UIView!

    @IBOutlet weak var nameTextField: CustomTextField!

    @IBOutlet weak var phoneTextField: CustomTextField!

    @IBOutlet weak var cityTextField: CustomTextField!

    @IBOutlet weak var emailTextField: CustomTextField!

    @IBOutlet weak var navLabel: UILabel!

    @IBOutlet weak var editButton: UIButton!

    var delegate : EditContactDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        phoneTextField.delegate = self
        cityTextField.delegate = self
        emailTextField.delegate = self

        nameTextField.text = information[0].name
        phoneTextField.text = String(describing: information[0].phone!)
        cityTextField.text = information[0].city
        emailTextField.text = information[0].email
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        setMask(view, rectCorner: [.bottomLeft,.bottomRight, .topLeft, .topRight], radius: CGSize(width: 20.0, height: 20.0))
        setMask(bannerView, rectCorner: [.topLeft, .topRight], radius: CGSize(width: 20.0, height: 20.0))

    }
    // MARK: Post Request

    func editContactRequest(name : String, phone : Int, city : String?, email: String?, id : String) {
        var param : [String : AnyObject] = ["Name": name as AnyObject, "PhoneNumber" : phone as AnyObject]
        if city != nil{
            param["City"] = city as AnyObject?
        }
        if email != nil {
            param["Email"] = email as AnyObject?
        }

        var urlRequest =  URLRequest(url: URL(string: baseUrl + information[0].id!)!)
        urlRequest.httpMethod = "PUT"

        let configureSession = URLSessionConfiguration.default
        configureSession.httpAdditionalHeaders = ["Content-Type" : "application/json"]

        let createContactSession = URLSession(configuration: configureSession)

        let dataPassing = try! JSONSerialization.data(withJSONObject: param, options: .prettyPrinted)

        createContactSession.uploadTask(with: urlRequest as URLRequest, from: dataPassing) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                if let responseHTTP = response as? HTTPURLResponse{
                    if responseHTTP.statusCode == 200 {
                        print(data)
                        DispatchQueue.main.async {
                            self.delegate?.dismissEditContactController(editVC: self)
                        }
                    }else {
                        print(responseHTTP.statusCode)
                    }
                }
            }
            }.resume()
    }

    // MARK: Create corner roundrect.

    func setMask(_ view : UIView, rectCorner : UIRectCorner, radius : CGSize){
        let maskPath = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: rectCorner, cornerRadii: radius)

        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        maskLayer.borderWidth = 1.0
        maskLayer.borderColor = UIColor.black.cgColor

        view.layer.mask = maskLayer

    }

    @IBAction func editContactAction(_ sender: AnyObject) {
        if let name = nameTextField.text, let phone = Int(phoneTextField.text!)
        {
            editContactRequest(name: name, phone: phone, city: cityTextField.text, email: emailTextField.text, id: information[0].id!)
        }else {
            print("no name no phone")
        }
    }
}


extension EditContactVC : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.setValue(UIColor.clear, forKeyPath: "_placeholderLabel.textColor")
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.setValue(UIColor.black, forKeyPath: "_placeholderLabel.textColor")
    }
}
