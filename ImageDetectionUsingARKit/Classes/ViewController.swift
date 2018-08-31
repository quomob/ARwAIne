//
//  ViewController.swift
//  ImageDetectionUsingARKit
//
//  Created by Yudiz on 25/06/18.
//  Copyright © 2018 Yudiz. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

/// ViewController
class ViewController: UIViewController {
    
    /// IBOutlet(s)
    @IBOutlet var sceneView: ARSCNView!
    
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
    
    /// View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
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
        if let imageAnchor =  anchor as? ARImageAnchor {
            //イメージサイズをリファレンスイメージのフィジカルサイズから取得
            let imageSize = imageAnchor.referenceImage.physicalSize
            //SceneKitで平面を生成。サイズを取得したイメージのプロパティのサイズを設定
            let plane = SCNPlane(width: CGFloat(imageSize.width), height: CGFloat(imageSize.height))
            //ここではまだ平面に何も貼り付けられていないはずなのにテクスチャーの倍率調整を行なっている
            plane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
            //イメージ用Sceneノード生成
            let imageHightingAnimationNode = SCNNode(geometry: plane)
            //オイラー角で回転＿意味不明
            imageHightingAnimationNode.eulerAngles.x = -.pi / 2
            //オブジェクトの透明度を設定。かなり透明にしている
            imageHightingAnimationNode.opacity = 0.25
            //イメージノードをシーンノードのチャイルドノードに追加
            node.addChildNode(imageHightingAnimationNode)
            
            //アニメーション実行
            imageHightingAnimationNode.runAction(imageHighlightAction) {
                
                // InfoのSpriteKitのシーンを生成。用意されているAboutのシーンを利用
                let infoSpriteKitScene = SKScene(fileNamed: "sakeInfo")
                
                infoSpriteKitScene?.isPaused = false
                //ここでAbout用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
                let infoPlane = SCNPlane(width: CGFloat(imageSize.width * 1.5), height: CGFloat(imageSize.height * 1.2))
                //テスクチャーとしてAboutシーンを設定
                infoPlane.firstMaterial?.diffuse.contents = infoSpriteKitScene
                //テクスチャーのサイズ調整
                infoPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                //About用ノード生成
                let infoUsNode = SCNNode(geometry: infoPlane)
                //trueにすると表面のみ表示する
                infoUsNode.geometry?.firstMaterial?.isDoubleSided = true
                //またオイラー角で回転
                infoUsNode.eulerAngles.x = -.pi / 2
                //原点を設定
                infoUsNode.position = SCNVector3Zero
                //Aboutノードをシーンノードのチャイルドノードに追加
                node.addChildNode(infoUsNode)
                //アクション開始
                //アクションを設定。byは現在位置から指定分だけ移動に使用。
                //0.8秒でX軸方向に。0.25m移動する
                let move1Action = SCNAction.move(by: SCNVector3(-0.28, 0, 0), duration: 0.8)
                
                infoUsNode.runAction(move1Action, completionHandler: {
                    
                // AboutのSpriteKitのシーンを生成。用意されているAboutのシーンを利用
                let aboutSpriteKitScene = SKScene(fileNamed: "Detail")
                
                aboutSpriteKitScene?.isPaused = false
                //ここでAbout用の平面生成。サイズはリファレンスイメージよりちょっと大きめ
                let aboutUsPlane = SCNPlane(width: CGFloat(imageSize.width * 1.5), height: CGFloat(imageSize.height * 1.2))
                //テスクチャーとしてAboutシーンを設定
                aboutUsPlane.firstMaterial?.diffuse.contents = aboutSpriteKitScene
                //テクスチャーのサイズ調整
                aboutUsPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                //About用ノード生成
                let aboutUsNode = SCNNode(geometry: aboutUsPlane)
                //trueにすると表面のみ表示する
                aboutUsNode.geometry?.firstMaterial?.isDoubleSided = true
                //またオイラー角で回転
                aboutUsNode.eulerAngles.x = -.pi / 2
                //原点を設定
                 aboutUsNode.position = SCNVector3Zero
                //Aboutノードをシーンノードのチャイルドノードに追加
                node.addChildNode(aboutUsNode)
                //アクション開始
                //アクションを設定。byは現在位置から指定分だけ移動に使用。
                //0.8秒でX軸方向に。0.25m移動する
                let moveAction = SCNAction.move(by: SCNVector3(0.28, 0, 0), duration: 0.8)
                //Aboutノードにアクションを設定して実行
                
                aboutUsNode.runAction(moveAction, completionHandler: {
                    /*
                    //タイトルノード生成
                    let titleNode = aboutSpriteKitScene?.childNode(withName: "TitleNode")
                    //タイトルノードを1秒でy座標だけ90へ移動。toはその座標へ移動する。
                    //ここでやっているのは用意されたシーンファイル(About.sks)において
                    //中心のメインノードの座標(0,0,0)に対して移動したいノードの中心点を
                    //該当座標(0,90,0)に移動している。
                    titleNode?.run(SKAction.moveTo(y: 90, duration: 1.0))
                    //内容ノードの生成
                    let name = aboutSpriteKitScene?.childNode(withName: "DescriptionNode")
                    //内容ノードを1秒でy座標だけ−30へ移動(0,−30,0)。
                    name?.run(SKAction.moveTo(y: -30, duration: 1.0))
                    
                    // What We Do 以下のコメントは上記のAboutと同様なので省略
                    let whatWeDoSpriteKitScene = SKScene(fileNamed: "WhatWeDo")
                    whatWeDoSpriteKitScene?.isPaused = false
                    
                    let whatWeDoPlane = SCNPlane(width: CGFloat(imageSize.width * 1.5), height: CGFloat(imageSize.height * 1.2))
                    whatWeDoPlane.firstMaterial?.diffuse.contents = whatWeDoSpriteKitScene
                    whatWeDoPlane.firstMaterial?.diffuse.contentsTransform = SCNMatrix4Translate(SCNMatrix4MakeScale(1, -1, 1), 0, 1, 0)
                    
                    let whatWeDoNode = SCNNode(geometry: whatWeDoPlane)
                    whatWeDoNode.geometry?.firstMaterial?.isDoubleSided = true
                    whatWeDoNode.eulerAngles.x = -.pi / 2
                    whatWeDoNode.position = SCNVector3Zero
                    node.addChildNode(whatWeDoNode)
                    
                    let move1Action = SCNAction.move(by: SCNVector3(-0.25, 0, 0), duration: 0.8)
                    whatWeDoNode.runAction(move1Action, completionHandler: {
                        let titleNode = whatWeDoSpriteKitScene?.childNode(withName: "TitleNode")
                        
                        let dept1 = whatWeDoSpriteKitScene?.childNode(withName: "Dept1Node")
                        dept1?.run(SKAction.fadeOut(withDuration: 0.0))
                        
                        let dept2 = whatWeDoSpriteKitScene?.childNode(withName: "Dept2Node")
                        dept2?.run(SKAction.fadeOut(withDuration: 0.0))

                        titleNode?.run(SKAction.moveTo(x: 0, duration: 1.0), completion: {
                            dept1?.run(SKAction.moveTo(y: 30, duration: 0.8))
                            dept1?.run(SKAction.fadeIn(withDuration: 1.0), completion: {
                                dept2?.run(SKAction.moveTo(y: -80, duration: 0.8))
                                dept2?.run(SKAction.fadeIn(withDuration: 1.0))
                            })
                        })
                        
                    })
*/
 })
                     })
            }
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
