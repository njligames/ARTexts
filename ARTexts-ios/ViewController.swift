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
import CoreMotion

class ViewController: UIViewController, ARSKViewDelegate {
    
    let address:String = "http://10.0.1.120:3000"
    
    @IBOutlet var sceneView: ARSKView!
    
    var locationManager: CLLocationManager!
    var currentCLLocation: CLLocation? {
        didSet {
            guard let loc = currentCLLocation else { return }
            
            longitudeLabel.text = "longitude \(loc.coordinate.longitude)"
            latitudeLabel.text = "latitude \(loc.coordinate.latitude)"
            altitudeLabel.text = "altitude \(loc.altitude)"
            courseLabel.text = "course \(loc.course)"
        }
    }
    var currentCameraLocation: matrix_float4x4? {
        didSet {
            guard let loc = currentCameraLocation else { return }
            
            cameraLabel.text = "\(loc.columns.3)"
        }
    }
    
    var currentAttitude:CMAttitude? {
        didSet {
            guard let a = currentAttitude else { return }
            
            self.deviceRotationLabel.text = "\(a)"
        }
    }
    
    var startAttitude:CMAttitude?
    var startYaw:Double = 0.0
    var startPitch:Double = 0.0
    var startRoll:Double = 0.0
    
    var remoteReady:Bool = false
    
    var blurView:UIVisualEffectView?
    
    var arReady:Bool = false
    
    private var currentLabel : SKLabelNode?
    private var currentLabelTransform : matrix_float4x4?
    
    private var currentField : UITextField?
    private var currentTextId : String?
    
    let coreMotionManager = CMMotionManager()
    
