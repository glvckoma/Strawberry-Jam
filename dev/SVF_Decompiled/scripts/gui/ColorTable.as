package gui
{
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class ColorTable extends MovieClip
   {
      private var _bm:Bitmap;
      
      private var _bmd:BitmapData;
      
      private var _id:int;
      
      private var _currColor:int;
      
      private var _currColorSwatch:Sprite;
      
      private var _secretColorIdx:int;
      
      private var _colorValues:Array;
      
      private var _colorIndexes:Array;
      
      private var _width:int;
      
      private var _height:int;
      
      private var _numRows:int;
      
      private var _numCols:int;
      
      private var _cellWidth:int;
      
      private var _cellHeight:int;
      
      private var _colorChangeCallback:Function;
      
      public function ColorTable()
      {
         super();
      }
      
      public function init(param1:int, param2:int, param3:int, param4:int, param5:int, param6:Array, param7:Array, param8:int, param9:Function, param10:int = -1) : void
      {
         _id = param1;
         _width = param2;
         _height = param3;
         _colorValues = param6;
         _colorIndexes = param7;
         _numCols = param4;
         _numRows = param5;
         _cellWidth = _width / _numCols;
         _cellHeight = _height / _numRows;
         _colorChangeCallback = param9;
         _secretColorIdx = param10;
         _bmd = new BitmapData(_width,_height,false,0);
         fillColorTable();
         _currColor = param8;
         setCurrentColorSwatch(_currColor);
         addEventListener("mouseDown",colorTableClickHandler,false,0,true);
      }
      
      public function destroy() : void
      {
         if(_bm)
         {
            this.removeChild(_bm);
            _bm = null;
         }
         if(_bmd)
         {
            _bmd = null;
         }
         _colorIndexes = null;
         _colorValues = null;
         removeEventListener("mouseDown",colorTableClickHandler);
      }
      
      private function fillColorTable() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc1_:Rectangle = null;
         _loc4_ = 0;
         while(_loc4_ < _colorIndexes.length)
         {
            _loc2_ = _loc4_ % _numCols * (_width / _numCols);
            _loc3_ = Math.floor(_loc4_ / _numCols) * (_height / _numRows);
            _loc1_ = new Rectangle(_loc2_,_loc3_,_width / _numCols,_height / _numRows);
            _bmd.fillRect(_loc1_,_colorValues[_colorIndexes[_loc4_]]);
            _loc4_++;
         }
         _bm = new Bitmap(_bmd);
         this.addChild(_bm);
      }
      
      private function setCurrentColorSwatch(param1:int) : void
      {
         var x:int;
         var y:int;
         var color:int = param1;
         var idxInPalette:int = -1;
         var i:int = 0;
         while(i < _colorIndexes.length)
         {
            if(_colorIndexes[i] == color)
            {
               idxInPalette = i;
               break;
            }
            i++;
         }
         if(_currColorSwatch)
         {
            this.removeChild(_currColorSwatch);
            _currColorSwatch = null;
         }
         if(idxInPalette >= 0)
         {
            x = idxInPalette % _numCols * _cellWidth;
            y = Math.floor(idxInPalette / _numCols) * _cellHeight;
            _currColorSwatch = new Sprite();
            with(_currColorSwatch.graphics)
            {
               
               beginFill(0);
               drawRect(x,y,_cellWidth,5);
               drawRect(x,y + _cellHeight - 5,_cellWidth,5);
               drawRect(x,y,5,_cellHeight);
               drawRect(x + _cellWidth - 5,y,5,_cellHeight);
            }
            this.addChild(_currColorSwatch);
         }
      }
      
      private function colorTableClickHandler(param1:MouseEvent) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Point = new Point(param1.localX,param1.localY);
         var _loc3_:int = -1;
         if(_loc2_.x == _width)
         {
            if(_secretColorIdx == -1)
            {
               _loc2_.x = _width - 1;
            }
            else if(_loc2_.y < _cellHeight * (_numRows - 1))
            {
               _loc2_.x = _width - 1;
            }
            else
            {
               _loc3_ = _secretColorIdx;
            }
         }
         if(_loc3_ < 0)
         {
            _loc4_ = Math.floor(_loc2_.x / _cellWidth) + Math.floor(_loc2_.y / _cellHeight) * _numCols;
            _loc3_ = int(_colorIndexes[_loc4_]);
         }
         if(_currColor != _loc3_)
         {
            _currColor = _loc3_;
            setCurrentColorSwatch(_loc3_);
            if(_colorChangeCallback != null)
            {
               _colorChangeCallback(_id,_loc3_);
            }
         }
      }
   }
}

