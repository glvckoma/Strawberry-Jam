package game.phantomsTreasure
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.Graphics;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.filters.DisplacementMapFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class PhantomsTreasureRipple extends Sprite
   {
      private static const GREY:int = 8421504;
      
      private static var uniqueColorForReference:uint = 5;
      
      public var radius:int = 70;
      
      public var durationInFrames:int = 30;
      
      public var amplitude:int = 50;
      
      public var waveSprite:Sprite;
      
      private var displayObject:DisplayObject;
      
      private var bitmapData:BitmapData;
      
      private var bitmap:Bitmap;
      
      private var displacementMapFilter:DisplacementMapFilter;
      
      private var position:Point;
      
      private var currentStep:int;
      
      private var scale:Number;
      
      private var currentAmplitude:Number;
      
      private var matrix:Matrix;
      
      private var rect:Rectangle;
      
      private var filterIndex:int;
      
      private var myFilters:Array;
      
      private var myColorRef:uint;
      
      public var _rippleComplete:Boolean;
      
      public function PhantomsTreasureRipple(param1:DisplayObject)
      {
         super();
         waveSprite = createDisplacementMap();
         displayObject = param1;
         matrix = new Matrix(1,0,0,1,1,1);
         bitmapData = new BitmapData(radius * 2,radius * 2,false,8421504);
         rect = new Rectangle(0,0,radius * 2,radius * 2);
         bitmapData.fillRect(rect,8421504);
         position = new Point();
      }
      
      public function rippleIt() : void
      {
         _rippleComplete = false;
         position.x = mouseX - radius;
         position.y = mouseY - radius;
         displacementMapFilter = new DisplacementMapFilter(bitmapData,position,1,2,amplitude,amplitude);
         displacementMapFilter.color = uniqueColorForReference;
         myColorRef = uniqueColorForReference;
         uniqueColorForReference++;
         myFilters = displayObject.filters;
         myFilters.push(displacementMapFilter);
         displayObject.filters = myFilters;
         currentStep = 0;
         displayObject.addEventListener("enterFrame",updateRipple);
      }
      
      private function updateRipple(param1:Event) : void
      {
         currentAmplitude = amplitude * ((durationInFrames - currentStep) / durationInFrames);
         myFilters = displayObject.filters;
         filterIndex = getFilterIndex();
         if(currentAmplitude > 0)
         {
            scale = currentStep / durationInFrames;
            matrix.a = scale;
            matrix.d = scale;
            matrix.tx = radius;
            matrix.ty = radius;
            bitmapData.fillRect(rect,8421504);
            bitmapData.draw(waveSprite,matrix);
            displacementMapFilter.scaleX = currentAmplitude;
            displacementMapFilter.scaleY = currentAmplitude;
            myFilters[filterIndex] = displacementMapFilter;
            displayObject.filters = myFilters;
         }
         else
         {
            rippleComplete();
         }
         currentStep++;
      }
      
      private function rippleComplete(param1:Event = null) : void
      {
         myFilters.splice(filterIndex,1);
         displayObject.filters = myFilters;
         displayObject.removeEventListener("enterFrame",updateRipple);
         _rippleComplete = false;
      }
      
      private function getFilterIndex() : int
      {
         var _loc2_:int = 0;
         var _loc1_:int = int(myFilters.length);
         if(_loc1_ == 0)
         {
            return -1;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            if(myFilters[_loc2_].color == myColorRef)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         trace("ERROR: FILTER IS NOT IN ARRAY");
         return -1;
      }
      
      private function createDisplacementMap() : Sprite
      {
         var _loc2_:Sprite = new Sprite();
         var _loc6_:Graphics = _loc2_.graphics;
         _loc6_.clear();
         _loc6_.beginGradientFill("linear",[16711680,0],[1,1],[0,255]);
         _loc6_.drawCircle(0,0,radius);
         _loc6_.endFill();
         var _loc4_:Sprite = new Sprite();
         _loc6_ = _loc4_.graphics;
         _loc6_.clear();
         _loc6_.beginGradientFill("linear",[65280,0],[1,1],[0,255]);
         _loc6_.drawCircle(0,0,radius);
         _loc6_.endFill();
         var _loc1_:Matrix = new Matrix(1,0,0,1,1,1);
         _loc1_.createGradientBox(radius * 2,radius * 2,0,-radius,-radius);
         var _loc5_:Sprite = new Sprite();
         _loc6_ = _loc5_.graphics;
         _loc6_.clear();
         _loc6_.beginGradientFill("radial",[8421504,8421504,8421504],[1,0,1],[128,192,255],_loc1_);
         _loc6_.drawCircle(0,0,radius);
         _loc6_.endFill();
         var _loc3_:Sprite = new Sprite();
         _loc6_ = _loc3_.graphics;
         _loc6_.clear();
         _loc6_.beginFill(8421504);
         _loc6_.drawRect(-radius,-radius,radius * 2,radius * 2);
         _loc6_.endFill();
         _loc3_.addChild(_loc2_);
         _loc4_.rotation = 90;
         _loc4_.blendMode = "add";
         _loc2_.addChild(_loc4_);
         _loc2_.addChild(_loc5_);
         return _loc3_;
      }
   }
}