    // get magnitude of vector via Pythagorean theorem
    func magnitude(from attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
    
    var cameraLabel: SKLabelNode!
    
    var longitudeLabel: SKLabelNode!
    var latitudeLabel: SKLabelNode!
    var altitudeLabel: SKLabelNode!
    var courseLabel: SKLabelNode!
    
    var deviceRotationLabel: SKLabelNode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blur = UIBlurEffect(style: .regular)
        self.blurView = UIVisualEffectView(effect: blur)
        self.blurView?.frame = self.view.bounds
        self.blurView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(self.blurView!)
        
        //http://xcodenoobies.blogspot.com/2014/12/multiline-sklabelnode-hell-yes-please-xd.html
        cameraLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        cameraLabel.text = "cameraLabel"
        cameraLabel.horizontalAlignmentMode = .center
        cameraLabel.verticalAlignmentMode = .center
        cameraLabel.position = CGPoint(x: 0, y: 0)
        cameraLabel.fontSize = 12
        
        longitudeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        longitudeLabel.text = "longitudeLabel"
        longitudeLabel.horizontalAlignmentMode = .center
        longitudeLabel.verticalAlignmentMode = .center
        longitudeLabel.position = CGPoint(x: 0, y: 10)
        longitudeLabel.fontSize = 12
        
        latitudeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        latitudeLabel.text = "latitudeLabel"
        latitudeLabel.horizontalAlignmentMode = .center
        latitudeLabel.verticalAlignmentMode = .center
        latitudeLabel.position = CGPoint(x: 0, y: 20)
        latitudeLabel.fontSize = 12
        
        altitudeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        altitudeLabel.text = "altitudeLabel"
        altitudeLabel.horizontalAlignmentMode = .center
        altitudeLabel.verticalAlignmentMode = .center
        altitudeLabel.position = CGPoint(x: 0, y: 30)
        altitudeLabel.fontSize = 12
        
        courseLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        courseLabel.text = "courseLabel"
        courseLabel.horizontalAlignmentMode = .center
        courseLabel.verticalAlignmentMode = .center
        courseLabel.position = CGPoint(x: 0, y: 40)
        courseLabel.fontSize = 12
        
        deviceRotationLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        deviceRotationLabel.text = "deviceRotationLabel"
        deviceRotationLabel.horizontalAlignmentMode = .center
        deviceRotationLabel.verticalAlignmentMode = .center
        deviceRotationLabel.position = CGPoint(x: 0, y: 50)
        deviceRotationLabel.fontSize = 12
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true
        
        // Load the SKScene from 'Scene.sks'
        if let scene = SKScene(fileNamed: "Scene") {
            scene.addChild(cameraLabel)
            scene.addChild(longitudeLabel)
            scene.addChild(latitudeLabel)
            scene.addChild(altitudeLabel)
            scene.addChild(courseLabel)
            scene.addChild(deviceRotationLabel)
            
            sceneView.presentScene(scene)
        }
        
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        
        
//        self.listAllTexts(arText: {(success:Bool, values:[String:Any]) in
//            print(success)
//            print(values)
//        })
        
//        self.createAText("While you are eating.. I had to go to a training class.", matrix_identity_float4x4, arText: {(id:String, success:Bool) in
//            print("id:\(id)")
//        })
//
//        self.readAText("59895a0b29db476df8f0a158", arText: {(text:String,transform:matrix_float4x4, success:Bool) in
//            print("text:\(text)\ntransform:\(transform)")
//        })
//
//        self.updateAText("59895a0b29db476df8f0a158", "ass hat mother fuckerh", matrix_identity_float4x4, arText: {(success:Bool) in
//            print(success)
//        })
//
//        self.deleteAText("59895a0b29db476df8f0a158", arText: {(success:Bool) in
//            print(success)
//        })
        
        
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
        
        if(self.arReady && self.remoteReady)
        {
            // Create and configure a node for the anchor added to the view's session.
            currentLabel = SKLabelNode(text: "👾")
            currentLabel?.horizontalAlignmentMode = .center
            currentLabel?.verticalAlignmentMode = .center
            
            currentLabelTransform = anchor.transform
            
            self.createAText((currentLabel?.text)!, anchor.transform, arText: {(id:String, success:Bool) in
                
                DispatchQueue.main.async {
                    
                    print("id:\(id)")
                    
                    self.currentTextId = id
                    
                    if(self.currentField != nil)
                    {
                        self.currentField?.removeFromSuperview()
                        self.currentField?.resignFirstResponder()
                        self.currentField = nil
                    }
                    
                    if(self.currentField == nil)
                    {
                        self.currentField = UITextField(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                        self.currentField?.delegate = self
                        self.currentField?.isHidden = true
                        self.view?.addSubview(self.currentField!)
                    }
                    self.currentField?.text = self.currentLabel?.text
                    self.currentField?.becomeFirstResponder()
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
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
    
    func listAllSessions(arSession: @escaping (_ succeeded:Bool, _ sessions:Array<[String:Any]>) -> ())
    {
        let url = URL(string: "\(self.address)/sessions")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false, [])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false, [])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let sessions = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? Array<[String:Any]> else {
                        arSession(false, [])
                        print("error trying to convert data to JSON")
                        return
                }
                arSession(true, sessions)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    func createASession(_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, arSession: @escaping (_ id:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)&yaw=\(yaw)&pitch=\(pitch)&roll=\(roll)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession("", false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession("", false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let session = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession("", false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + session.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let _id = session["_id"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                //                print("The textId is: " + _id)
                
                arSession(_id, true)
                
            } catch  {
                arSession("", false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func readASession(_ id:String, arSession: @escaping (_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error calling GET on /sessions")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arSession = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + _arSession.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let latitude = _arSession["latitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let longitude = _arSession["longitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let altitude = _arSession["altitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let horizontalAccuracy = _arSession["horizontalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let verticalAccuracy = _arSession["verticalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let course = _arSession["course"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let speed = _arSession["speed"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let yaw = _arSession["yaw"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let pitch = _arSession["pitch"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let roll = _arSession["roll"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
//                guard let timestamp = _arSession["timestamp"] as? Date else {
//                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Date(), false)
//                    print("Could not get todo title from JSON")
//                    return
//                }
                
//                let numberFormatter = NumberFormatter()
                
                /*
                 _ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ timestamp:Date
                 */
                
                arSession(latitude,
                          longitude,
                          altitude,
                          horizontalAccuracy,
                          verticalAccuracy,
                          course,
                          speed,
                          yaw,
                          pitch,
                          roll,
                          true)
            } catch  {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func updateASession(_ id:String, _ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ yaw:Double, _ pitch:Double, _ roll:Double, arSession: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)&yaw=\(yaw)&pitch=\(pitch)&roll=\(roll)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
                //                print("The todo is: " + text.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard (text["_id"] as? String) != nil else {
                    arSession(false)
                    print("Could not get todo title from JSON")
                    return
                }
                //                print("The textId is: " + _id)
                
                guard (text["Created_date"] as? String) != nil else {
                    arSession(false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                //                print("The Created_date is: " + Created_date)
                arSession(true)
            } catch  {
                arSession(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func deleteASession(_ id:String, arSession: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + text.description)
                
                arSession(true)
            } catch  {
                arSession(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func startRemoteARSession()
    {
        // Create a session configuration
        let configuration = ARWorldTrackingSessionConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
        sceneView.session.delegate = self
        
        guard let latitude:Double = self.currentCLLocation?.coordinate.latitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let longitude:Double = self.currentCLLocation?.coordinate.longitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let altitude:Double = self.currentCLLocation?.altitude else {
            print("Error: cannot create URL")
            return
        }
        
        guard let horizontalAccuracy:Double = self.currentCLLocation?.horizontalAccuracy else {
            print("Error: cannot create URL")
            return
        }
        
        guard let verticalAccuracy:Double = self.currentCLLocation?.verticalAccuracy else {
            print("Error: cannot create URL")
            return
        }
        
        guard let course:Double = self.currentCLLocation?.course else {
            print("Error: cannot create URL")
            return
        }
        
        guard let speed:Double = self.currentCLLocation?.speed else {
            print("Error: cannot create URL")
            return
        }
        
//        guard let timestamp:Date = self.currentCLLocation?.timestamp else {
//            print("Error: cannot create URL")
//            return
//        }
        
        let defaults = UserDefaults.standard
        if let sessionId = defaults.string(forKey: "sessionId")
        {
            self.readASession(sessionId, arSession: {(latitude:Double, longitude:Double, altitude:Double, horizontalAccuracy:Double, verticalAccuracy:Double, course:Double, speed:Double, yaw:Double, pitch:Double, roll:Double, success:Bool) in
                
                self.remoteReady = true
                
                self.startYaw = yaw
                self.startPitch = pitch
                self.startRoll = roll
                
                self.listAllTexts(arText: {(success:Bool, texts:Array<[String:Any]>) in
                    for _arText in texts
                    {
                        guard let text = _arText["text"] as? String else {
                            continue
                        }
                        
                        guard let t = _arText["transform"] as? String else {
                            continue
                        }
                        
                        let transformComponents = t.components(separatedBy: ",")
                        
                        let numberFormatter = NumberFormatter()
                        
                        let transform = matrix_float4x4(float4(x: (numberFormatter.number(from: transformComponents[0])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[1])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[2])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[3])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[4])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[5])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[6])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[7])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[8])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[9])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[10])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[11])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[12])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[13])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[14])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[15])?.floatValue)!))
                        
                        print("\(text) : \(transform)")
                    }
                })
            })
        }
        else
        {
            self.createASession(latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, course, speed, self.startYaw, self.startPitch, self.startRoll, arSession: {(id:String, success:Bool) in
                
                defaults.setValue(id, forKey: "sessionId")
                defaults.synchronize()
                
                self.remoteReady = true
                
            })
        }
        
        
// TODO: - Send the current GPS location to the server.
// The RESTful response should be the stored gps location if there was a previous session or null if there is no session.
// If there is a previous session, find the gps location difference and convert it to matrix_float4x4;
// Then load all of the texts and draw it.
    }
    
    func listAllTexts(arText: @escaping (_ succeeded:Bool, _ texts:Array<[String:Any]>) -> ())
    {
        let url = URL(string: "\(self.address)/texts")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
//        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false,[])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false, [])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let texts = try JSONSerialization.jsonObject(with: responseData, options: [.allowFragments]) as? Array<[String:Any]> else {
                    arText(false, [])
                    return
                }
                arText(true, texts)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    //needs a completion string
    func createAText(_ text:String, _ transform: matrix_float4x4, arText: @escaping (_ id:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var transformString:String = transform.columns.0.x.description
        transformString += ","
        transformString += transform.columns.0.y.description
        transformString += ","
        transformString += transform.columns.0.z.description
        transformString += ","
        transformString += transform.columns.0.w.description
        transformString += ","
        transformString += transform.columns.1.x.description
        transformString += ","
        transformString += transform.columns.1.y.description
        transformString += ","
        transformString += transform.columns.1.z.description
        transformString += ","
        transformString += transform.columns.1.w.description
        transformString += ","
        transformString += transform.columns.2.x.description
        transformString += ","
        transformString += transform.columns.2.y.description
        transformString += ","
        transformString += transform.columns.2.z.description
        transformString += ","
        transformString += transform.columns.2.w.description
        transformString += ","
        transformString += transform.columns.3.x.description
        transformString += ","
        transformString += transform.columns.3.y.description
        transformString += ","
        transformString += transform.columns.3.z.description
        transformString += ","
        transformString += transform.columns.3.w.description
        
        let defaults = UserDefaults.standard
        if let sessionId = defaults.string(forKey: "sessionId")
        {
            let postString = "transform=\(transformString)&text=\(text)&sessionId=\(sessionId)"
            request.httpBody = postString.data(using: .utf8)
            
            let task = session.dataTask(with: request) {
                (data, response, error) in
                // check for any errors
                guard error == nil else {
                    arText("", false)
                    print("error calling GET on /texts")
                    print(error!)
                    return
                }
                // make sure we got data
                guard let responseData = data else {
                    arText("", false)
                    print("Error: did not receive data")
                    return
                }
                // parse the result as JSON, since that's what the API provides
                do {
                    guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                        as? [String: Any] else {
                            arText("", false)
                            print("error trying to convert data to JSON")
                            return
                    }
                    
                    // now we have the todo
                    // let's just print it to prove we can access it
                    //                print("The todo is: " + text.description)
                    
                    // the todo object is a dictionary
                    // so we just access the title using the "title" key
                    // so check for a title and print it if we have one
                    guard let _id = text["_id"] as? String else {
                        print("Could not get todo title from JSON")
                        return
                    }
                    //                print("The textId is: " + _id)
                    
                    arText(_id, true)
                    
                } catch  {
                    arText("", false)
                    print("error trying to convert data to JSON")
                    return
                }
            }
            task.resume()
        }
        else
        {
            arText("", false)
        }
        
    }
    
    func readAText(_ id:String, arText: @escaping (_ text:String, _ transform: matrix_float4x4, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText("", matrix_identity_float4x4, false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText("", matrix_identity_float4x4, false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arText = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText("", matrix_identity_float4x4, false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
//                print("The todo is: " + _arText.description)
                
                let defaults = UserDefaults.standard
                if let sessionId = defaults.string(forKey: "sessionId")
                {
                    guard let _sessionId = _arText["sessionId"] as? String else {
                        arText("", matrix_identity_float4x4, false)
                        print("Could not get todo title from JSON")
                        return
                    }
                    
                    if(sessionId == _sessionId)
                    {
                        // the todo object is a dictionary
                        // so we just access the title using the "title" key
                        // so check for a title and print it if we have one
                        guard let text = _arText["text"] as? String else {
                            arText("", matrix_identity_float4x4, false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        //                print("The text is: " + text)
                        
                        guard let transform = _arText["transform"] as? String else {
                            arText(text, matrix_identity_float4x4, false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        //                print("The transform is: " + transform)
                        let transformComponents = transform.components(separatedBy: ",")
                        
                        let numberFormatter = NumberFormatter()
                        
                        let t = matrix_float4x4(float4(x: (numberFormatter.number(from: transformComponents[0])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[1])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[2])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[3])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[4])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[5])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[6])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[7])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[8])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[9])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[10])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[11])?.floatValue)!),
                                                float4(x: (numberFormatter.number(from: transformComponents[12])?.floatValue)!,
                                                       y: (numberFormatter.number(from: transformComponents[13])?.floatValue)!,
                                                       z: (numberFormatter.number(from: transformComponents[14])?.floatValue)!,
                                                       w: (numberFormatter.number(from: transformComponents[15])?.floatValue)!))
                        
                        arText(text, t, true)
                    }
                    else
                    {
                        arText("", matrix_identity_float4x4, false)
                    }
                }
                else
                {
                    arText("", matrix_identity_float4x4, false)
                }
            } catch  {
                arText("", matrix_identity_float4x4, false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func updateAText(_ id:String, _ text:String, _ transform: matrix_float4x4, arText: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        var transformString:String = transform.columns.0.x.description
        transformString += ","
        transformString += transform.columns.0.y.description
        transformString += ","
        transformString += transform.columns.0.z.description
        transformString += ","
        transformString += transform.columns.0.w.description
        transformString += ","
        transformString += transform.columns.1.x.description
        transformString += ","
        transformString += transform.columns.1.y.description
        transformString += ","
        transformString += transform.columns.1.z.description
        transformString += ","
        transformString += transform.columns.1.w.description
        transformString += ","
        transformString += transform.columns.2.x.description
        transformString += ","
        transformString += transform.columns.2.y.description
        transformString += ","
        transformString += transform.columns.2.z.description
        transformString += ","
        transformString += transform.columns.2.w.description
        transformString += ","
        transformString += transform.columns.3.x.description
        transformString += ","
        transformString += transform.columns.3.y.description
        transformString += ","
        transformString += transform.columns.3.z.description
        transformString += ","
        transformString += transform.columns.3.w.description
        
        let postString = "transform=\(transformString)&text=\(text)"
        request.httpBody = postString.data(using: .utf8)
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText(false)
                        print("error trying to convert data to JSON")
                        return
                }
                
                // now we have the todo
                // let's just print it to prove we can access it
//                print("The todo is: " + text.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let _id = text["_id"] as? String else {
                    arText(false)
                    print("Could not get todo title from JSON")
                    return
                }
//                print("The textId is: " + _id)
                
                guard let Created_date = text["Created_date"] as? String else {
                    arText(false)
                    print("Could not get todo title from JSON")
                    return
                }
                
//                print("The Created_date is: " + Created_date)
                arText(true)
            } catch  {
                arText(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func deleteAText(_ id:String, arText: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "\(self.address)/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText(false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let text = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText(false)
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + text.description)
                
                arText(true)
            } catch  {
                arText(false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func updateRemoteARText(_ _id:NSInteger, _ text:String)
    {
        
    }
    
//    func addRemoteARText(_ transform: matrix_float4x4)
//    {
//        let url = URL(string: "\(self.address)")!
//
//        let parameters = ["transform":
//            [
//                transform.columns.0.x,
//                transform.columns.0.y,
//                transform.columns.0.z,
//                transform.columns.0.w,
//
//                transform.columns.1.x,
//                transform.columns.1.y,
//                transform.columns.1.z,
//                transform.columns.1.w,
//
//                transform.columns.2.x,
//                transform.columns.2.y,
//                transform.columns.2.z,
//                transform.columns.2.w,
//
//                transform.columns.3.x,
//                transform.columns.3.y,
//                transform.columns.3.z,
//                transform.columns.3.w
//            ]
//        ]
//
//        //create the session object
//        let session = URLSession.shared
//
//        //now create the URLRequest object using the url object
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST" //set http method as POST
//
//        do {
//            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
//        } catch let error {
//            print(error.localizedDescription)
//        }
//
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/json", forHTTPHeaderField: "Accept")
//
//        //create dataTask using the session object to send data to the server
//        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
//
//            guard error == nil else {
//                return
//            }
//
//            guard let data = data else {
//                return
//            }
//
//            do {
//                //create json object from data
//                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
//                    print(json)
//                    // handle json...
//                }
//            } catch let error {
//                print(error.localizedDescription)
//            }
//        })
//        task.resume()
//
////        {
////            "transform" : [
////            1.0, 0.0, 0.0, 0.0,
////            0.0, 1.0, 0.0, 0.0,
////            0.0, 0.0, 1.0, 0.0,
////            0.0, 0.0, 0.0, 1.0
////            ]
////        }
//
//// TODO: - Send the text's transform to the server, the server should return with an id, so that the user can edit the text.
//
//    }
    
    func loadRemoteSession() -> Bool
    {
        return false
    }
    
    func getWorldTransformOffset(_ transform: matrix_float4x4) -> matrix_float4x4!
    {
        var worldTransform = matrix_identity_float4x4
        return worldTransform + transform
    }
    
    func manuallyAddARText(_ transform: matrix_float4x4)
    {
        //should make sure that the AR Session has started.
        self.sceneView.session.add(anchor: ARAnchor(transform: self.getWorldTransformOffset(transform)))
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        
        switch camera.trackingState {
        case .notAvailable:
            self.arReady = false
            self.blurView!.isHidden = false
        case .limited:
            self.blurView!.isHidden = false
            self.arReady = false
        case .normal:
            self.arReady = true
            self.blurView!.isHidden = true
        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}

extension ViewController:ARSessionDelegate
{
    func session(_ session: ARSession,
                 didUpdate frame: ARFrame)
    {
        currentCameraLocation = frame.camera.transform
    }
}

extension ViewController:CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        var startCMSession:Bool = false
        if(currentCLLocation == nil)
        {
            startCMSession = true
        }

        currentCLLocation = locations[0]
        if(currentCLLocation == nil)
        {
            return
        }

        if(startCMSession)
        {
            if coreMotionManager.isDeviceMotionAvailable {
                
                coreMotionManager.startDeviceMotionUpdates(to: .main) {
                    [weak self] (data: CMDeviceMotion?, error: Error?) in
                    
                    guard let data = data else { return }
                    
                    self?.currentAttitude = data.attitude
                    
                    if (self?.startAttitude == nil)
                    {
                        self?.startAttitude = data.attitude
                        
                        self?.startRoll = (self?.startAttitude?.roll)!
                        self?.startYaw = (self?.startAttitude?.yaw)!
                        self?.startPitch = (self?.startAttitude?.pitch)!
                        
                        self?.startRemoteARSession()
                    }
                }
            }
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.updateAText(self.currentTextId!, textField.text!, currentLabelTransform!, arText: {(success:Bool) in
            DispatchQueue.main.async {
                self.view.endEditing(true)
            }
        })
        
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        DispatchQueue.main.async {
            textField.selectAll(nil)
        }
    }
}

extension SKLabelNode {
    func multilined() -> SKLabelNode {
        let substrings: [String] = self.text!.components(separatedBy: "\n")
        return substrings.enumerated().reduce(SKLabelNode()) {
            let label = SKLabelNode(fontNamed: self.fontName)
            label.text = $1.element
            label.fontColor = self.fontColor
            label.fontSize = self.fontSize
            label.position = self.position
            label.horizontalAlignmentMode = self.horizontalAlignmentMode
            label.verticalAlignmentMode = self.verticalAlignmentMode
            let y = CGFloat($1.offset - substrings.count / 2) * self.fontSize
            label.position = CGPoint(x: 0, y: -y)
            $0.addChild(label)
            return $0
        }
    }
}

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}
