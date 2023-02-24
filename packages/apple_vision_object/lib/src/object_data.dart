import 'package:flutter/material.dart';

class Object{
  Object(this.rect);
  Rect rect;
}

class ObjectData{
  ObjectData(this.objects,this.imageSize);
  List<Object> objects;
  Size imageSize;
}

class ObjectFunctions{
  List<Object> getObjectDataFromList(List<Object?> object){
    List<Object> data = [];
    for(int i = 0; i < object.length; i++){
      Map map = (object[i] as Map);
      String temp = map.keys.first;
      data.add(
        Object(Rect.fromCenter(center: Offset(map['origin']['x'],map['origin']['y']),width: map['width'],height: map['height']))
      );
    }

    return data;
  }
}