//
//  ViewController.swift
//  ORAI_Feedback
//
//  Created by Chris Thompson on 11/19/17.
//  Copyright © 2017 Chris Thompson. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nuetral: UIImageView!
    
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var happy: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    
    var panGesture       = UIPanGestureRecognizer()

    
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
    
    @IBOutlet weak var recordings: UITableView!
    
    var stillOutput = AVCaptureStillImageOutput()
    var smiles = 0
    
    var totalSmiles = [""]
    var totalFaces = [""]
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var counter = 0
    var timer = Timer()
    var gameScore = PFObject(className:"GameScore")
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer : AVAudioPlayer!
    var soundSetting = [String : Int]()
    
    @IBOutlet weak var recordOutlet: UIButton!
    
    @IBOutlet weak var playButton: UIButton!
    
    func directoryURL() -> NSURL? {
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let soundURL = documentDirectory.appendingPathComponent("sound.m4a")
        print(soundURL)
        return soundURL as NSURL?
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func startRecording() {
        
        progress.isHidden = false
        
        let audioSession = AVAudioSession.sharedInstance()
        
        
        do {
            audioRecorder = try AVAudioRecorder(url: self.directoryURL()! as URL,
                                                settings: soundSetting)
            print(audioRecorder.url)
            
            audioRecorder.delegate = self
            audioRecorder.prepareToRecord()
            print("recording")
        } catch {
            finishRecording(success: false)
        }
        do {
            try audioSession.setActive(true)
            audioRecorder.record()
        } catch {
        }
        
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        progress.isHidden = true
        happy.isHidden = true
        nuetral.isHidden = true
        self.faceLabel.isHidden = true

        

        
        if success {
            recordOutlet.setTitle("Tap to Re-record", for: .normal)
            print("success")
        } else {
            recordOutlet.setTitle("Tap to Record", for: .normal)
            // recording failed :(
        }
    }
    
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    @objc func timerAction() {
        counter += 1
        let x = (Double(self.totalSmiles.count) / Double(self.totalFaces.count as Int)) * 100

    }

    @IBAction func recordAction(_ sender: Any) {
        if audioRecorder == nil {
            totalSmiles = [""]
            totalFaces = [""]
            startRecording()
            timerLabel.text = "Recording"
            
            timer.invalidate() // just in case this button is tapped multiple times
            counter = 0
            // start the timer
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
        

            captureSession?.startRunning()
            videoPreviewLayer?.isHidden = false


            if let image = UIImage(named: "icons8-stop-120.png") {
                
                self.recordOutlet.setImage(image, for: .normal)
                UIView.animate(withDuration: 2.0,
                               delay: 0,
                               usingSpringWithDamping: 0.2,
                               initialSpringVelocity: 6.0,
                               options: .allowUserInteraction,
                               animations: { [weak self] in
                                self?.recordOutlet.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                                
                    },
                               completion: nil)
            }
            
        } else {
            finishRecording(success: true)
            timer.invalidate()
            activity.startAnimating()
            videoPreviewLayer?.isHidden = true
            if let image = UIImage(named: "icons8-microphone-250.png") {
                self.recordOutlet.setImage(image, for: .normal)
                self.playButton.isHidden = false
                do {
                    let audioData = try Data(contentsOf: audioRecorder.url as URL)
                    let file = PFFile(name:"audio.m4a", data:audioData)
                    file?.saveInBackground(block: { (success, error) in
                        if success == true && error == nil{
                            self.audioRecorder = nil
                            PFUser.current()!["currentAudio"] = file
                            PFUser.current()!.saveInBackground(block: { (success, error) in
                                if success == true && error == nil {
                                    self.performSegue(withIdentifier: "nameSong", sender: self)
                                    print(PFUser.current()!["currentAudio"])
                                    self.activity.stopAnimating()

                                } else {
                                    let alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    self.activity.stopAnimating()

                                }
                            })
                            
                        }
                    })

                    
                } catch {
                    print("Unable to load data: \(error)")
                }

            }
            UIView.animate(withDuration: 2.0,
                           delay: 0,
                           usingSpringWithDamping: 0.2,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: { [weak self] in
                            self?.recordOutlet.transform = .identity
                            
                },
                           completion: nil)
        }
    }
    
    
    
    @IBAction func playAction(_ sender: Any) {
      
        if self.audioRecorder != nil {
        
        self.audioPlayer = try! AVAudioPlayer(contentsOf: audioRecorder.url)
        self.audioPlayer.prepareToPlay()
        self.audioPlayer.delegate = self
        self.audioPlayer.play()
        
    }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int)  -> Int {
        
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell=UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "mycell")

        return cell
    }
    
    
    func exifOrientation(orientation: UIDeviceOrientation) -> Int {
        switch orientation {
        case .portraitUpsideDown:
            return 8
        case .landscapeLeft:
            return 3
        case .landscapeRight:
            return 1
        default:
            return 6
        }
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        self.view.bringSubview(toFront: self.cameraView)
        let translation = sender.translation(in: self.view)
        cameraView.center = CGPoint(x: self.cameraView.center.x + translation.x, y: self.cameraView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        cameraView.layer.borderWidth = 3
        
        progress.transform = progress.transform.scaledBy(x: 1, y: 10)
        
        
        cameraView.layer.borderColor = UIColor.white.cgColor
        let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: AVCaptureDevice.Position.front)

        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = cameraView.layer.bounds
            cameraView.layer.addSublayer(videoPreviewLayer!)
            cameraView.addSubview(recordOutlet)
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : NSNumber(value: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
            
            output.alwaysDiscardsLateVideoFrames = true
            
            if (captureSession?.canAddOutput(output))! {
                captureSession?.addOutput(output)
            }
            
            captureSession?.commitConfiguration()
            
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue)

            
            

        } catch {
            print(error)
        }
        

        
        cameraView.layer.cornerRadius = cameraView.frame.height / 2.0
        cameraView.layer.masksToBounds = true
        
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.draggedView(_:)))
        cameraView.isUserInteractionEnabled = true
        cameraView.addGestureRecognizer(panGesture)
        

        
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.recordOutlet.isHidden = false
                        self.recordOutlet.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                        
                        UIView.animate(withDuration: 2.0,
                                       delay: 0,
                                       usingSpringWithDamping: 0.2,
                                       initialSpringVelocity: 6.0,
                                       options: .allowUserInteraction,
                                       animations: { [weak self] in
                                        self?.recordOutlet.transform = .identity
                                        
                            },
                                       completion: nil)
                        
                        
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        soundSetting = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
        let options: [String : Any] = [CIDetectorImageOrientation: exifOrientation(orientation: UIDevice.current.orientation),
                                       CIDetectorSmile: true,
                                       CIDetectorEyeBlink: true]
        
        let allFeatures = faceDetector?.features(in: ciImage, options: options)
        DispatchQueue.main.async {
            
            if self.videoPreviewLayer?.isHidden != true {

                self.happy.isHidden = false

                self.faceLabel.isHidden = false
                self.nuetral.isHidden = false
                let x = (Double(self.totalSmiles.count) / Double(self.totalFaces.count as Int))

                
                self.progress.progress = Float(x)

                

            }
        }
        let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer)
        let cleanAperture = CMVideoFormatDescriptionGetCleanAperture(formatDescription!, false)
        guard let features = allFeatures else {

            return
            
        }
        
        for feature in features {
            if let faceFeature = feature as? CIFaceFeature {
                DispatchQueue.main.async {
                    if self.videoPreviewLayer?.isHidden != true {
                        self.faceLabel.isHidden = true

                if faceFeature.hasSmile == true && faceFeature.hasMouthPosition == true{

                        self.happy.isHidden = false
                    self.smiles += 1
                    self.totalSmiles.append("smile")
                    self.totalFaces.append("noSmile")


                } else {
                        self.totalFaces.append("noSmile")

                        
                        }
                    
                    
                }
                }
            }
            
            
        }
    }
}
