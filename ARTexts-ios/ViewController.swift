//
//  ViewController.swift
//  ARTexts-ios
//
//  Created by James Folk on 8/3/17.
//  Copyright © 2017 James Folk. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import CoreLocation

class ViewController: UIViewController, ARSKViewDelegate {
    
    @IBOutlet var sceneView: ARSKView!
    
    var locationManager: CLLocationManager!
    var currentCLLocation: CLLocation?
    var currentCameraLocation: matrix_float4x4?
    
    private var currentLabel : SKLabelNode?
    private var currentField : UITextField?
    
    var readyTimer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            sceneView.presentScene(scene)
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSKViewDelegate
    
    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        // Create and configure a node for the anchor added to the view's session.
        currentLabel = SKLabelNode(text: "👾")
        currentLabel?.horizontalAlignmentMode = .center
        currentLabel?.verticalAlignmentMode = .center
        
        self.addRemoteARText(anchor.transform)
        
        if(self.currentField != nil)
        {
            self.currentField?.resignFirstResponder()
            self.currentField = nil
        }
        
        if(self.currentField == nil)
        {
            currentField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
            currentField?.delegate = self
            currentField?.isHidden = true
            self.view?.addSubview(currentField!)
        }
        currentField?.text = currentLabel?.text
        currentField?.becomeFirstResponder()
        
        return currentLabel;
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func startRemoteARSession()
    {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        
// TODO: - Send the current world position to the server
// The RESTful response should be the stored gps location if there was a previous session or null if there is no session.
// If there is a previous session, find the gps location difference and convert it to matrix_float4x4;
// Then load all of the texts and draw it.
    }
    
    func addRemoteARText(_ transform: matrix_float4x4)
    {
// TODO: - Send the text's transform to the server
//        transform.columns.0.x
//        transform.columns.0.y
//        transform.columns.0.z
//        transform.columns.0.w
//
//        transform.columns.1.x
//        transform.columns.1.y
//        transform.columns.1.z
//        transform.columns.1.w
//
//        transform.columns.2.x
//        transform.columns.2.y
//        transform.columns.2.z
//        transform.columns.2.w
//
//        transform.columns.3.x
//        transform.columns.3.y
//        transform.columns.3.z
//        transform.columns.3.w
    }
    
    func loadRemoteSession() -> Bool
    {
        return false
    }
    
    func getWorldTransformOffset(_ transform: matrix_float4x4) -> matrix_float4x4!
    {
        var worldTransform = matrix_float4x4(diagonal: float4(1.0))
        return worldTransform + transform
    }
    
    func manuallyAddARText(_ transform: matrix_float4x4)
    {
        //should make sure that the AR Session has started.
        self.sceneView.session.add(anchor: ARAnchor(transform: self.getWorldTransformOffset(transform)))
    }
}

extension ViewController:ARSessionDelegate
{
    func session(_ session: ARSession,
                 didUpdate frame: ARFrame)
    {
        //The camera Transform...
        currentCameraLocation = frame.camera.transform
    }
}

extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var startARSession:Bool = false
        if(currentCLLocation == nil)
        {
            startARSession = true
        }
        
        currentCLLocation = locations[0]
        if(currentCLLocation == nil)
        {
            return
        }
        
        if(startARSession)
        {
            startRemoteARSession()
        }
    }
}

extension ViewController: UITextFieldDelegate
{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
        
        currentLabel?.text = newString
        return true
    }
    
    private func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            textView.selectAll(nil)
        }
    }
}
