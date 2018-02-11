//
//  Body.swift
//  hello-world
//
//  Created by Chris Young on 4/1/17.
//  Copyright © 2017 Chris Young. All rights reserved.
//

import GLKit

struct Body {
    var scale:[GLfloat];
    var translation:[GLfloat];
    var rotation:[GLfloat];
    
    var velocity:[GLfloat];
    var rotationalVelocity:[GLfloat];

    var bounds:GLfloat;
    
    var model:Model;

    var hidden = false;

    init(x:GLfloat, y:GLfloat, model:Model) {
        scale = [0.2, 0.2, 0.2];
        translation = [x, y, -5.0];
        rotation = [GLfloat(Double.pi) / -9.0, 0.0, 0.0];
        
        velocity = [0.0, 0.0];
        rotationalVelocity = [0.0, 0.0];

        bounds = 0.2;
        
        self.model = model;
    }
}

// return collision angle
func collision(a:Body, b:Body) -> Bool {
    let x = a.translation[0] - b.translation[0];
    let y = a.translation[1] - b.translation[1];
    let c = sqrt(pow(x, 2) + pow(y, 2));
    
    return c < a.bounds + b.bounds;
}
