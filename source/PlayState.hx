package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;

import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;

import flixel.math.FlxPoint;

import flixel.text.FlxText;

import flixel.ui.FlxButton;

import flixel.util.FlxColor;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;

import flixel.addons.display.shapes.FlxShape;
import flixel.addons.display.shapes.FlxShapeCircle;

import flixel.addons.ui.FlxUISlider;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PNGEncoderOptions;

import openfl.utils.ByteArray;

import objects.Player;

class PlayState extends FlxState
{
	var camHUD:FlxCamera;
	
	var background:FlxBackdrop;
	
	var backgroundAlphaSlider:FlxUISlider;
	
	var colorWheel:FlxSprite;
	
	var selectedColor:FlxColor;
	
	var selectedColorVisualizer:FlxSprite;
	
	var enabled:Bool;
	
	var enableVisualizer:FlxSprite;
	
	var brushSize:Float;
	
	var brushSizeSlider:FlxUISlider;
	
	var saveButton:FlxButton;
	
	var pxGroup:FlxTypedGroup<FlxSprite>;
	
	var player:Player;
	
	override function create():Void
	{
		super.create();
		
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);
		
		background = new FlxBackdrop(FlxGridOverlay.createGrid(40, 40, 80, 80, true, FlxColor.WHITE, FlxColor.WHITE.getInverted()));
		add(background);
		
		backgroundAlphaSlider = new FlxUISlider(background, "alpha", 0, 0, 0, 1, 100, 15, 3, FlxColor.WHITE, 0xFF828282);
		backgroundAlphaSlider.camera = camHUD;
		backgroundAlphaSlider.nameLabel.text = "Background Alpha";
		backgroundAlphaSlider.setPosition(0, 150);
		add(backgroundAlphaSlider);
		
		colorWheel = new FlxSprite(0, 0, "assets/images/colorWheel.png");
		colorWheel.camera = camHUD;
		colorWheel.scale.set(0.25, 0.25);
		colorWheel.updateHitbox();
		add(colorWheel);
		
		selectedColor = FlxColor.WHITE;
		
		selectedColorVisualizer = new FlxSprite().makeGraphic(30, 30);
		selectedColorVisualizer.camera = camHUD;
		selectedColorVisualizer.color = selectedColor;
		selectedColorVisualizer.setPosition(colorWheel.x + 100, colorWheel.y);
		add(selectedColorVisualizer);
		
		enabled = true;
		
		enableVisualizer = new FlxSprite().makeGraphic(30, 30);
		enableVisualizer.camera = camHUD;
		enableVisualizer.color = enabled ? FlxColor.LIME : FlxColor.RED;
		enableVisualizer.setPosition(selectedColorVisualizer.x + 45, selectedColorVisualizer.y);
		add(enableVisualizer);
		
		brushSize = 30;
		
		brushSizeSlider = new FlxUISlider(this, "brushSize", 0, 0, 0, 100, 100, 15, 3, FlxColor.WHITE, 0xFF828282);
		brushSizeSlider.camera = camHUD;
		brushSizeSlider.nameLabel.text = "Brush Size";
		brushSizeSlider.setPosition(colorWheel.x, colorWheel.y + 100);
		add(brushSizeSlider);
		
		saveButton = new FlxButton(0, 0, "Save to PNG", function()
		{
			savePNG();
		});
		saveButton.camera = camHUD;
		saveButton.setPosition(10, (FlxG.height - saveButton.height) - 10);
		add(saveButton);
		
		pxGroup = new FlxTypedGroup<FlxSprite>();
		add(pxGroup);
		
		player = new Player();
		add(player);
		
		FlxG.camera.follow(player, LOCKON);
	}
	
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		FlxG.worldBounds.set(player.x, player.y, player.width, player.height);
		
		if (!FlxG.mouse.pressedRight)
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
				var mousePosition:FlxPoint = FlxPoint.get(FlxG.mouse.getWorldPosition(camHUD).x, FlxG.mouse.getWorldPosition(camHUD).y);
				
				var color:Null<FlxColor> = colorWheel.getPixelAtScreen(mousePosition, camHUD);
				
				if (color == FlxColor.TRANSPARENT)
					color = FlxColor.BLACK;
				
				background.loadGraphic(FlxGridOverlay.createGrid(40, 40, 160, 160, true, color, color.getInverted()));
				
				selectedColor = color;
				
				selectedColorVisualizer.color = selectedColor;
			}
			
			if (enabled)
			{
				var px:FlxSprite = new FlxSprite().makeGraphic(Std.int(brushSize), Std.int(brushSize), selectedColor);
				px.immovable = true;
				px.setPosition(FlxG.mouse.getWorldPosition().x, FlxG.mouse.getWorldPosition().y);
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
		
		if (FlxG.keys.pressed.Q)
			FlxG.camera.zoom -= 0.05;
		
		if (FlxG.keys.pressed.E)
			FlxG.camera.zoom += 0.05;
		
		for (px in pxGroup.members)
			px.alpha = FlxG.mouse.pressedRight ? 0.5 : 1;
		
		if (FlxG.keys.justPressed.R)
			FlxG.resetState();
	}
	
	override function destroy():Void
	{
		super.destroy();
	}
	
	function savePNG():Void
	{
		var bitmap:Bitmap = new Bitmap(BitmapData.fromImage(FlxG.stage.window.readPixels()));
		
		var bytes:ByteArray = bitmap.bitmapData.encode(bitmap.bitmapData.rect, new PNGEncoderOptions());
		
		if (!sys.FileSystem.exists("./art/"))
			sys.FileSystem.createDirectory("./art/");
		
		sys.io.File.saveBytes("art/art_" + Date.now().toString().split(":").join("-") + ".png", bytes);
	}
}