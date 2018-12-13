//
//  ViewController.swift
//  ImageDetectionUsingARKit
//
//
import UIKit
import SceneKit
import ARKit
import AVKit
import AVFoundation
import WebKit

/// ViewController
class ViewController: UIViewController {
    
    /// IBOutlet(s)
    @IBOutlet var sceneView: ARSCNView!
    
    //変数定義
    var imageAnchor: ARImageAnchor!
    
    var shopButtonScene: SCNScene!
    //各種ボタン用ノード
    var shopButtonNode: SCNNode!
    var movieButtonNode: SCNNode!
    var scanButtonNode: SCNNode!
    var infoButtonNode: SCNNode!
    //各種プレーンノード
    var infoPlaneNode: SCNNode!
    var moviePlaneNode: SCNNode!
    var mainPlaneNode: SCNNode!
    var no1InfoPlaneNode: SCNNode!
    var no2InfoPlaneNode: SCNNode!
    var no3InfoPlaneNode: SCNNode!
    var no4InfoPlaneNode: SCNNode!
    var no5InfoPlaneNode: SCNNode!
    var no1MoviePlaneNode: SCNNode!
    var no3MoviePlaneNnode: SCNNode!
    var no4MoviePlaneNnode: SCNNode!
    //各種URL
    var shopUrl: URL!
    //var movieUrl: URL!
    
