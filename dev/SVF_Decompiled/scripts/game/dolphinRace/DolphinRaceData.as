package game.dolphinRace
{
   import flash.events.Event;
   import flash.net.FileFilter;
   import flash.net.FileReference;
   import flash.net.URLLoader;
   import flash.utils.ByteArray;
   
   public class DolphinRaceData
   {
      public var _data:Object;
      
      public var _facts:Array;
      
      public var loadit:URLLoader;
      
      public var MyFile:FileReference;
      
      public function DolphinRaceData()
      {
         super();
         initLevelData();
      }
      
      public function initLevelData() : void
      {
         _facts = [{
            "imageID":1738,
            "text":11408
         },{
            "imageID":1739,
            "text":11409
         },{
            "imageID":1740,
            "text":11410
         },{
            "imageID":1741,
            "text":11411
         },{
            "imageID":1742,
            "text":11412
         },{
            "imageID":1743,
            "text":11413
         },{
            "imageID":1744,
            "text":11414
         },{
            "imageID":1745,
            "text":11415
         },{
            "imageID":1746,
            "text":11416
         },{
            "imageID":1747,
            "text":11417
         },{
            "imageID":1748,
            "text":11418
         },{
            "imageID":1749,
            "text":11419
         },{
            "imageID":1750,
            "text":11420
         },{
            "imageID":1751,
            "text":11421
         },{
            "imageID":1752,
            "text":11422
         },{
            "imageID":1753,
            "text":11423
         },{
            "imageID":1754,
            "text":11424
         },{
            "imageID":1755,
            "text":11425
         },{
            "imageID":1756,
            "text":11426
         },{
            "imageID":1757,
            "text":11427
         },{
            "imageID":1758,
            "text":11428
         },{
            "imageID":1759,
            "text":11429
         },{
            "imageID":1760,
            "text":11430
         }];
         _data = {
            "hurdles":[[1,0,0],[1,1,0],[1,2,0],[1,3,0],[1,4,0],[2,0,0],[2,1,0],[2,2,0],[2,3,0],[2,4,0],[2,5,0],[2,7,0],[2,8,0],[2,9,0]],
            "tiles":[[600],[500,0,0,10],[500,1,0,13],[500,2],[500,3],[500,4],[500,5],[500,6],[500,7],[500,8],[500,9],[500,10],[500,11],[500,12],[500,13],[500,3,400,4,0,5,400,3,400,4,0,6,400,3,400,4,0,5],[500,0,50,0,0,10,50,0],[500,3,50,3,0,5,50,3],[500,4,50,4,0,6,50,4],[500,2,0,8,400,2,400,2,0,8],[300,3,300,3,0,10,0,9,300,3],[300,4,300,4,300,4],[1200],[200],[200,2,0,8,200,2,0,9,200,2,0,8,200,2,0,9],[300,3,300,4,300,3,300,4,300,3,300,4],[0,4,50,4,50,4],[300,3,300,4,300,3,250,4,50,4,50,4,250,3,300,4],[500,2,50,2,0,5,50,2],[500,8,100,4,100,4,100,4,100,8],[500,13,0,0],[500,12,0,4],[500,7,0,9,0,3],[500,13,0,1],[300,3,225,4,225,3,225,4,225,3,225,4],[300,2,0,8,300,3,0,7],[400,12,0,3,250,4,350,1,50,13,100,0,50,10,75,1],[0,4,50,4,50,4,200,2,200,0,0,9,0,10,250,13,150,2,300,4,50,4,50,4],[500,12,0,4]],
            "proTracks":[[0,19,23,20,21,1,29,1,29,20,33,31,32,31,30,23,34,1,34,1,0,26,23,26,23,26,23,1,0,26,16,0,24,24,25,1,34,16,18,1,23,38,23,37,0,36],[0,19,0,26,23,26,23,1,0,26,16,0,24,24,25,1,34,16,18,1,0,26,23,20,21,1,29,1,29,20,33,31,32,31,30,23,34,1,34,1,23,38,23,36,0,37],[0,35,35,19,0,26,23,26,23,1,0,26,16,0,35,24,35,25,1,34,16,18,1,0,26,23,20,21,1,29,1,28,23,38,23,36,0,37,29,20,33,31,32,31,30,23,34,1,34,1],[0,19,0,20,21,1,29,1,29,20,33,31,32,31,30,23,34,1,34,1,0,35,35,0,26,23,26,23,26,23,1,0,26,16,0,35,24,35,25,1,34,16,18,1,23,38,23,37,0,36],[0,19,0,35,24,35,25,1,34,16,18,1,20,21,1,23,29,1,0,35,35,0,26,23,26,23,26,23,1,0,26,16,29,20,33,31,32,31,30,23,34,1,34,1,23,38,23,36,0,37]],
            "beginnerTracks":[[0,19,15,2,15,1,15,16,0,24,24,23,20,21,20,14,0,18,1,15,18,1,23,13,23,1,23,38,23,36,0,37],[0,19,23,20,21,20,14,0,15,2,15,1,15,16,0,13,23,1,23,38,23,36,0,37,23,24,24,18,1,15,18,1,28],[0,24,3,4,5,6,25,23,24,20,27,23,1,28,13,23,24,18,16,25,19,15,2,15,1,13,23,1,23,38,23,37,0,36],[0,19,23,20,21,20,14,0,15,2,15,1,15,16,0,24,24,25,1,25,16,18,1,28,23,38,23,36,0,37,13,23,1],[0,19,23,0,24,24,25,1,25,16,18,12,0,21,20,14,0,25,2,25,1,27,16,28,13,23,1,23,38,23,36,0,37]]
         };
      }
      
      public function getArrayStartIndex(param1:String, param2:int) : int
      {
         while(param1.charAt(param2) != "[" && param2 < param1.length)
         {
            param2++;
         }
         return param2 + 1;
      }
      
      public function getArrayEndIndex(param1:String, param2:int) : int
      {
         var _loc5_:String = null;
         var _loc3_:int = 0;
         var _loc4_:Boolean = false;
         while(!_loc4_)
         {
            if(param2 >= param1.length)
            {
               param2 = -1;
               _loc4_ = true;
            }
            else
            {
               _loc5_ = param1.charAt(param2);
               if(_loc5_ == "[")
               {
                  _loc3_++;
               }
               else if(_loc5_ == "]")
               {
                  if(_loc3_ == 0)
                  {
                     _loc4_ = true;
                  }
                  else
                  {
                     _loc3_--;
                  }
               }
               if(!_loc4_)
               {
                  param2++;
               }
            }
         }
         return param2;
      }
      
      public function parseArray(param1:Array, param2:String, param3:String) : void
      {
         var _loc8_:* = 0;
         var _loc10_:int = 0;
         var _loc4_:int = 0;
         var _loc7_:int = 0;
         var _loc12_:String = null;
         var _loc9_:Array = null;
         var _loc5_:Array = null;
         var _loc6_:int = 0;
         var _loc11_:int = int(param2.indexOf(param3));
         _loc8_ = getArrayStartIndex(param2,_loc11_);
         if(_loc8_ < param2.length)
         {
            _loc10_ = getArrayEndIndex(param2,_loc8_);
            if(_loc10_ != -1)
            {
               while(_loc8_ < _loc10_)
               {
                  _loc4_ = getArrayStartIndex(param2,_loc8_);
                  if(_loc4_ < _loc10_ && _loc4_ < param2.length)
                  {
                     _loc7_ = getArrayEndIndex(param2,_loc4_);
                     if(_loc7_ != -1)
                     {
                        _loc12_ = param2.substring(_loc4_,_loc7_);
                        _loc9_ = _loc12_.split(",");
                        _loc5_ = [];
                        _loc6_ = 0;
                        while(_loc6_ < _loc9_.length)
                        {
                           _loc5_.push(int(_loc9_[_loc6_]));
                           _loc6_++;
                        }
                        param1.push(_loc5_);
                     }
                     _loc8_ = _loc7_;
                  }
                  else
                  {
                     _loc8_ = _loc4_;
                  }
               }
            }
         }
      }
      
      public function loadFromFile() : void
      {
         MyFile = new FileReference();
         MyFile.addEventListener("select",selectHandler);
         var _loc2_:Array = [];
         var _loc1_:FileFilter = new FileFilter("Text Files (*.txt)","*.txt");
         _loc2_.push(_loc1_);
         MyFile.browse(_loc2_);
      }
      
      private function selectHandler(param1:Event) : void
      {
         MyFile.addEventListener("complete",onFileLoaded);
         MyFile.load();
      }
      
      public function onFileLoaded(param1:Event) : void
      {
         var _loc3_:FileReference = param1.target as FileReference;
         var _loc2_:ByteArray = _loc3_["data"];
         var _loc4_:String = _loc2_.toString();
         _data = {};
         _data.hurdles = [];
         _data.tiles = [];
         _data.proTracks = [];
         _data.beginnerTracks = [];
         parseArray(_data.hurdles,_loc4_,"hurdles:");
         parseArray(_data.tiles,_loc4_,"tiles:");
         parseArray(_data.proTracks,_loc4_,"proTracks:");
         parseArray(_data.beginnerTracks,_loc4_,"beginnerTracks:");
      }
   }
}

