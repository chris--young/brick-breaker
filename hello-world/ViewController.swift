//
//  ViewController.swift
//  hello-world
//
//  Created by Chris Young on 2/12/17.
//  Copyright © 2017 Chris Young. All rights reserved.
//

import UIKit
import CoreMotion
import GLKit

let diamond = Model(name: "diamond");
let sphere = Model(name: "sphere");
let cube = Model(name: "cube");

var ball = Body(x: 0.0, y: -1.5, model: sphere);
var paddle = Body(x: 0.0, y: -2.0, model: cube);

var bodies:[Body] = [paddle, ball];

class ViewController: UIViewController {

    @IBOutlet weak var glView: GLKView!

    var manager:CMMotionManager!

    override func viewDidLoad() {
        super.viewDidLoad();

        self.manager = CMMotionManager()
        if !self.manager.isAccelerometerAvailable {
            print("accelerometer unavailable");
            return;
        }

        self.manager.accelerometerUpdateInterval = 0.1;
        self.manager.startAccelerometerUpdates();

        let context = EAGLContext.init(api: EAGLRenderingAPI.openGLES2);
        if (context == nil) {
            print("could not get context");
            return;
        }

        self.glView.context = context!;

        let xs = [-1.0, -0.5, 0.0, 0.5, 1.0];
        let ys = [0.0, 0.5, 1.0, 1.5, 2.0];

        for x in xs {
            for y in ys {
                bodies.append(Body(x: GLfloat(x), y: GLfloat(y), model: diamond));
            }
        }
        
        bodies[1].velocity[1] = 0.03;
        bodies[1].rotationalVelocity[0] = -0.09;

        let link = CADisplayLink(target: self, selector: #selector(self.update(coda:)));

        link.add(to: .main, forMode: .defaultRunLoopMode);

        UIApplication.shared.isIdleTimerDisabled = true;
    }

    func update(coda:Float) {
        self.glView.display();

        if let data = self.manager.accelerometerData {
            let x = bodies[0].translation[0] + GLfloat(data.acceleration.x) * 0.3;
            if (x < 1.0 && x > -1.0) {
                bodies[0].translation[0] = x;
            }
        }
        
        if (collision(a: bodies[0], b: bodies[1])) {
            let x = bodies[0].translation[0] - bodies[1].translation[0];
            let y = bodies[0].translation[1] - bodies[1].translation[1];
            let a = atan2(x, y);
            
            // update z rotation
            // bodies[1].rotation[2] = a;
            bodies[1].rotationalVelocity[0] *= -1.0;

            bodies[1].velocity[0] = cos(a) * 0.03;
            bodies[1].velocity[1] = sin(a) * 0.03;
        }

        let x = bodies[1].translation[0] + bodies[1].velocity[0];
        if (x < 1.0 && x > -1.0) {
            bodies[1].translation[0] = x;
        } else {
            bodies[1].velocity[0] *= -1.0;
        }

        let y = bodies[1].translation[1] + bodies[1].velocity[1];
        if (y < 2.0 && y > -2.0) {
            bodies[1].translation[1] = y;
        } else {
            bodies[1].velocity[1] *= -1.0;
            bodies[1].rotationalVelocity[0] *= -1.0;
        }

        bodies[1].rotation[1] += bodies[1].rotationalVelocity[1];
        bodies[1].rotation[0] += bodies[1].rotationalVelocity[0];

        for i in 2...bodies.count - 1 {
            if (!bodies[i].hidden && collision(a: bodies[1], b: bodies[i])) {
                bodies[i].hidden = true;
                
                bodies[1].velocity[0] *= -1.0;
                bodies[1].velocity[1] *= -1.0;

                bodies[1].rotationalVelocity[0] *= -1.0;
            }

            bodies[i].rotation[1] -= 0.01;
        }
    }

}
