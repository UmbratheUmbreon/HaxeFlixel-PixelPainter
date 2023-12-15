import flixel.FlxG;

import flixel.FlxSprite;

import flixel.text.FlxText;

import flixel.text.FlxTextBorderStyle;

var sprite:FlxSprite;

var text:FlxText;

function new():Void
{
	// sprite = new FlxSprite(-100, -100).makeGraphic(10, 10, 0xFFFFFFFF);
	// FlxG.state.add(sprite);
	
	// text = new FlxText(-110, -120, 0, 'Hello World!', 10);
	// text.setBorderStyle(FlxTextBorderStyle.SHADOW, 0xFFFF0000);
	// FlxG.state.add(text);
	
	// trace(this.interp.locals);
}

function update(elapsed:Float):Void
{
	if (FlxG.keys.pressed.E)
		FlxG.camera.zoom += 0.01;
	
	if (FlxG.keys.pressed.Q)
		FlxG.camera.zoom -= 0.01;
}

function destroy():Void
{
	// trace('Destroyed!');
}