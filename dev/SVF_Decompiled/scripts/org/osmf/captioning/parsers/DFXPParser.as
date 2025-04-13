package org.osmf.captioning.parsers
{
   import flash.utils.Dictionary;
   import org.osmf.captioning.model.Caption;
   import org.osmf.captioning.model.CaptionFormat;
   import org.osmf.captioning.model.CaptionStyle;
   import org.osmf.captioning.model.CaptioningDocument;
   import org.osmf.utils.TimeUtil;
   
   public class DFXPParser implements ICaptioningParser
   {
      private var ns:Namespace;
      
      private var ttm:Namespace;
      
      private var tts:Namespace;
      
      private var rootNamespace:Namespace;
      
      private var namedColorMap:Dictionary;
      
      public function DFXPParser()
      {
         super();
         namedColorMap = new Dictionary();
         namedColorMap["transparent"] = 0;
         namedColorMap["black"] = 0;
         namedColorMap["silver"] = 12632256;
         namedColorMap["gray"] = 8421504;
         namedColorMap["white"] = 16777215;
         namedColorMap["maroon"] = 8388608;
         namedColorMap["red"] = 16711680;
         namedColorMap["purple"] = 8388736;
         namedColorMap["fuchsia"] = 16711935;
         namedColorMap["magenta"] = 16711935;
         namedColorMap["green"] = 32768;
         namedColorMap["lime"] = 65280;
         namedColorMap["olive"] = 8421376;
         namedColorMap["yellow"] = 16776960;
         namedColorMap["navy"] = 128;
         namedColorMap["blue"] = 255;
         namedColorMap["teal"] = 32896;
         namedColorMap["aqua"] = 65535;
         namedColorMap["cyan"] = 65535;
      }
      
      public function parse(param1:String) : CaptioningDocument
      {
         var _loc2_:XML = null;
         var _loc3_:CaptioningDocument = new CaptioningDocument();
         var _loc4_:Boolean = Boolean(XML.ignoreWhitespace);
         var _loc6_:Boolean = Boolean(XML.prettyPrinting);
         var _loc5_:String = param1.replace(/\s+$/,"");
         _loc5_ = _loc5_.replace(/>\s+</g,"><");
         XML.ignoreWhitespace = false;
         XML.prettyPrinting = false;
         try
         {
            _loc2_ = new XML(_loc5_);
         }
         catch(e:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + e.message);
            throw e;
         }
         finally
         {
            XML.ignoreWhitespace = _loc4_;
            XML.prettyPrinting = _loc6_;
         }
         rootNamespace = _loc2_.namespace();
         ns = _loc2_.namespace();
         ttm = _loc2_.namespace("ttm");
         tts = _loc2_.namespace("tts");
         try
         {
            parseHead(_loc3_,_loc2_);
            parseBody(_loc3_,_loc2_);
         }
         catch(err:Error)
         {
            debugLog("Unhandled exception in DFXPParser : " + err.message);
            throw err;
         }
         return _loc3_;
      }
      
      private function parseHead(param1:CaptioningDocument, param2:XML) : void
      {
         var _loc7_:XMLList = null;
         var _loc6_:* = 0;
         var _loc5_:XML = null;
         var _loc3_:CaptionStyle = null;
         try
         {
            param1.title = param2..ttm::title.text();
            param1.description = param2..ttm::desc.text();
            param1.copyright = param2..ttm::copyright.text();
         }
         catch(err:Error)
         {
            if(err.errorID != 1080)
            {
               throw err;
            }
         }
         var _loc4_:XMLList = param2..ns::styling;
         if(_loc4_.length())
         {
            _loc7_ = _loc4_.children();
            _loc6_ = 0;
            while(_loc6_ < _loc7_.length())
            {
               _loc5_ = _loc7_[_loc6_];
               _loc3_ = createStyleObject(_loc5_);
               param1.addStyle(_loc3_);
               _loc6_++;
            }
         }
      }
      
      private function createStyleObject(param1:XML) : CaptionStyle
      {
         var _loc4_:Object = null;
         var _loc6_:String = param1.@id;
         var _loc2_:CaptionStyle = new CaptionStyle(_loc6_);
         var _loc3_:String = param1.tts::@backgroundColor;
         if(_loc3_ != "")
         {
            _loc4_ = parseColor(_loc3_);
            _loc2_.backgroundColor = _loc4_.color;
            _loc2_.backgroundColorAlpha = _loc4_.alpha;
         }
         _loc2_.textAlign = param1.tts::@textAlign;
         _loc3_ = param1.tts::@color;
         if(_loc3_ != "")
         {
            _loc4_ = parseColor(_loc3_);
            _loc2_.textColor = _loc4_.color;
            _loc2_.textColorAlpha = _loc4_.alpha;
         }
         _loc2_.fontFamily = parseFontFamily(param1.tts::@fontFamily);
         var _loc5_:String = parseFontSize(param1.tts::@fontSize);
         _loc2_.fontSize = parseInt(_loc5_);
         _loc2_.fontStyle = param1.tts::@fontStyle;
         _loc2_.fontWeight = param1.tts::@fontWeight;
         _loc2_.wrapOption = String(param1.tts::@wrapOption).toLowerCase() == "nowrap" ? false : true;
         return _loc2_;
      }
      
      private function parseColor(param1:String) : Object
      {
         var _loc4_:Object = null;
         var _loc5_:Object = null;
         var _loc3_:RegExp = /^\s*#([\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f][\dA-Fa-f])([\dA-Fa-f][\dA-Fa-f])?\s*$/;
         var _loc2_:Array = param1.match(_loc3_);
         if(_loc2_ != null)
         {
            _loc4_ = parseInt(_loc2_[1],16);
            if(_loc2_.length == 3)
            {
               _loc5_ = parseInt(_loc2_[2]) / 255;
            }
         }
         else
         {
            _loc3_ = /^\s*rgb(a)?\((\d+),(\d+),(\d+)(\)|(,(\d+)\)))\s*$/i;
            _loc2_ = param1.match(_loc3_);
            if(_loc2_ != null && _loc2_.length >= 5)
            {
               _loc4_ = (parseInt(_loc2_[2]) << 16) + (parseInt(_loc2_[3]) << 8) + parseInt(_loc2_[4]);
               if(_loc2_.length == 8 && _loc2_[7] != undefined)
               {
                  _loc5_ = parseInt(_loc2_[7]) / 255;
               }
            }
            else
            {
               _loc4_ = namedColorMap[param1.toLowerCase()];
               if(_loc4_ == null)
               {
                  _loc4_ = parseInt(param1);
                  if(isNaN(int(_loc4_)))
                  {
                     _loc4_ = null;
                     debugLog("Invalid DFXP document: invalid color value of " + param1);
                  }
               }
            }
         }
         return {
            "color":_loc4_,
            "alpha":_loc5_
         };
      }
      
      private function parseFontSize(param1:String) : String
      {
         var _loc8_:RegExp = null;
         var _loc4_:Object = null;
         var _loc7_:RegExp = null;
         var _loc2_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc3_:String = "";
         var _loc6_:RegExp = new RegExp(/^\s*\d+%.*$/);
         var _loc5_:Object = _loc6_.exec(param1);
         if(_loc5_)
         {
            debugLog("Invalid DFXP document: percentages are not supported for font size.");
            _loc3_ = "";
         }
         else
         {
            _loc8_ = new RegExp(/^\s*[\+\-]\d.*/);
            _loc4_ = _loc8_.exec(param1);
            if(_loc4_)
            {
               debugLog("Invalid DFXP document: increment values are not supported for font size.");
               _loc3_ = "";
            }
            else
            {
               _loc7_ = new RegExp(/^\s*(\d+).*$/);
               _loc2_ = _loc7_.exec(param1);
               if(_loc2_ && _loc2_[1] != undefined)
               {
                  _loc3_ = _loc2_[1];
               }
            }
         }
         return _loc3_;
      }
      
      private function parseFontFamily(param1:String) : String
      {
         var _loc2_:Object = null;
         if(!param1 || param1 == "")
         {
            return "";
         }
         var _loc3_:String = "";
         var _loc5_:RegExp = new RegExp(/^\s*([^,\s]+)\s*((,\s*([^,\s]+)\s*)*)$/);
         var _loc4_:Boolean = false;
         do
         {
            _loc2_ = _loc5_.exec(param1);
            if(!_loc2_)
            {
               _loc4_ = true;
            }
            else
            {
               if(_loc3_.length > 0)
               {
                  _loc3_ += ",";
               }
               switch(_loc2_[1])
               {
                  case "default":
                  case "serif":
                  case "proportionalSerif":
                     _loc3_ += "_serif";
                     break;
                  case "monospace":
                  case "monospaceSansSerif":
                  case "monospaceSerif":
                     _loc3_ += "_typewriter";
                     break;
                  case "sansSerif":
                  case "proportionalSansSerif":
                     _loc3_ += "_sans";
                     break;
                  default:
                     _loc3_ += _loc2_[1];
               }
               if(_loc2_[2] != undefined && _loc2_[2] != "")
               {
                  param1 = _loc2_[2].slice(1);
               }
               else
               {
                  _loc4_ = true;
               }
            }
         }
         while(!_loc4_);
         
         return _loc3_;
      }
      
      private function parseBody(param1:CaptioningDocument, param2:XML) : void
      {
         var _loc3_:XMLList = null;
         var _loc4_:XMLList = null;
         var _loc5_:* = 0;
         var _loc7_:XML = null;
         var _loc6_:XMLList = param2..ns::body;
         if(_loc6_.length() <= 0)
         {
            debugLog("Invalid DFXP document: <body> tag is required.");
         }
         else
         {
            _loc3_ = param2..ns::div;
            _loc4_ = !!_loc3_.length() ? _loc3_.children() : (!!_loc6_.length() ? _loc6_.children() : new XMLList());
            _loc5_ = 0;
            while(_loc5_ < _loc4_.length())
            {
               _loc7_ = _loc4_[_loc5_];
               if(rootNamespace == _loc7_.namespace())
               {
                  parsePTag(param1,_loc7_,_loc5_);
               }
               else
               {
                  debugLog("Ignoring this tag, foreign namespaces not supported: \"" + _loc7_ + "\"");
               }
               _loc5_++;
            }
         }
      }
      
      private function parsePTag(param1:CaptioningDocument, param2:XML, param3:uint) : void
      {
         var _loc10_:* = 0;
         var _loc22_:XML = null;
         var _loc20_:* = 0;
         var _loc5_:Array = null;
         var _loc6_:* = 0;
         var _loc12_:CaptionFormat = null;
         var _loc17_:CaptionFormat = null;
         var _loc19_:String = param2.@begin;
         var _loc16_:String = param2.@end;
         var _loc4_:String = param2.@dur;
         if(_loc19_ == "")
         {
            _loc19_ = "0s";
         }
         var _loc9_:Number = TimeUtil.parseTime(_loc19_);
         var _loc13_:Number = 0;
         if(_loc16_ != "")
         {
            _loc13_ = TimeUtil.parseTime(_loc16_);
         }
         else if(_loc4_ != "")
         {
            _loc13_ = _loc9_ + TimeUtil.parseTime(_loc4_);
         }
         var _loc7_:Array = [];
         var _loc18_:String = new String("<p>");
         var _loc15_:XMLList = param2.children();
         _loc10_ = 0;
         for(; _loc10_ < _loc15_.length(); _loc10_++)
         {
            switch((_loc22_ = _loc15_[_loc10_]).nodeKind())
            {
               case "text":
                  _loc18_ += formatCCText(_loc22_.toString());
                  break;
               case "element":
                  switch(_loc22_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "span":
                        _loc20_ = uint(calcClearTextLength(_loc18_));
                        _loc5_ = [];
                        _loc18_ += parseSpanTag(param1,_loc22_,_loc5_);
                        _loc6_ = uint(calcClearTextLength(_loc18_));
                        for each(var _loc8_ in _loc5_)
                        {
                           _loc12_ = new CaptionFormat(_loc8_,_loc20_,_loc6_);
                           _loc7_.push(_loc12_);
                        }
                        continue;
                     case "br":
                        _loc18_ += "<br />";
                        continue;
                     default:
                        _loc18_ += formatCCText(_loc22_.toString());
                        continue;
                  }
                  break;
            }
         }
         _loc18_ += "</p>";
         var _loc21_:Caption = new Caption(param3,_loc9_,_loc13_,_loc18_);
         var _loc14_:CaptionStyle = parseStyleAttrib(param1,param2);
         if(_loc14_)
         {
            _loc17_ = new CaptionFormat(_loc14_);
            _loc21_.addCaptionFormat(_loc17_);
         }
         _loc10_ = 0;
         while(_loc10_ < _loc7_.length)
         {
            _loc21_.addCaptionFormat(_loc7_[_loc10_]);
            _loc10_++;
         }
         param1.addCaption(_loc21_);
      }
      
      private function parseStyleAttrib(param1:CaptioningDocument, param2:XML) : CaptionStyle
      {
         var _loc7_:* = 0;
         var _loc8_:XMLList = null;
         var _loc5_:XML = null;
         var _loc4_:String = null;
         var _loc6_:String = param2.@style;
         var _loc3_:CaptionStyle = null;
         if(_loc6_ != "")
         {
            while(_loc7_ < param1.numStyles)
            {
               if(param1.getStyleAt(_loc7_).id == _loc6_)
               {
                  _loc3_ = param1.getStyleAt(_loc7_);
               }
               _loc7_++;
            }
         }
         else
         {
            try
            {
               _loc8_ = param2.tts::@*;
            }
            catch(err:Error)
            {
               if(err.errorID != 1080)
               {
                  throw err;
               }
            }
            _loc7_ = 0;
            while(_loc8_ != null && _loc7_ < _loc8_.length())
            {
               _loc5_ = _loc8_[_loc7_];
               _loc4_ = _loc5_.localName();
               if(_loc4_ != "inherit")
               {
                  _loc3_ = createStyleObject(param2);
               }
               _loc7_++;
            }
         }
         return _loc3_;
      }
      
      private function parseSpanTag(param1:CaptioningDocument, param2:XML, param3:Array) : String
      {
         var _loc7_:* = 0;
         var _loc8_:XML = null;
         var _loc4_:CaptionStyle = parseStyleAttrib(param1,param2);
         if(_loc4_ != null)
         {
            param3.push(_loc4_);
         }
         var _loc6_:String = new String();
         var _loc5_:XMLList = param2.children();
         _loc7_ = 0;
         for(; _loc7_ < _loc5_.length(); _loc7_++)
         {
            switch((_loc8_ = _loc5_[_loc7_]).nodeKind())
            {
               case "text":
                  _loc6_ += formatCCText(_loc8_.toString());
                  break;
               case "element":
                  switch(_loc8_.localName())
                  {
                     case "set":
                     case "metadata":
                        break;
                     case "br":
                        _loc6_ += "<br/>";
                        continue;
                     default:
                        _loc6_ += _loc8_.toString();
                        continue;
                  }
                  break;
            }
         }
         return _loc6_;
      }
      
      private function formatCCText(param1:String) : String
      {
         return param1.replace(/\s+/g," ");
      }
      
      private function calcClearTextLength(param1:String) : int
      {
         var _loc2_:String = param1.replace(/<(.|\n)*?>/g,"");
         return _loc2_.length;
      }
      
      private function debugLog(param1:String) : void
      {
      }
   }
}

