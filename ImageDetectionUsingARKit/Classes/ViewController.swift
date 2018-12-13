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
    var shopUrl: URL!
    var movieUrl: URL!
    
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
                UIApplication.shared.open(shopUrl!)
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
         //これで再度レンダリング処理が実行される
         sceneView.session.remove(anchor: imageAnchor)
    }
    
    //動画プレイヤー定義
    let videoPlayer:AVPlayer = {
      //  let url = URL(string: "https://youtu.be/_D2_lTmG-6w")
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
        
        shopButtonScene = SCNScene(named: "art.scnassets/shop_button.scn")!
        
        
        shopButtonNode = shopButtonScene.rootNode.childNode(withName: "shopButton",recursively: true)
        shopButtonNode?.name = "shopButton"
        movieButtonNode = shopButtonScene.rootNode.childNode(withName: "movieButton",recursively: true)
        movieButtonNode?.name = "movieButton"
        infoButtonNode = shopButtonScene.rootNode.childNode(withName: "infoButton",recursively: true)
        infoButtonNode?.name = "infoButton"
        infoPlaneNode = shopButtonScene.rootNode.childNode(withName: "infoPlane", recursively: true)
        infoPlaneNode?.name = "infoPlane"
        
        let moviePlane = SCNPlane(width: CGFloat(0.12), height: CGFloat(0.07))
        //テスクチャーとしてMovieシーンを設定
        moviePlane.firstMaterial?.diffuse.contents = self.videoPlayer
        //テクスチャーのサイズ調整
        moviePlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        //Movie用ノード生成
        moviePlaneNode = SCNNode(geometry: moviePlane)
        moviePlaneNode?.name = "moviePlane"
        
        //trueにすると表面のみ表示する
        shopButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        movieButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        infoButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
        infoPlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        moviePlaneNode!.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        shopButtonNode!.eulerAngles.x = -.pi / 2
        movieButtonNode!.eulerAngles.x = -.pi / 2
        infoButtonNode!.eulerAngles.x = -.pi / 2
        infoPlaneNode!.eulerAngles.x = -.pi / 2
        //なぜかMovieだけ逆回転
        moviePlaneNode!.eulerAngles.x = .pi / 2
        //原点を設定
        shopButtonNode!.position = SCNVector3(0.03, 0, 0.055)
        movieButtonNode!.position = SCNVector3(0, 0, 0.055)
        infoButtonNode!.position = SCNVector3(-0.03, 0, 0.055)
        infoPlaneNode!.position = SCNVector3Zero
        moviePlaneNode!.position = SCNVector3Zero
        //気持ち透明にしてみる
        shopButtonNode!.opacity = 0.9
        movieButtonNode!.opacity = 0.9
        infoButtonNode!.opacity = 0.9
        infoPlaneNode!.opacity = 0.9
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
            let infoPlane = SCNPlane(width: CGFloat(0.12), height: CGFloat(0.07))
            switch imageAnchor.referenceImage.name {
            case "koutetsu100_label":
                infoPlane.firstMaterial?.diffuse.contents = UIImage(named: "koutetsu100info.png")
                infoPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                infoPlaneNode = SCNNode(geometry: infoPlane)
            case "chateauBrillantMur_white_Label":
                infoPlane.firstMaterial?.diffuse.contents = UIImage(named: "chateauBrillantMur_whiteInfo.png")
                infoPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                infoPlaneNode = SCNNode(geometry: infoPlane)
            default: break
            }

            node.addChildNode(mainPlaneNode!)
            //Aboutノードをシーンノードのチャイルドノードに追加
            node.addChildNode(shopButtonNode!)
            node.addChildNode(movieButtonNode!)
            node.addChildNode(infoButtonNode!)
            
            //mainPlaneアクション開始
            //1秒でフェードインする
            mainPlaneNode.opacity = 0
            let action = SCNAction.fadeIn(duration: 1)
            mainPlaneNode.runAction(action)
 
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
