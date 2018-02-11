//
//  Model.swift
//  hello-world
//
//  Created by Chris Young on 2/25/17.
//  Copyright © 2017 Chris Young. All rights reserved.
//

import GLKit

struct Obj {
    var vertexes:[String] = [];
    var normals:[String] = [];
    var faces:[String] = [];
}

struct Model {
    var shape:[GLfloat] = [];
    var normal:[GLfloat] = [];
    var color:[GLfloat] = [];

    var faces = 0;

    init(name:String) {
        let materials = loadMtl(name: name);
        let obj = loadObj(name: name);

        var m = "";

        func parseVector(i:Int) {
            let ss = obj.vertexes[i - 1].characters.split{ $0 == " " }.map(String.init);

            shape.append(GLfloat(ss[1])!);
            shape.append(GLfloat(ss[2])!);
            shape.append(GLfloat(ss[3])!);

            color.append(materials[m]![0]);
            color.append(materials[m]![1]);
            color.append(materials[m]![2]);
            color.append(GLfloat(1.0));

            faces += 1;
        }

        func parseNormal(i:Int) {
            let ss = obj.normals[i - 1].characters.split{ $0 == " " }.map(String.init);

            normal.append(GLfloat(ss[1])!);
            normal.append(GLfloat(ss[2])!);
            normal.append(GLfloat(ss[3])!);
        }

        for face in obj.faces {
            let ss = face.characters.split{ $0 == " " }.map(String.init);

            if ss[0] == "usemtl" {
                m = ss[1];
            } else {
                for i in 1...3 {
                    let t = ss[i].characters.split{ $0 == "/" }.map(String.init);

                    parseVector(i: Int(t[0])!);
                    parseNormal(i: Int(t[1])!);
                }
            }
        }
    }
}

func readLines(name:String, type:String) -> [String] {
    let path = Bundle.main.path(forResource: name, ofType: type);

    var file = "";

    do {
        file = try String(contentsOfFile: path!);
    } catch _ {
        print("failed to read file:", name, type);
        return [];
    }

    return file.characters.split{ $0 == "\n" }.map(String.init);
}

func loadMtl(name:String) -> [String:[GLfloat]] {
    var materials = [String:[GLfloat]]();

    let lines = readLines(name: name, type: "mtl");

    for (i, line) in lines.enumerated() {
        let ss = line.characters.split{ $0 == " " }.map(String.init);

        if ss[0] == "newmtl" {
            let cs = lines[i + 3].characters.split{ $0 == " " }.map(String.init);

            materials[ss[1]] = [GLfloat(cs[1])!, GLfloat(cs[2])!, GLfloat(cs[3])!];
        }
    }

    return materials;
}

func loadObj(name:String) -> Obj {
    let lines = readLines(name: name, type: "obj");

    var obj = Obj();

    for (_, line) in lines.enumerated() {
        switch (line.characters[line.startIndex]) {
            case "v":
                if line.characters[line.index(line.startIndex, offsetBy: 1)] == "n" {
                    obj.normals.append(line);
                } else {
                    obj.vertexes.append(line);
                }
                break;
            case "f":
                obj.faces.append(line);
                break;
            case "u":
                obj.faces.append(line);
                break;
            default:
                break;
        }
    }

    return obj;
}
