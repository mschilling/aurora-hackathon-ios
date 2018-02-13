
//
//  ArKitViewController.swift
//  Aurora
//
//  Created by Julian van 't Veld on 08-02-18.
//  Copyright © 2018 Julian van 't Veld. All rights reserved.
//

import UIKit
import ARKit

class ArKitViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLighting()
        addTapGestureToSceneView()        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func addBox(x: Float = 0, y: Float = 0, z: Float = -0.2) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        
        sceneView.scene.rootNode.addChildNode(boxNode)
        
    }
    
    func addSphere(x: Float = 0, y: Float = 0, z: Float = -0.2){
        let sphere = SCNSphere(radius: 0.3)
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "earthtruecolor_nasa_big.jpg")
        sphere.materials = [material]
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3(x, y, z)
        sceneView.scene.rootNode.addChildNode(sphereNode)
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ArKitViewController.didTap(withGestureRecognizer:)))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else {
            let hitTestResultsWithFeaturePoints = sceneView.hitTest(tapLocation, types: .featurePoint)
            
            if let hitTestResultWithFeaturePoints = hitTestResultsWithFeaturePoints.first {
                let translation = hitTestResultWithFeaturePoints.worldTransform.translation
                addTower(x: translation.x, y: translation.y, z: translation.z)
            }
            
            return }
        node.removeFromParentNode()
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    
    func addTower(x: Float = 0, y: Float = 0, z: Float = -0.5) {
        guard let towerScene = SCNScene(named: "model.dae") else { return }
        let towerNode = SCNNode()
        let towerSceneChildNodes = towerScene.rootNode.childNodes
        
        for childNode in towerSceneChildNodes {
            towerNode.addChildNode(childNode)
        }
        towerNode.position = SCNVector3(x, y, z)
        towerNode.scale = SCNVector3(0.3, 0.3, 0.3)
        sceneView.scene.rootNode.addChildNode(towerNode)
    }
    
    
}

extension float4x4 {
    var translation: float3 {
        let translation = self.columns.3
        return float3(translation.x, translation.y, translation.z)
    }
}