    //オブジェクトがタッチされた時の処理
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        //  let sceneViewSender = sender.view as! ARSCNViews
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation)
        //拡大
        let buttonAction1 = SCNAction.scale(by: 4, duration: 0.3)
        //縮小
        let buttonAction2 = SCNAction.scale(by: 0.25, duration: 0.3)
        
        // let node = sceneView.scene.rootNode
        if !hitResults.isEmpty{
            let hitNode = hitResults.first
            //ボタンが押されたらアクションを実行
            //ボタンを一瞬大きくして元のサイズに戻す
            hitNode?.node.runAction(
                SCNAction.group([
                    buttonAction1,
                    buttonAction2
                    ])
            )
            //ショップボタンがこされた場合Safariを起動しオンラインショッピングのサイトへ遷移
            if hitNode?.node.name == "shopButton"
            {
                self.videoPlayer.pause()
                shopUrl = URL(string: "http://sadoya-wine.com/fs/sadoya/red_wine/KT1675R")
                UIApplication.shared.open(shopUrl)
            }
                //ムービーボタンが押下された場合ムービーを再生
                //メインプレーンをムービープレーンに変更
            else if hitNode?.node.name == "movieButton"
            {
                self.videoPlayer.play()
                mainPlaneNode.removeFromParentNode()
                mainPlaneNode = moviePlaneNode
            }
                //Infoボタンが押された場合ムービーを一時停止
                //メインプレーンをInfoプレーンに変更
            else if hitNode?.node.name == "infoButton"
            {
                self.videoPlayer.pause()
                mainPlaneNode.removeFromParentNode()
                mainPlaneNode = infoPlaneNode
            }
                //scanボタンが押下された場合ムービーを一時停止
                //基本的にはセッションをリムーブするのが目的
            else if hitNode?.node.name == "scanButton"
            {
                self.videoPlayer.pause()
            }
        }
        //ボタン押下をトリガーに一旦セッションを削除
        //これで再度画像検索およびレンダリング処理が実行される
        sceneView.session.remove(anchor: imageAnchor)
        print("tap")
    }
    
    //動画プレイヤー定義
    let videoPlayer:AVPlayer = {
        //  let url = URL(string: "https://youtu.be/_D2_lTmG-6w")
        //動画パスベタ打ちなので要修正
        guard let url = Bundle.main.url(forResource:"sadoya",withExtension:"mp4",subdirectory:"art.scnassets")
            else {
                print("Could not find vide files")
                return AVPlayer()
        }
        return AVPlayer(url: url)
    }()
    
    /*
     //Web画面定義
     let webView:UIWebView = UIWebView(frame : CGRect(x: 0, y: 0, width: 320, height: 240))
     //  let request = URLRequest(url: URL(string: "https://www.suntory.co.jp/wine/nihon/wine-cellar/list_tominooka.html#lwt")!)
     let request = URLRequest(url: URL(string: "www.google.co.jp")!)
     */
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shopUrl = URL(string: "http://sadoya-wine.com/fs/sadoya/red_wine/KT1675R")
        
        shopButtonScene = SCNScene(named: "art.scnassets/shop_button.scn")!
        //各種ボタンノードへシーンファイルからオブジェクトを読み込み
        scanButtonNode = shopButtonScene.rootNode.childNode(withName: "scanButton",recursively: true)
        scanButtonNode?.name = "scanButton"
        shopButtonNode = shopButtonScene.rootNode.childNode(withName: "shopButton",recursively: true)
        shopButtonNode?.name = "shopButton"
        movieButtonNode = shopButtonScene.rootNode.childNode(withName: "movieButton",recursively: true)
        movieButtonNode?.name = "movieButton"
        infoButtonNode = shopButtonScene.rootNode.childNode(withName: "infoButton",recursively: true)
        infoButtonNode?.name = "infoButton"
        //各種Infoプレーン読み込み
        infoPlaneNode = shopButtonScene.rootNode.childNode(withName: "infoPlane", recursively: true)
        infoPlaneNode?.name = "infoPlane"
        no1InfoPlaneNode = shopButtonScene.rootNode.childNode(withName: "no1InfoPlane", recursively: true)
        no1InfoPlaneNode?.name = "no1InfoPlane"
        no2InfoPlaneNode = shopButtonScene.rootNode.childNode(withName: "no2InfoPlane", recursively: true)
        no2InfoPlaneNode?.name = "no2InfoPlane"
        no3InfoPlaneNode = shopButtonScene.rootNode.childNode(withName: "no4InfoPlane", recursively: true)
        no3InfoPlaneNode?.name = "no3InfoPlane"
        no4InfoPlaneNode = shopButtonScene.rootNode.childNode(withName: "no5InfoPlane", recursively: true)
        no4InfoPlaneNode?.name = "no4InfoPlane"
        no5InfoPlaneNode = shopButtonScene.rootNode.childNode(withName: "no7InfoPlane", recursively: true)
        no5InfoPlaneNode?.name = "no5InfoPlane"
        
        let moviePlane = SCNPlane(width: CGFloat(0.12), height: CGFloat(0.07))
        //テスクチャーとしてMovieシーンを設定
        moviePlane.firstMaterial?.diffuse.contents = self.videoPlayer
        //テクスチャーのサイズ調整
        moviePlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        //Movie用ノード生成
        moviePlaneNode = SCNNode(geometry: moviePlane)
        moviePlaneNode?.name = "moviePlane"
        
        //trueにすると表面のみ表示する
        scanButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        shopButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        movieButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        infoButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        
        infoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        moviePlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        no1InfoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        no2InfoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        no3InfoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        no4InfoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        no5InfoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        scanButtonNode!.eulerAngles.x = -.pi / 2
        shopButtonNode!.eulerAngles.x = -.pi / 2
        movieButtonNode!.eulerAngles.x = -.pi / 2
        infoButtonNode!.eulerAngles.x = -.pi / 2
        infoPlaneNode!.eulerAngles.x = -.pi / 2
        no1InfoPlaneNode!.eulerAngles.x = -.pi / 2
        no2InfoPlaneNode!.eulerAngles.x = -.pi / 2
        no3InfoPlaneNode!.eulerAngles.x = -.pi / 2
        no4InfoPlaneNode!.eulerAngles.x = -.pi / 2
        no5InfoPlaneNode!.eulerAngles.x = -.pi / 2
        //なぜかMovieだけ逆回転。なぜか。
        moviePlaneNode!.eulerAngles.x = .pi / 2
        //各種オブジェクトの座標設定
        scanButtonNode!.position = SCNVector3(-0.045, 0, 0.055)
        infoButtonNode!.position = SCNVector3(-0.015, 0, 0.055)
        movieButtonNode!.position = SCNVector3(0.015, 0, 0.055)
        shopButtonNode!.position = SCNVector3(0.045, 0, 0.055)
        infoPlaneNode!.position = SCNVector3Zero
        no1InfoPlaneNode!.position = SCNVector3Zero
        no2InfoPlaneNode!.position = SCNVector3Zero
        no3InfoPlaneNode!.position = SCNVector3Zero
        no4InfoPlaneNode!.position = SCNVector3Zero
        no5InfoPlaneNode!.position = SCNVector3Zero
        moviePlaneNode!.position = SCNVector3Zero
        //気持ち透明にしてみる
        shopButtonNode!.opacity = 0.9
        shopButtonNode!.opacity = 0.9
        movieButtonNode!.opacity = 0.9
        infoButtonNode!.opacity = 0.9
        infoPlaneNode!.opacity = 0.9
        no1InfoPlaneNode!.opacity = 0.9
        no2InfoPlaneNode!.opacity = 0.9
        no3InfoPlaneNode!.opacity = 0.9
        no4InfoPlaneNode!.opacity = 0.9
        no5InfoPlaneNode!.opacity = 0.9
        moviePlaneNode!.opacity = 0.9
        
        //初期表示には情報ノードを設定
        mainPlaneNode = infoPlaneNode
        
        /*
         //Webページ生成
         webView.scalesPageToFit = true
         webView.loadRequest(request)
         */
        prepareUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureARImageTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
}


