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
    
    var imageAnchor: ARImageAnchor!
    var shopButtonScene: SCNScene!
    var shopButtonNode: SCNNode!
    var movieButtonNode: SCNNode!
    var infoButtonNode: SCNNode!
    var infoPlaneNode: SCNNode!
    var moviePlaneNode: SCNNode!
    var mainPlaneNode: SCNNode!
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
      //  let sceneViewSender = sender.view as! ARSCNViews
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation)
        
       
        
        //以下、まともに動かず。
       // let node = sceneView.scene.rootNode
        if !hitResults.isEmpty{
            let hitNode = hitResults.first
            //ショップボタンがこされた場合Safariを起動しオンラインショッピングのサイトへ遷移
            if hitNode?.node.name == "shopButton"
            {
                self.videoPlayer.pause()
                let url = URL(string: "http://sadoya-wine.com/fs/sadoya/red_wine/KT1675R")
                UIApplication.shared.open(url!)
            //ムービーボタンが押下された場合ムービーを再生
            }
            else if hitNode?.node.name == "movieButton"
            {
                self.videoPlayer.play()
                mainPlaneNode.removeFromParentNode()
                mainPlaneNode = moviePlaneNode
            }
            else if hitNode?.node.name == "infoButton"
            {
                self.videoPlayer.pause()
                mainPlaneNode.removeFromParentNode()
                mainPlaneNode = infoPlaneNode
            }
        }
         sceneView.session.remove(anchor: imageAnchor)
    }
    
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
        
        let moviePlane = SCNPlane(width: CGFloat(0.1), height: CGFloat(0.06))
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
        // create a web view
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
    
    //ワインの情報を表示するNodeを生成
    func addInfoNode(node: SCNNode, imageSize: CGSize){

        let infoPlane = SCNPlane(width: CGFloat(imageSize.width * 5), height: CGFloat(imageSize.height * 1.2))
        //テスクチャーとしてAboutシーンを設定
        infoPlane.firstMaterial?.diffuse.contents = UIImage(named: "art.scnassets/koutetsu100info.png")
        //テクスチャーのサイズ調整
        infoPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        //About用ノード生成
        infoPlaneNode = SCNNode(geometry: infoPlane)
        infoPlaneNode.name =  "infoObj"
        //trueにすると表面のみ表示する
        infoPlaneNode.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        infoPlaneNode.eulerAngles.x = .pi / 2
        //原点を設定
        infoPlaneNode.position = SCNVector3Zero
        //気持ち透明にしてみる
        infoPlaneNode.opacity = 0.9
        //Aboutノードをシーンノードのチャイルドノードに追加
        //sceneView.scene.rootNode.addChildNode(infoNode)
        node.addChildNode(infoPlaneNode)
    }
    
    //ムービーを表示するNodeを生成
    func addMovieNode(node:SCNNode,imageSize:CGSize){
        // MovieのSpriteKitのシーンを生成。用意されているMovieのシーンを利用
        //let movieSpriteKitScene = SKScene(fileNamed: "Movie")
        
        //movieSpriteKitScene?.isPaused = false
        //ここでMovie用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
        let moviePlane = SCNPlane(width: CGFloat(imageSize.width * 4), height: CGFloat(imageSize.height * 1))
        //テスクチャーとしてMovieシーンを設定
        moviePlane.firstMaterial?.diffuse.contents = self.videoPlayer
        self.videoPlayer.play()
        //テクスチャーのサイズ調整
        moviePlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
        //Movie用ノード生成
        moviePlaneNode = SCNNode(geometry: moviePlane)
        moviePlaneNode.name = "movieObj"
        //trueにすると表面のみ表示する
        moviePlaneNode.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        moviePlaneNode.eulerAngles.x = .pi / 2
        //原点を設定
        moviePlaneNode.position = SCNVector3Zero
        //気持ち透明にしてみる
        moviePlaneNode.opacity = 0.95
        //Movieノードをシーンノードのチャイルドノードに追加
        //sceneView.scene.rootNode.addChildNode(movieNode)
        node.addChildNode(moviePlaneNode)
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

    //初期ノード配置
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

            //ここでAbout用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
 //           addInfoNode(node: node, imageSize: imageSize)
            node.addChildNode(mainPlaneNode!)
            //Aboutノードをシーンノードのチャイルドノードに追加
            node.addChildNode(shopButtonNode!)
            node.addChildNode(movieButtonNode!)
            node.addChildNode(infoButtonNode!)
            //アクション開始
            //アクションを設定。byは現在位置から指定分だけ移動に使用。
            //0.8秒でX軸方向に。0.25m移動する
            /*
            let move4Action = SCNAction.move(by: SCNVector3(-0.03, 0, 0.055), duration: 0.8)
            let move5Action = SCNAction.move(by: SCNVector3(0, 0, 0.055), duration: 0.8)
            let move6Action = SCNAction.move(by: SCNVector3(0.03, 0, 0.055), duration: 0.8)
            //Aboutノードにアクションを設定して実行
            infoButtonNode!.runAction(move4Action, completionHandler: {
            })
            movieButtonNode!.runAction(move5Action, completionHandler: {
            })
            shopButtonNode!.runAction(move6Action, completionHandler: {
            })
            */
            
            //sceneView.session.remove(anchor: anchor)
 
        } else {
            print("Error: Failed to get ARImageAnchor")
        }
    }
/*
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
     //   node.addChildNode(moviePlaneNode!)
      //  node.
        shopButtonScene.rootNode.renderingOrder()
    }
 */

    
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
