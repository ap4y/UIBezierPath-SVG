UIBezierPath+SVG
=============

UIBezierPath class category with SVG parser

[<img src="https://raw.github.com/ap4y/UIBezierPath-SVG/master/photo.png" width="420px"></img>](https://raw.github.com/ap4y/UIBezierPath-SVG/master/photo.png)

[<img src="https://raw.github.com/mredig/UIBezierPath-SVG/master/macSS.png"></img>](https://raw.github.com/mredig/UIBezierPath-SVG/master/macSS.png)

## Usage ##

    + (SKUBezierPath *)bezierPathWithSVGString:(NSString*)svgString;

Example project included with sample SVG icons (from Raphael free icons collection).

(It was renamed "SKUBezierPath" to ease cross platform development in SpriteKit. However, SpriteKit is not a requirement - NSBezierPath or UIBezierPath will still work, depending on the platform you're developing for)

Reference
-------

- [SVG 1.1 (Second Edition)](http://www.w3.org/TR/SVG/paths.html#PathData)
- [Raphael.js free icons](http://raphaeljs.com/icons/)

License
-------
(The MIT License)
