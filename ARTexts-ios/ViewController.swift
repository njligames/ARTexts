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
        
//        self.listAllTexts(arText: {(success:Bool, values:[String:Any]) in
//            print(success)
//            print(values)
//        })
        
//        self.createAText("While you are eating.. I had to go to a training class.", matrix_float4x4(diagonal: float4(1.0)), arText: {(id:String, success:Bool) in
//            print("id:\(id)")
//        })
//
//        self.readAText("59895a0b29db476df8f0a158", arText: {(text:String,transform:matrix_float4x4, success:Bool) in
//            print("text:\(text)\ntransform:\(transform)")
//        })
//
//        self.updateAText("59895a0b29db476df8f0a158", "ass hat mother fuckerh", matrix_float4x4(diagonal: float4(1.0)), arText: {(success:Bool) in
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
    
    func listAllSessions(arSession: @escaping (_ succeeded:Bool, _ texts:[String:Any]) -> ())
    {
        let url = URL(string: "http://localhost:3000/sessions")!
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
                arSession(false, [:])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(false, [:])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let texts = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(false, [:])
                        print("error trying to convert data to JSON")
                        return
                }
                arSession(true, texts)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    func createASession(_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, arSession: @escaping (_ id:String, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "http://localhost:3000/sessions")!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)"
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
    
    func readASession(_ id:String, arSession: @escaping (_ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, _ succeeded:Bool) -> ())
    {
        let url = URL(string: "http://localhost:3000/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error calling GET on /sessions")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("Error: did not receive data")
                return
            }
            
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arSession = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
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
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let longitude = _arSession["longitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let altitude = _arSession["altitude"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let horizontalAccuracy = _arSession["horizontalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let verticalAccuracy = _arSession["verticalAccuracy"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let course = _arSession["course"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                    print("Could not get todo title from JSON")
                    return
                }
                
                guard let speed = _arSession["speed"] as? Double else {
                    arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
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
                          0,
                          true)
            } catch  {
                arSession(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func updateASession(_ id:String, _ latitude:Double, _ longitude:Double, _ altitude:Double, _ horizontalAccuracy:Double, _ verticalAccuracy:Double, _ course:Double, _ speed:Double, arSession: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "http://localhost:3000/sessions" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let postString = "latitude=\(latitude)&longitude=\(longitude)&altitude=\(altitude)&horizontalAccuracy=\(horizontalAccuracy)&verticalAccuracy=\(verticalAccuracy)&course=\(course)&speed=\(speed)"
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
        let url = URL(string: "http://localhost:3000/sessions" + "/" + id)!
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
            self.readASession(sessionId, arSession: {(latitude:Double, longitude:Double, altitude:Double, horizontalAccuracy:Double, verticalAccuracy:Double, course:Double, speed:Double, success:Bool) in
                

            })
        }
        else
        {
            self.createASession(latitude, longitude, altitude, horizontalAccuracy, verticalAccuracy, course, speed, arSession: {(id:String, success:Bool) in
                
                defaults.setValue(id, forKey: "sessionId")
                defaults.synchronize()
                
                

            })
        }
        
        
// TODO: - Send the current GPS location to the server.
// The RESTful response should be the stored gps location if there was a previous session or null if there is no session.
// If there is a previous session, find the gps location difference and convert it to matrix_float4x4;
// Then load all of the texts and draw it.
    }
    
    func listAllTexts(arText: @escaping (_ succeeded:Bool, _ texts:[String:Any]) -> ())
    {
        let url = URL(string: "http://localhost:3000/texts")!
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
                arText(false, [:])
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText(false, [:])
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let texts = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText(false, [:])
                        print("error trying to convert data to JSON")
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
        let url = URL(string: "http://localhost:3000/texts")!
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
        let url = URL(string: "http://localhost:3000/texts" + "/" + id)!
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "GET" //set http method as POST
        
        let task = session.dataTask(with: request) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                print("error calling GET on /texts")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let _arText = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        arText("", matrix_float4x4(diagonal: float4(1.0)), false)
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
                        arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                        print("Could not get todo title from JSON")
                        return
                    }
                    
                    if(sessionId == _sessionId)
                    {
                        // the todo object is a dictionary
                        // so we just access the title using the "title" key
                        // so check for a title and print it if we have one
                        guard let text = _arText["text"] as? String else {
                            arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                            print("Could not get todo title from JSON")
                            return
                        }
                        //                print("The text is: " + text)
                        
                        guard let transform = _arText["transform"] as? String else {
                            arText(text, matrix_float4x4(diagonal: float4(1.0)), false)
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
                        arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                    }
                }
                else
                {
                    arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                }
            } catch  {
                arText("", matrix_float4x4(diagonal: float4(1.0)), false)
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
    }
    
    func updateAText(_ id:String, _ text:String, _ transform: matrix_float4x4, arText: @escaping (_ succeeded:Bool) -> ())
    {
        let url = URL(string: "http://localhost:3000/texts" + "/" + id)!
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
        let url = URL(string: "http://localhost:3000/texts" + "/" + id)!
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
    
    func addRemoteARText(_ transform: matrix_float4x4)
    {
        let url = URL(string: "http://localhost:3000")!
        
        let parameters = ["transform":
            [
                transform.columns.0.x,
                transform.columns.0.y,
                transform.columns.0.z,
                transform.columns.0.w,
                
                transform.columns.1.x,
                transform.columns.1.y,
                transform.columns.1.z,
                transform.columns.1.w,
                
                transform.columns.2.x,
                transform.columns.2.y,
                transform.columns.2.z,
                transform.columns.2.w,
                
                transform.columns.3.x,
                transform.columns.3.y,
                transform.columns.3.z,
                transform.columns.3.w
            ]
        ]
        
        //create the session object
        let session = URLSession.shared
        
        //now create the URLRequest object using the url object
        var request = URLRequest(url: url)
        request.httpMethod = "POST" //set http method as POST
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            
            guard error == nil else {
                return
            }
            
            guard let data = data else {
                return
            }
            
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    print(json)
                    // handle json...
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
//        {
//            "transform" : [
//            1.0, 0.0, 0.0, 0.0,
//            0.0, 1.0, 0.0, 0.0,
//            0.0, 0.0, 1.0, 0.0,
//            0.0, 0.0, 0.0, 1.0
//            ]
//        }
        
// TODO: - Send the text's transform to the server, the server should return with an id, so that the user can edit the text.
        
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
    
    func test()
    {
        //https://stackoverflow.com/questions/26364914/http-request-in-swift-with-post-method
        //https://grokswift.com/simple-rest-with-swift/
        
        let todoEndpoint: String = "https://jsonplaceholder.typicode.com/todos/1"
        guard let url = URL(string: todoEndpoint) else {
            print("Error: cannot create URL")
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        
        let session = URLSession.shared
        
//        let task = session.dataTask(with: urlRequest, completionHandler:{ _, _, _ in })
//        let task = session.dataTask(with: urlRequest) { data, response, error in
//            // do stuff with response, data & error here
//            var d = data
//        }
        
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            // check for any errors
            guard error == nil else {
                print("error calling GET on /todos/1")
                print(error!)
                return
            }
            // make sure we got data
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            // parse the result as JSON, since that's what the API provides
            do {
                guard let todo = try JSONSerialization.jsonObject(with: responseData, options: [])
                    as? [String: Any] else {
                        print("error trying to convert data to JSON")
                        return
                }
                // now we have the todo
                // let's just print it to prove we can access it
                print("The todo is: " + todo.description)
                
                // the todo object is a dictionary
                // so we just access the title using the "title" key
                // so check for a title and print it if we have one
                guard let todoTitle = todo["title"] as? String else {
                    print("Could not get todo title from JSON")
                    return
                }
                print("The title is: " + todoTitle)
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        task.resume()
        
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
            self.startRemoteARSession()
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
