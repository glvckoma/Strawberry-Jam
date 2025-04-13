package game.pillBugs
{
   import flash.events.Event;
   import flash.events.ProgressEvent;
   import flash.net.*;
   import flash.text.*;
   import flash.utils.*;
   
   public class PillBugsLevelConverter
   {
      public var _outFile:FileReference;
      
      public var _myFile:FileReference;
      
      public var _outputReadyState:int;
      
      public var _output:Array;
      
      public var _outputString:String;
      
      public function PillBugsLevelConverter()
      {
         super();
      }
      
      public function convertFile() : void
      {
         _outputReadyState = 0;
         _myFile = new FileReference();
         _myFile.addEventListener("select",selectHandler);
         _myFile.addEventListener("ioError",onFileLoadError);
         _myFile.addEventListener("progress",onProgress);
         var _loc2_:Array = [];
         var _loc1_:FileFilter = new FileFilter("Comma Separated Files (*.csv)","*.csv");
         _loc2_.push(_loc1_);
         _myFile.browse(_loc2_);
      }
      
      private function selectHandler(param1:Event) : void
      {
         _myFile.removeEventListener("select",selectHandler);
         _myFile.addEventListener("complete",onFileLoaded);
         _myFile.load();
      }
      
      private function onProgress(param1:ProgressEvent) : void
      {
         var _loc2_:Number = param1.bytesLoaded / param1.bytesTotal * 100;
         trace("loaded: " + _loc2_ + "%");
      }
      
      private function onFileLoadError(param1:Event) : void
      {
         _myFile.removeEventListener("complete",onFileLoaded);
         _myFile.removeEventListener("ioError",onFileLoadError);
         _myFile.removeEventListener("progress",onProgress);
         trace("File load error");
      }
      
      public function onFileLoaded(param1:Event) : void
      {
         var _loc6_:int = 0;
         var _loc7_:String = null;
         var _loc8_:String = null;
         var _loc4_:int = 0;
         var _loc3_:Boolean = false;
         var _loc14_:String = null;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         _myFile.removeEventListener("complete",onFileLoaded);
         _myFile.removeEventListener("ioError",onFileLoadError);
         _myFile.removeEventListener("progress",onProgress);
         var _loc5_:int = 0;
         var _loc13_:FileReference = param1.target as FileReference;
         var _loc2_:ByteArray = _loc13_["data"];
         var _loc11_:String = _loc2_.toString();
         _output = [];
         _output["level"] = 1;
         _output["x"] = 10;
         _output["y"] = 10;
         _output["gameboard"] = [];
         _output["pegs"] = 10;
         _output["easy"] = 20;
         _output["medium"] = 18;
         _output["hard"] = 16;
         _loc5_ = int(_loc11_.indexOf("easy=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["easy"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("medium=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["medium"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("hard=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["hard"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("level=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["level"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("x=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["x"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("y=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["y"] = int(_loc7_);
         }
         _loc5_ = int(_loc11_.indexOf("pegs=",0));
         if(_loc5_ != -1)
         {
            _loc5_ = int(_loc11_.indexOf("=",_loc5_));
            _loc5_++;
            _loc6_ = int(_loc11_.indexOf(",",_loc5_));
            _loc7_ = _loc11_.substring(_loc5_,_loc6_);
            _output["pegs"] = int(_loc7_);
         }
         var _loc12_:int = 1;
         while(_loc5_ < _loc11_.length)
         {
            _loc8_ = _loc12_ + ",";
            _loc5_ = int(_loc11_.indexOf(_loc8_,_loc5_));
            if(_loc5_ == -1)
            {
               break;
            }
            _loc5_ += _loc8_.length;
            if(_loc5_ >= _loc11_.length)
            {
               break;
            }
            _output["gameboard"][_loc12_ - 1] = [];
            _loc4_ = 0;
            _loc3_ = true;
            while(_loc11_.charAt(_loc5_) == "," || _loc11_.charAt(_loc5_) == "1" || _loc11_.charAt(_loc5_) == "2" || _loc11_.charAt(_loc5_) == "3" || _loc11_.charAt(_loc5_) == "4" || _loc11_.charAt(_loc5_) == "5" || _loc11_.charAt(_loc5_) == "a" || _loc11_.charAt(_loc5_) == "A" || _loc11_.charAt(_loc5_) == "b" || _loc11_.charAt(_loc5_) == "B" || _loc11_.charAt(_loc5_) == "c" || _loc11_.charAt(_loc5_) == "C" || _loc11_.charAt(_loc5_) == "d" || _loc11_.charAt(_loc5_) == "D" || _loc11_.charAt(_loc5_) == "e" || _loc11_.charAt(_loc5_) == "E")
            {
               _loc14_ = _loc11_.charAt(_loc5_);
               switch(_loc11_.charAt(_loc5_))
               {
                  case "1":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 1;
                     _loc3_ = false;
                     break;
                  case "2":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 2;
                     _loc3_ = false;
                     break;
                  case "3":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 3;
                     _loc3_ = false;
                     break;
                  case "4":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 4;
                     _loc3_ = false;
                     break;
                  case "5":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 5;
                     _loc3_ = false;
                     break;
                  case "a":
                  case "A":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 101;
                     break;
                  case "b":
                  case "B":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 102;
                     _loc3_ = false;
                     break;
                  case "c":
                  case "C":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 103;
                     _loc3_ = false;
                     break;
                  case "d":
                  case "D":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 104;
                     _loc3_ = false;
                     break;
                  case "e":
                  case "E":
                     _output["gameboard"][_loc12_ - 1][_loc4_] = 105;
                     _loc3_ = false;
                     break;
                  case ",":
                     if(_loc3_)
                     {
                        _output["gameboard"][_loc12_ - 1][_loc4_] = 0;
                     }
                     _loc3_ = true;
                     _loc4_++;
                     break;
               }
               _loc3_ = false;
               _loc5_++;
            }
            if(_loc3_)
            {
               _output["gameboard"][_loc12_ - 1][_loc4_] = 0;
            }
            _loc12_++;
         }
         _outputString = new String();
         _outputString += "[\r\n";
         _outputString += "\t{\r\n\t level:" + _output["level"] + ",\r\n\t sizeX:" + _output["x"] + ",\r\n\t sizeY:" + _output["y"] + ",\r\n\t pegs:" + _output["pegs"] + ",\r\n\t easy:" + _output["easy"] + ",\r\n\t medium:" + _output["medium"] + ",\r\n\t hard:" + _output["hard"] + ",\r\n";
         _outputString += "\t gameboard:\r\n\t\t[\r\n";
         _loc10_ = 0;
         while(_loc10_ < _output["gameboard"].length)
         {
            _outputString += "\t\t\t[";
            _loc9_ = 0;
            while(_loc9_ < _output["gameboard"][_loc10_].length)
            {
               if(_loc9_ != 0)
               {
                  _outputString += ",";
               }
               _outputString += _output["gameboard"][_loc10_][_loc9_];
               _loc9_++;
            }
            if(_loc10_ < _output["gameboard"].length - 1)
            {
               _outputString += "],\r\n";
            }
            else
            {
               _outputString += "]\r\n";
            }
            _loc10_++;
         }
         _outputString += "\t\t]\r\n\t}\r\n]\r\n";
         _outputReadyState = 1;
      }
      
      public function saveFile() : void
      {
         _outFile = new FileReference();
         if(_outputReadyState != 0)
         {
            _outFile.save(_outputString,"level.txt");
         }
      }
   }
}

