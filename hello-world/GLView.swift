//
//  GLView.swift
//  hello-world
//
//  Created by Chris Young on 2/12/17.
//  Copyright © 2017 Chris Young. All rights reserved.
//

import UIKit
import GLKit

var aspect:GLfloat = 0.0;

var a = Light(position: [-1.0, 1.0, 1.0], brightness: 0.4);
var b = Light(position: [-1.0, -1.0, 1.0], brightness: 0.4);
var c = Light(position: [1.0, 1.0, 1.0], brightness: 0.8);
var d = Light(position: [1.0, -1.0, 1.0], brightness: 0.4);

class GLView: GLKView {

    var program:GLuint = 0
    var once = false

    override func draw(_ rect: CGRect) {
        if (!once) {
            self.setup();
            once = true;
        }
        
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT));
        
        self.bindUniform3fv(name: "u_lightA", data: a.position);
        self.bindUniform3fv(name: "u_lightB", data: b.position);
        self.bindUniform3fv(name: "u_lightC", data: c.position);
        self.bindUniform3fv(name: "u_lightD", data: d.position);

        self.bindUniform1f(name: "v_brightnessA", data: a.brightness);
        self.bindUniform1f(name: "v_brightnessB", data: b.brightness);
        self.bindUniform1f(name: "v_brightnessC", data: c.brightness);
        self.bindUniform1f(name: "v_brightnessD", data: d.brightness);
        
        for body in bodies {
            if (!body.hidden) {
                var shapeAttrib = self.bindAttrib(name: "a_shape", data: body.model.shape, stride: 3);
                defer { glDeleteBuffers(1, &shapeAttrib) }
            
                var normalAttrib = self.bindAttrib(name: "a_normal", data: body.model.normal, stride: 3);
                defer { glDeleteBuffers(1, &normalAttrib) }
            
                var colorAttrib = self.bindAttrib(name: "a_color", data: body.model.color, stride: 4);
                defer { glDeleteBuffers(1, &colorAttrib) }
            
                self.bindUniform3fv(name: "u_scale", data: body.scale);
                self.bindUniform3fv(name: "u_translation", data: body.translation);
                self.bindUniform3fv(name: "u_rotation", data: body.rotation);

                glDrawArrays(GLenum(GL_TRIANGLES), 0, GLsizei(body.model.faces));
            }
        }
    }

    func setup() {
        let vertexScript = readScript(name: "vertex")
        let vertexShader = compileShader(script: vertexScript, type: GLenum(GL_VERTEX_SHADER))
        
        let fragmentScript = readScript(name: "fragment")
        let fragmentShader = compileShader(script: fragmentScript, type: GLenum(GL_FRAGMENT_SHADER))
        
        self.program = linkProgram(vertex: vertexShader, fragment: fragmentShader)
        
        glUseProgram(self.program)
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        glEnable(GLenum(GL_CULL_FACE))
        glEnable(GLenum(GL_DEPTH_TEST))
        
        aspect = GLfloat(self.drawableWidth) / GLfloat(self.drawableHeight)
        
        let perspective = frustrum(fieldOfView: GLfloat(Double.pi) / 4.0);
        
        self.bindUniformMatrix4fv(name: "u_perspective", data: perspective);
    }
    
    func bindUniform1f(name: String, data: GLfloat) {
        let location = glGetUniformLocation(self.program, name)
        
        if location == -1 {
            print("failed to get uniform1f location")
            return
        }
        
        glUniform1f(location, data);
    }
    
    func bindUniform3fv(name: String, data: [GLfloat]) {
        let location = glGetUniformLocation(self.program, name)
        
        if (location == -1) {
            print("failed to get uniform3fv location")
            return
        }
        
        glUniform3fv(location, 1, data);
    }
    
    func bindUniformMatrix4fv(name: String, data: [GLfloat]) {
        let location = glGetUniformLocation(self.program, name)
        
        if (location == -1) {
            print("failed to get uniformMatrix4fv location")
            return
        }
        
        glUniformMatrix4fv(location, 1, GLboolean(false), data);
    }

    func bindAttrib(name: String, data: [GLfloat], stride: Int) -> GLuint {
        var VBO:GLuint = 0
        
        glGenBuffers(1, &VBO)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), VBO)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLfloat>.stride * data.count, data, GLenum(GL_STATIC_DRAW))
        
        let location = glGetAttribLocation(self.program, name)
        if location == -1 {
            print("failed to get attribute position for", name)
            return 0
        }
        
        glEnableVertexAttribArray(GLuint(location))
        glVertexAttribPointer(GLuint(location), GLint(stride), GLenum(GL_FLOAT), GLboolean(false), GLsizei(MemoryLayout<GLfloat>.stride * stride), nil)
        
        return VBO
    }
    
}

func readScript(name: String) -> String {
    let path = Bundle.main.path(forResource: name, ofType: "glsl")
    
    do {
        return try String(contentsOfFile: path!)
    } catch _ {
        return ""
    }
}

func compileShader(script: String, type: GLenum) -> GLuint {
    let shader:GLuint = glCreateShader(type)
    
    var string = (script as NSString).utf8String
    glShaderSource(shader, 1, &string, nil)
    glCompileShader(shader)
    
    var success:GLint = 0
    glGetShaderiv(shader, GLenum(GL_COMPILE_STATUS), &success)
    
    var infoLog = [GLchar](repeating: 0, count: 512)
    guard success == GL_TRUE else {
        glGetShaderInfoLog(shader, 512, nil, &infoLog)
        print("shader failed to compile", String.init(validatingUTF8: infoLog)!)
        return 0
    }
    
    return shader
}

func linkProgram(vertex: GLuint, fragment: GLuint) -> GLuint {
    let program:GLuint = glCreateProgram()
    
    glAttachShader(program, vertex)
    glAttachShader(program, fragment)
    glLinkProgram(program)
    
    var success:GLint = 0
    glGetProgramiv(program, GLenum(GL_LINK_STATUS), &success)
    
    var infoLog = [GLchar](repeating: 0, count: 512)
    guard success == GL_TRUE else {
        glGetProgramInfoLog(program, 512, nil, &infoLog)
        print("failed to link shaders", String.init(validatingUTF8: infoLog)!)
        return 0
    }
    
    return program
}

func frustrum(fieldOfView: GLfloat) -> [GLfloat] {
    let depth = tan(GLfloat(Double.pi) * 0.5 - 0.5 * fieldOfView);
    let near:GLfloat = 0.0;
    let far:GLfloat = 100.0;
    let range = 1.0 / (near - far);
    
    let perspective:[GLfloat] = [
        depth / aspect, 0.0, 0.0, 0.0,
        0.0, depth, 0.0, 0.0,
        0.0, 0.0, (near + far) * range, -1.0,
        0.0, 0.0, near * far * range, 1.0
    ];
    
    return perspective;
}
