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
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        let sceneView = sender.view as! ARSCNView
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation)
        
        //以下、まともに動かず。
        let node = self.sceneView.scene.rootNode
        let imageSize = imageAnchor.referenceImage.physicalSize
        
        if !hitResults.isEmpty{
            let hitNode = hitResults.first
            //ショップボタンがこされた場合Safariを起動しオンラインショッピングのサイトへ遷移
            if hitNode?.node.name == "shopButton"
            {
                let url = URL(string: "http://sadoya-wine.com/fs/sadoya/red_wine/KT1675R")
                UIApplication.shared.open(url!)
            //ムービーボタンが押下された場合ムービーを再生
            }
            else if hitNode?.node.name == "movieButton"
            {
                let theNode = node.childNode(withName: "infoObj", recursively: true)
                theNode?.removeFromParentNode()//ここまでは機能している
                addMovieNode(node: node, imageSize: imageSize)
            }
            else if hitNode?.node.name == "infoButton"
            {
                let theNode = node.childNode(withName: "movieObj", recursively: true)
                theNode?.removeFromParentNode()//ここまでは機能している
                addInfoNode(node: node, imageSize: imageSize)
            }
        }
    }

    var imageAnchor: ARImageAnchor!

    /// Variable Declaration(s)
    var imageHighlightAction: SCNAction {
        return .sequence([
            //0.25秒一時停止
            .wait(duration: 0.25),
            //0.25秒かけて85％の透明度にする
            .fadeOpacity(to: 0.85, duration: 0.25),
            //0.25秒かけて15％の透明度にする
            .fadeOpacity(to: 0.15, duration: 0.25),
            //0.25秒かけて85％の透明度にする
            .fadeOpacity(to: 0.85, duration: 0.25),
            //0.5秒かけて透明度を0にして見えなくする
            .fadeOut(duration: 0.5),
            //このアクションに紐付いているノードを削除する
            .removeFromParentNode()
            ])
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
        let infoNode = SCNNode(geometry: infoPlane)
        infoNode.name =  "infoObj"
        //trueにすると表面のみ表示する
        infoNode.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        infoNode.eulerAngles.x = .pi / 2
        //原点を設定
        infoNode.position = SCNVector3Zero
        //気持ち透明にしてみる
        infoNode.opacity = 0.9
        //Aboutノードをシーンノードのチャイルドノードに追加
        node.addChildNode(infoNode)
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
        let movieNode = SCNNode(geometry: moviePlane)
        movieNode.name = "movieObj"
        //trueにすると表面のみ表示する
        movieNode.geometry?.firstMaterial?.isDoubleSided = true
        //またオイラー角で回転
        movieNode.eulerAngles.x = .pi / 2
        //原点を設定
        movieNode.position = SCNVector3Zero
        //気持ち透明にしてみる
        movieNode.opacity = 0.95
        //Movieノードをシーンノードのチャイルドノードに追加
        node.addChildNode(movieNode)
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

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        /// Casting down ARAnchor to `ARImageAnchor`.
        // ここでは情報を付与するロジックを追加
        // SpriteKit（２Dを扱う）とSceneKit(3Dを扱う）を利用。紛らわしい。
        //ここのイメージアンカーにはアセットカタログに配置した参照イメージのプロパティが含まれている
        imageAnchor =  anchor as? ARImageAnchor
        if  imageAnchor ==  anchor as? ARImageAnchor {
            
/*
            // create a web view
            let tvPlane = SCNPlane(width: 0.1, height: 0.1)
            tvPlane.firstMaterial?.diffuse.contents = self.webView
            tvPlane.firstMaterial?.isDoubleSided = true
            
            let tvPlaneNode = SCNNode(geometry: tvPlane)
            
            //trueにすると表面のみ表示する
            tvPlaneNode.geometry?.firstMaterial?.isDoubleSided = true
            //またオイラー角で回転
            tvPlaneNode.eulerAngles.x = -.pi / 2
            //原点を設定
            tvPlaneNode.position = SCNVector3Zero
            //気持ち透明にしてみる
            tvPlaneNode.opacity = 0.9
            //Aboutノードをシーンノードのチャイルドノードに追加
            node.addChildNode(tvPlaneNode)
            //アクション開始
            //アクションを設定。byは現在位置から指定分だけ移動に使用。
            //0.8秒でX軸方向に。0.25m移動する
            let move4Action = SCNAction.move(by: SCNVector3(0.1, 0, 0), duration: 0.1)
            //Aboutノードにアクションを設定して実行
            tvPlaneNode.runAction(move4Action, completionHandler: {
            })
*/
            
            //イメージサイズをリファレンスイメージのフィジカルサイズから取得
            let imageSize = imageAnchor.referenceImage.physicalSize
/*
            //SceneKitで平面を生成。サイズを取得したイメージのプロパティのサイズを設定
            //let plane = SCNPlane(width: CGFloat(imageSize.width), height: CGFloat(imageSize.height))
            let plane = SCNPlane(width: CGFloat(imageSize.width * 2.5), height: CGFloat(imageSize.height * 1.2))
            //ここではまだ平面に何も貼り付けられていないはずなのにテクスチャーの倍率調整を行なっている
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            //イメージ用Sceneノード生成
            let imageHightingAnimationNode = SCNNode(geometry: plane)
            //オイラー角で回転＿地平に平行なのでX軸（横軸）で90度回転
            imageHightingAnimationNode.eulerAngles.x = -.pi / 2
            //オブジェクトの透明度を設定。かなり透明にしている
            imageHightingAnimationNode.opacity = 0.25
            //イメージノードをシーンノードのチャイルドノードに追加
            node.addChildNode(imageHightingAnimationNode)
            
            //アニメーション実行
            imageHightingAnimationNode.runAction(imageHighlightAction) {
                
                imageHightingAnimationNode.opacity = 0
 */
                // InfoのSpriteKitのシーンを生成。用意されているAboutのシーンを利用
/*
                let infoSpriteKitScene = SKScene(fileNamed: "About")
                
                infoSpriteKitScene?.isPaused = false
 */
                //ここでAbout用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
                addMovieNode(node: node, imageSize: imageSize)
                // shop_buttonのSpriteKitのシーンを生成。用意されているAboutのシーンを利用
                let shopButtonSpriteKitScene = SKScene(fileNamed: "shop_button")
            
                shopButtonSpriteKitScene?.isPaused = false
                //ここでAbout用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
                //let shopButtonlane = SCNPlane(width: CGFloat(imageSize.width * 3), height: CGFloat(imageSize.height * 1.2))
                let shopButtonlane = SCNPlane(width: 0.12, height: 0.12)
                //テスクチャーとしてAboutシーンを設定
                shopButtonlane.firstMaterial?.diffuse.contents = shopButtonSpriteKitScene
                //テクスチャーのサイズ調整
                shopButtonlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                //About用ノード生成
                //let shopButtonNode = SCNNode(geometry: shopButtonlane)
                let shopButtonScene = SCNScene(named: "art.scnassets/shop_button.scn")!
            
                let shopButtonNode = shopButtonScene.rootNode.childNode(withName: "shopButton",recursively: true)
                shopButtonNode?.name = "shopButton"
                let movieButtonNode = shopButtonScene.rootNode.childNode(withName: "movieButton",recursively: true)
                movieButtonNode?.name = "movieButton"
                let infoButtonNode = shopButtonScene.rootNode.childNode(withName: "infoButton",recursively: true)
                infoButtonNode?.name = "infoButton"
            
                //let shopButtonNode = SCNNode(geometry: shopButtonScene)
                //trueにすると表面のみ表示する
                shopButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
                movieButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
                infoButtonNode!.geometry?.firstMaterial?.isDoubleSided = true
                //またオイラー角で回転
                shopButtonNode!.eulerAngles.x = -.pi / 2
                movieButtonNode!.eulerAngles.x = -.pi / 2
                infoButtonNode!.eulerAngles.x = -.pi / 2
                //原点を設定
                shopButtonNode!.position = SCNVector3Zero
                movieButtonNode!.position = SCNVector3Zero
                infoButtonNode!.position = SCNVector3Zero
                //気持ち透明にしてみる
                shopButtonNode!.opacity = 0.9
                movieButtonNode!.opacity = 0.9
                infoButtonNode!.opacity = 0.9
                //Aboutノードをシーンノードのチャイルドノードに追加
                node.addChildNode(shopButtonNode!)
                node.addChildNode(movieButtonNode!)
                node.addChildNode(infoButtonNode!)
                //アクション開始
                //アクションを設定。byは現在位置から指定分だけ移動に使用。
                //0.8秒でX軸方向に。0.25m移動する
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


                
    //        }
 
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
