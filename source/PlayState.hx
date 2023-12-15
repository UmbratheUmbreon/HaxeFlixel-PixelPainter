package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.group.FlxGroup;

import flixel.math.FlxPoint;

import flixel.text.FlxText;

import flixel.util.FlxColor;

import flixel.addons.ui.FlxUISlider;

import objects.Player;

class PlayState extends FlxState
{
	var camHUD:FlxCamera;
	
	var colorWheel:FlxSprite;
	
	var selectedColor:FlxColor;
	
	var selectedColorVisualizer:FlxSprite;
	
	var enabled:Bool;
	
	var enableVisualizer:FlxSprite;
	
	var brushSize:Float;
	
	var brushSizeSlider:FlxUISlider;
	
	var player:Player;
	
	var pxGroup:FlxGroup;
	
	var script:Script;
	
	override function create():Void
	{
		super.create();
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		
		colorWheel = new FlxSprite(0, 0, "assets/images/colorWheel.png");
		colorWheel.camera = camHUD;
		colorWheel.scale.set(0.25, 0.25);
		colorWheel.updateHitbox();
		add(colorWheel);
		
		selectedColor = FlxColor.WHITE;
		
		selectedColorVisualizer = new FlxSprite(colorWheel.x + 100, colorWheel.y).makeGraphic(30, 30, selectedColor);
		selectedColorVisualizer.camera = camHUD;
		add(selectedColorVisualizer);
		
		enabled = true;
		
		enableVisualizer = new FlxSprite(selectedColorVisualizer.x + 45, selectedColorVisualizer.y).makeGraphic(30, 30);
		enableVisualizer.camera = camHUD;
		enableVisualizer.color = enabled ? FlxColor.LIME : FlxColor.RED;
		add(enableVisualizer);
		
		brushSize = 30;
		
		brushSizeSlider = new FlxUISlider(this, "brushSize", colorWheel.x, colorWheel.y + 100, 0, 100, 100, 15, 3, FlxColor.WHITE);
		brushSizeSlider.camera = camHUD;
		brushSizeSlider.nameLabel.text = "Brush Size";
		add(brushSizeSlider);
		
		pxGroup = new FlxGroup();
		add(pxGroup);
		
		player = new Player();
		add(player);
		
		FlxG.camera.follow(player, LOCKON);
		
		script = new Script();
		script.doFile("assets/scripts/script.hx");
		script.call("new", []);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.worldBounds.set(player.x, player.y, player.width, player.height);
		
		FlxG.collide(player, pxGroup);
		
		if (FlxG.keys.justPressed.ENTER)
		{
			enabled = !enabled;
			
			enableVisualizer.color = enabled ? FlxColor.LIME : FlxColor.RED;
		}
		
		if (FlxG.mouse.pressed)
		{
			if (FlxG.mouse.overlaps(colorWheel, camHUD))
			{
				var mousePosition:FlxPoint = FlxPoint.get(FlxG.mouse.getScreenPosition(camHUD).x, FlxG.mouse.getScreenPosition(camHUD).y);
				
				var color:Null<FlxColor> = colorWheel.getPixelAtScreen(mousePosition, camHUD);
				
				selectedColor = color != FlxColor.TRANSPARENT ? color : FlxColor.BLACK;
				
				selectedColorVisualizer.color = selectedColor;
			}
			else if (enabled)
			{
				var px:FlxSprite = new FlxSprite(FlxG.mouse.x, FlxG.mouse.y).makeGraphic(Std.int(brushSize), Std.int(brushSize), selectedColor);
				px.immovable = true;
				pxGroup.add(px);
			}
			else
			{
				for (px in pxGroup.members)
				{
					if (FlxG.mouse.overlaps(px))
					{
						px.destroy();
						pxGroup.members.remove(px);
					}
				}
			}
		}
		
		script.call("update", [elapsed]);
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
	}
	
	override function destroy():Void
	{
		super.destroy();
		
		script.call("destroy", []);
		
		script.destroy();
	}
}