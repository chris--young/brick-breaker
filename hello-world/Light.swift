//
//  Light.swift
//  hello-world
//
//  Created by Chris Young on 4/1/17.
//  Copyright © 2017 Chris Young. All rights reserved.
//

import GLKit

struct Light {
    var position:[GLfloat];
    var brightness:GLfloat;
    
    init(position:[GLfloat], brightness:GLfloat) {
        self.position = position;
        self.brightness = brightness;
    }
}
