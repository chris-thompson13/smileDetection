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
import Foundation
import AVKit
import Dispatch
import AssetsLibrary

class ViewController: UIViewController, AVAudioRecorderDelegate, AVCaptureFileOutputRecordingDelegate, AVAudioPlayerDelegate, UITableViewDelegate, UITableViewDataSource {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
    }
    
    
    @IBOutlet weak var smileView: UILabel!
    
    @IBOutlet weak var smileView2: UIView!
    
    @IBOutlet weak var smileScore: UILabel!
    
    var newCounter = 0.0
    
    
    @IBOutlet weak var showStats: UIView!
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
    
    var first = true
    
    var output = AVCaptureVideoDataOutput()
    
    
    var minCounter = 0
    
    
    var panGesture = UIPanGestureRecognizer()
    
    @IBOutlet weak var counter: UILabel!
    
    @IBOutlet weak var counterView: UIView!
    
    let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyLow])
    
    @IBOutlet weak var recordings: UITableView!
    
    var input = AVAssetWriter.self
    var stillOutput = AVCaptureStillImageOutput()
    var urlString: NSURL!
    var fileWriter: AVAssetWriter!
    var videoOutputSettings = [String : AnyObject]()
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    var videoInput: AVAssetWriterInput!
    var audioInput: AVAssetWriterInput!
    
    
    
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
    var soundSetting = [String : AnyObject]()
    
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
    
    func videUrl() -> NSURL? {
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as NSURL
        let video = documentDirectory.appendingPathComponent("speech.mp4")
        print(video)
        
        return video as NSURL?
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
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func finishRecording(success: Bool) {
        
        
        if success {
            audioRecorder.stop()
            captureSession?.stopRunning()
            DispatchQueue.main.async {
                
                print("file writer status", self.fileWriter.status.rawValue)
                
                
                self.fileWriter.finishWriting(completionHandler: {
                    
                    
                    
                    do {
                        
                        
                        
                        if PFUser.current() != nil {
                            
                            let data = try Data(contentsOf: self.urlString as URL)
                            let file = PFFile(name:"video.mp4", data:data)
                            PFUser.current()!["currentVideo"] = file
                            PFUser.current()?.saveInBackground()
                            
                        }
                        
                        
                    } catch {
                        
                        print(error)
                    }
                    
                    
                })
                
            }
            progress.isHidden = true
            happy.isHidden = true
            nuetral.isHidden = true
            self.faceLabel.isHidden = true
            tapOutlet.text = "tap to re-record"
            
            
            
            
            
        } else {
            recordOutlet.setTitle("Tap to record", for: .normal)
            // recording failed :(
        }
    }
    
    
    
    
    
    
    @objc func timerAction() {
        self.cameraView.translatesAutoresizingMaskIntoConstraints = true
        counterInt += 1
        minCounter += 1
        let x = (Double(self.totalSmiles.count) / Double(self.totalFaces.count as Int)) * 100
        
        if counterInt > 59 {
            counterInt = 0
            
        }
        if counterInt < 10 {
            let seconds = "0" + String(counterInt + 00)
            counter.text = String(counterInt/60 + 00) + ":" + seconds
            
            
        } else {
            counter.text = String(minCounter/60 + 00) + ":" + String(counterInt + 00)
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
    
    
    
    
    
    
    func degreeToRadian(_ x: CGFloat) -> CGFloat {
        return .pi * x / 180.0
    }
    
    func animatePercentage(){
        let percentage = (Double(self.totalSmiles.count as Int + (self.totalFaces.count/5)) / Double(self.totalFaces.count))
        self.smileScore.text = "0"
        if newCounter < percentage {
            
            newCounter += 1
            
            let x = (Double(self.totalSmiles.count as Int + (self.totalFaces.count/5)) / Double(self.totalFaces.count))
            let y = (x * 100).rounded()
            
            self.smileScore.text = String(format: "%.0f", y) + "%"
            let when = DispatchTime.now() + 0.01
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animatePercentage()
            }
            
            
            
            
        }
    }
    
    
    @IBAction func recordAction(_ sender: Any) {
        
        
        
        
        if audioRecorder == nil {
            counter.text = "00:00"
            
            newCounter = 0.0
            
            reset()
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
            self.videoQueue().async {
                self.captureSession?.startRunning()
                UIView.animate(withDuration: 1.0, animations: {
                    self.cameraView.transform = CGAffineTransform( translationX: 0.0, y: 300.0 )
                    self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                    self.counterView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                    self.tapOutlet.transform = CGAffineTransform( translationX: 400.0, y: 0.0 )
                    self.smileView2.transform = CGAffineTransform( translationX: 800.0, y: 0.0 )
                    
                    
                    self.view.bringSubview(toFront: self.cameraView)
                })
            }
            
            
            fileWriter.add(videoInput)
            fileWriter.add(audioInput)
            
            fileWriter.startWriting()
            
            
            
            print("test1")
            
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
                
                
                
                self.videoPreviewLayer?.isHidden = false
                self.cameraView.layer.addSublayer(self.videoPreviewLayer!)
                self.cameraView.addSubview(self.recordOutlet)
                self.recordOutlet.backgroundColor = UIColor.clear
                
                
                
                
                
            }
            smileAlert.addAction(okAction)
            present(smileAlert, animated: true, completion: nil)
            
            
        } else {
            
            finishRecording(success: true)
            timer.invalidate()
            activity.frame = CGRect(origin: .zero, size: CGSize(width: 100, height: 100))
            activity.isHidden = false
            activity.color = UIColor.white
            activity.startAnimating()
            view.isUserInteractionEnabled = false
            
            
            
            
            
            UIView.animate(withDuration: 1.5, animations: {
                self.cameraView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                self.view.bringSubview(toFront: self.cameraView)
                self.counterView.transform = CGAffineTransform( translationX: -500.0, y: 0.0 )
                self.tapOutlet.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                self.smileView2.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                
                
                self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 0.0 )
                
                
            })
            
            videoPreviewLayer?.isHidden = true
            if let image = UIImage(named: "icons8-microphone-250.png") {
                self.recordOutlet.setImage(image, for: .normal)
                self.recordOutlet.backgroundColor = UIColor.white
                
                do {
                    
                    
                    let audioData = try Data(contentsOf: audioRecorder.url as URL)
                    let file = PFFile(name:"audio.m4a", data:audioData)
                    
                    file?.saveInBackground()
                    
                    if PFUser.current() != nil {
                        
                        print(file!)
                        PFUser.current()!["currentAudio"] = file
                        PFUser.current()!.saveInBackground()
                        
                    }
                    //self.performSegue(withIdentifier: "nameSong", sender: self)
                    let when = DispatchTime.now() + 2
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        let player = AVPlayer(url: self.urlString as URL)
                        let playerLayer = AVPlayerLayer(player: player)
                        let affineTransform = CGAffineTransform(rotationAngle: self.degreeToRadian(90))
                        playerLayer.setAffineTransform(affineTransform)
                        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
                        print("play")
                        playerLayer.frame = self.cameraView.bounds
                        self.cameraView.layer.addSublayer(playerLayer)
                        player.play()
                        
                    }
                    
                    let audio = DispatchTime.now() + 3
                    DispatchQueue.main.asyncAfter(deadline: audio) {
                        self.audioPlayer = try! AVAudioPlayer(contentsOf: self.audioRecorder.url)
                        do {
                            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                        } catch {
                        }
                        self.audioPlayer.prepareToPlay()
                        self.audioPlayer.delegate = self
                        self.audioPlayer.play()
                        
                        self.activity.stopAnimating()
                        self.activity.isHidden = true
                        self.view.isUserInteractionEnabled = true
                        self.audioRecorder = nil
                        
                    }
                    
                    
                    
                    
                    
                    
                    
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
    
    
    
    
    func reset(){
        
        totalFaces = [""]
        totalSmiles = [""]
        soundSetting = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC) as AnyObject,
            AVNumberOfChannelsKey : 1 as AnyObject,
            AVSampleRateKey : 44100 as AnyObject,
            AVEncoderBitRateKey : 128000 as AnyObject
        ]
        videoOutputSettings = [
            AVVideoCodecKey : AVVideoCodecH264 as AnyObject,
            AVVideoHeightKey : self.view.frame.width as AnyObject,
            AVVideoWidthKey : self.view.frame.height as AnyObject
        ]
        urlString = self.videUrl()
        
        if FileManager().fileExists(atPath: urlString.path!) {
            do {
                
                
                print("The file already exists at path")
                try FileManager().removeItem(atPath: urlString.path!)
            } catch {
                
            }
            
        } else {
            
        }
        videoInput = try? AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        
        audioInput = try? AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: soundSetting)
        audioInput.expectsMediaDataInRealTime = true
        
        
        print(urlString as URL)
        fileWriter = try? AVAssetWriter(url: urlString as URL, fileType: AVFileType.mov)
    }
    
    func mergeFilesWithUrl(videoUrl:URL, audioUrl:URL)
    {
        let mixComposition : AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        
        //start merge
        
        let aVideoAsset : AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset : AVAsset = AVAsset(url: audioUrl)
        
        mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
        
        let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
        let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
        
        
        
        do{
            try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
            
            //In my case my audio file is longer then video file so i took videoAsset duration
            //instead of audioAsset duration
            
            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
            
            //Use this instead above line if your audiofile and video file's playing durations are same
            
            //            try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), ofTrack: aAudioAssetTrack, atTime: kCMTimeZero)
            
        }catch{
            
        }
        
        totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration )
        
        let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
        
        mutableVideoComposition.renderSize = CGSize(width: 1280, height: 720)
        //        playerItem = AVPlayerItem(asset: mixComposition)
        //        player = AVPlayer(playerItem: playerItem!)
        //
        //
        //        AVPlayerVC.player = player
        
        //find your video on this URl
        let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/newVideo.mp4")
        
        let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
        assetExport.outputFileType = AVFileType.mp4
        assetExport.outputURL = savePathUrl
        assetExport.shouldOptimizeForNetworkUse = true
        
        assetExport.exportAsynchronously { () -> Void in
            switch assetExport.status {
                
            case AVAssetExportSessionStatus.completed:
                
                //Uncomment this if u want to store your video in asset
                
                //let assetsLib = ALAssetsLibrary()
                //assetsLib.writeVideoAtPathToSavedPhotosAlbum(savePathUrl, completionBlock: nil)
                
                print("success")
            case  AVAssetExportSessionStatus.failed:
                print("failed \(String(describing: assetExport.error))")
            case AVAssetExportSessionStatus.cancelled:
                print("cancelled \(String(describing: assetExport.error))")
            default:
                print("complete")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        first = true
        self.statsView.transform = CGAffineTransform( translationX: 0.0, y: 800.0 )
        
        self.counterView.transform = CGAffineTransform( translationX: -400.0, y: 0.0 )
        
        self.smileView2.transform = CGAffineTransform( translationX: 800.0, y: 0.0 )
        
        
        
        cameraView.layer.borderWidth = 3
        
        progress.transform = progress.transform.scaledBy(x: 1, y: 10)
        
        
        if PFUser.current() == nil {
            
            let user = PFUser()
            user.username = randomString(length: 7)
            user.password = "password"
            
            user.signUpInBackground()
            
        }
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
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
}







extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ captureOutput: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        
        
        if let _ = captureOutput as? AVCaptureVideoDataOutput {
            
            if CMSampleBufferDataIsReady(sampleBuffer) {
                
                if fileWriter.status.rawValue != 0 {
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    
                    fileWriter.startSession(atSourceTime: startTime)
                    videoInput.append(sampleBuffer)
                }
            }
        }
        
        if let _ = captureOutput as? AVCaptureAudioDataOutput {
            
            if CMSampleBufferDataIsReady(sampleBuffer) {
                
                if fileWriter.status.rawValue != 0 {
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    
                    fileWriter.startSession(atSourceTime: startTime)
                    audioInput.append(sampleBuffer)
                }
            }
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
                let x = (Double(self.totalSmiles.count as Int + (self.totalFaces.count/5)) / Double(self.totalFaces.count))
                
                
                let y = (x * 100).rounded()
                
                
                
                
                self.smileScore.text = String(format: "%.0f", y) + "%"
                
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
