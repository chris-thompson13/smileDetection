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
    @IBOutlet weak var tapOutlet: UILabel!
    @IBOutlet weak var statsView: UIView!
    @IBOutlet weak var faceLabel: UILabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var percent: UILabel!
    @IBOutlet weak var happy: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var cameraView: UIView!
    
    var output = AVCaptureVideoDataOutput()

    
    
    var panGesture       = UIPanGestureRecognizer()

    @IBOutlet weak var counter: UILabel!
    
    @IBOutlet weak var counterView: UIView!
    
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
    
    @IBOutlet weak var recordings: UITableView!
    
    var stillOutput = AVCaptureStillImageOutput()
    var smiles = 0
    let movieOutput = AVCaptureMovieFileOutput()
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    var totalSmiles = [""]
    var totalFaces = [""]
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var counterInt = 0
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
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
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
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        progress.isHidden = true
        happy.isHidden = true
        nuetral.isHidden = true
        self.faceLabel.isHidden = true


        

        
        if success {
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
        self.cameraView.translatesAutoresizingMaskIntoConstraints = true
        counterInt += 1
        let x = (Double(self.totalSmiles.count) / Double(self.totalFaces.count as Int)) * 100
        if counterInt < 10 {
            let seconds = "0" + String(counterInt + 00)
            counter.text = String(counterInt/60 + 00) + ":" + seconds

        } else {
        counter.text = String(counterInt/60 + 00) + ":" + String(counterInt + 00)
        }
    }
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    

    
    func recordVideo(){
        if movieOutput.isRecording == false {

        let connection = movieOutput.connection(with: AVMediaType.video)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = currentVideoOrientation()
        }
        
        if (connection?.isVideoStabilizationSupported)! {
            connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
        }
        
        let device = activeInput.device
        if (device.isSmoothAutoFocusSupported) {
            do {
                try device.lockForConfiguration()
                device.isSmoothAutoFocusEnabled = false
                device.unlockForConfiguration()
            } catch {
                print("Error setting configuration: \(error)")
            }
            
        }
        outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self as! AVCaptureFileOutputRecordingDelegate)
        } else {
            captureSession?.addOutput(movieOutput)
            movieOutput.stopRecording()
            print("finishedRecording")

        }
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
        
    }
    
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            
            _ = outputURL as URL
            
        }
        outputURL = nil
    }
    
    



    @IBAction func recordAction(_ sender: Any) {
        

        if audioRecorder == nil {
            

            let smileAlert = UIAlertController(title: "Smile Detector", message: "Please make sure you are in good lighting and your full face is in the view", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                
                self.totalSmiles = [""]
                self.totalFaces = [""]
                self.startRecording()
                self.timerLabel.text = "Recording"
                
                self.statsView.isHidden = false

                
                self.timer.invalidate() // just in case this button is tapped multiple times
                self.counterInt = 0
                // start the timer
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true)
                
                
                self.videoQueue().async {
                    self.captureSession?.startRunning()
                    UIView.animate(withDuration: 1.5, animations: {
                        self.cameraView.transform = CGAffineTransform( translationX: 0.0, y: 300.0 )
                        self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                        self.counterView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                        self.tapOutlet.transform = CGAffineTransform( translationX: 400.0, y: 0.0 )

                        self.view.bringSubview(toFront: self.cameraView)
                    })
                }
                self.videoPreviewLayer?.isHidden = false
                
                
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
                
                
                
            }
            smileAlert.addAction(okAction)
            present(smileAlert, animated: true, completion: nil)

            
        } else {
            finishRecording(success: true)
            timer.invalidate()
            activity.isHidden = false
            activity.startAnimating()
            view.isUserInteractionEnabled = false
            
            UIView.animate(withDuration: 1.5, animations: {
                self.cameraView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                self.view.bringSubview(toFront: self.cameraView)
                self.counterView.transform = CGAffineTransform( translationX: -500.0, y: 0.0 )
                self.tapOutlet.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )

                
                self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 800.0 )
                
                
            })

            videoPreviewLayer?.isHidden = true
            if let image = UIImage(named: "icons8-microphone-250.png") {
                self.recordOutlet.setImage(image, for: .normal)
                do {
                    let audioData = try Data(contentsOf: audioRecorder.url as URL)
                    let videoData = try Data(contentsOf: audioRecorder.url as URL)
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
                                    self.activity.isHidden = true
                                    self.view.isUserInteractionEnabled = true



                                } else {
                                    let alert = UIAlertController(title: "Error", message: error as? String, preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                    self.activity.stopAnimating()
                                    self.activity.isHidden = true
                                    self.view.isUserInteractionEnabled = true

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

    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 800.0 )
        
        self.counterView.transform = CGAffineTransform( translationX: -400.0, y: 0.0 )
        
            
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
        if (captureSession?.canAddOutput(output))!{
        captureSession?.addOutput(output)
        }
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
                let x = (Double(self.totalSmiles.count as Int + 30) / Double(self.totalFaces.count))
                
                
                self.progress.progress = Float(x)
                if x > 60 {
                    self.progress.progressTintColor = UIColor.green
                }

                

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