// MARK: - UI Related Method(s)
extension ViewController {
    
    func prepareUI() {
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    //画像認識処理
    func configureARImageTracking() {
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        if let imageTrackingReference = ARReferenceImage.referenceImages(inGroupNamed: "iOSDept", bundle: Bundle.main) {
            configuration.trackingImages = imageTrackingReference
            configuration.maximumNumberOfTrackedImages = 1
        } else {
            print("Error: Failed to get image tracking referencing image from bundle")
        }
        // Run the view's session
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        print("tracking")
    }
}

// MARK: - UIButton Action(s)
extension ViewController {
    
    @IBAction func tapBtnRefresh(_ sender: UIButton) {
        configureARImageTracking()
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    //初期レンダリング処理
    //イメージを認識したときに実行される
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("didAdd")
        /// Casting down ARAnchor to `ARImageAnchor`.
        // ここでは情報を付与するロジックを追加
        // SpriteKit（２Dを扱う）とSceneKit(3Dを扱う）を利用。紛らわしい。
        //ここのイメージアンカーにはアセットカタログに配置した参照イメージのプロパティが含まれている
        imageAnchor =  anchor as? ARImageAnchor
        if  imageAnchor ==  anchor as? ARImageAnchor {
            //イメージサイズをリファレンスイメージのフィジカルサイズから取得
            //  let imageSize = imageAnchor.referenceImage.physicalSize
            //認識したラベルによってInfoPlaneのテクスチャを切り替える
            let labelName:String = imageAnchor.referenceImage.name!
            
            if labelName == "kuraonooto_label"{
                mainPlaneNode = no2InfoPlaneNode
            }
            else if labelName == "italico_label"{
                mainPlaneNode = no3InfoPlaneNode
            }
            else if labelName == "chateauBrillantMur_white_Label" {
                mainPlaneNode = no4InfoPlaneNode
            }
            else if labelName == "pipa_label"{
                mainPlaneNode = no5InfoPlaneNode
            }
            
            node.addChildNode(mainPlaneNode!)
            //各種ボタンノードをシーンノードのチャイルドノードに追加
            node.addChildNode(scanButtonNode!)
            node.addChildNode(shopButtonNode!)
            node.addChildNode(movieButtonNode!)
            node.addChildNode(infoButtonNode!)
            
            //mainPlaneアクション開始
            //1秒でフェードインする
            mainPlaneNode.opacity = 0
            let action = SCNAction.fadeIn(duration: 1)
            mainPlaneNode.runAction(action)
            print("renderer")
            
        } else {
            print("Error: Failed to get ARImageAnchor")
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        print("Error didFailWithError: \(error.localizedDescription)")
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        print("Error sessionWasInterrupted: \(session.debugDescription)")
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        print("Error sessionInterruptionEnded : \(session.debugDescription)")
    }
}
