package it.gotoandplay.smartfoxserver.util
{
   public class ObjectSerializer
   {
      private static var instance:ObjectSerializer;
      
      private var debug:Boolean;
      
      private var eof:String;
      
      private var tabs:String;
      
      public function ObjectSerializer(param1:Boolean = false)
      {
         super();
         this.tabs = "\t\t\t\t\t\t\t\t\t\t\t\t\t";
         setDebug(param1);
      }
      
      public static function getInstance(param1:Boolean = false) : ObjectSerializer
      {
         if(instance == null)
         {
            instance = new ObjectSerializer(param1);
         }
         return instance;
      }
      
      private function setDebug(param1:Boolean) : void
      {
         this.debug = param1;
         if(this.debug)
         {
            this.eof = "\n";
         }
         else
         {
            this.eof = "";
         }
      }
      
      public function serialize(param1:Object) : String
      {
         var _loc2_:Object = {};
         obj2xml(param1,_loc2_);
         return _loc2_.xmlStr;
      }
      
      public function deserialize(param1:String) : Object
      {
         var _loc3_:XML = new XML(param1);
         var _loc2_:Object = {};
         xml2obj(_loc3_,_loc2_);
         return _loc2_;
      }
      
      private function obj2xml(param1:Object, param2:Object, param3:int = 0, param4:String = "") : void
      {
         var _loc6_:String = null;
         var _loc5_:String = null;
         var _loc8_:* = undefined;
         if(param3 == 0)
         {
            param2.xmlStr = "<dataObj>" + this.eof;
         }
         else
         {
            if(this.debug)
            {
               param2.xmlStr += this.tabs.substr(0,param3);
            }
            _loc6_ = param1 is Array ? "a" : "o";
            param2.xmlStr += "<obj t=\'" + _loc6_ + "\' o=\'" + param4 + "\'>" + this.eof;
         }
         for(var _loc7_ in param1)
         {
            _loc5_ = typeof param1[_loc7_];
            _loc8_ = param1[_loc7_];
            if(_loc5_ == "boolean" || _loc5_ == "number" || _loc5_ == "string" || _loc5_ == "null")
            {
               if(_loc5_ == "boolean")
               {
                  _loc8_ = Number(_loc8_);
               }
               else if(_loc5_ == "null")
               {
                  _loc5_ = "x";
                  _loc8_ = "";
               }
               else if(_loc5_ == "string")
               {
                  _loc8_ = Entities.encodeEntities(_loc8_);
               }
               if(this.debug)
               {
                  param2.xmlStr += this.tabs.substr(0,param3 + 1);
               }
               param2.xmlStr += "<var n=\'" + _loc7_ + "\' t=\'" + _loc5_.substr(0,1) + "\'>" + _loc8_ + "</var>" + this.eof;
            }
            else if(_loc5_ == "object")
            {
               obj2xml(_loc8_,param2,param3 + 1,_loc7_);
               if(this.debug)
               {
                  param2.xmlStr += this.tabs.substr(0,param3 + 1);
               }
               param2.xmlStr += "</obj>" + this.eof;
            }
         }
         if(param3 == 0)
         {
            param2.xmlStr += "</dataObj>" + this.eof;
         }
      }
      
      private function xml2obj(param1:XML, param2:Object) : void
      {
         var _loc3_:String = null;
         var _loc9_:String = null;
         var _loc10_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc11_:String = null;
         var _loc7_:XMLList = param1.children();
         for each(var _loc4_ in _loc7_)
         {
            _loc3_ = _loc4_.name().toString();
            if(_loc3_ == "obj")
            {
               _loc9_ = _loc4_.@o;
               _loc10_ = _loc4_.@t;
               if(_loc10_ == "a")
               {
                  param2[_loc9_] = [];
               }
               else if(_loc10_ == "o")
               {
                  param2[_loc9_] = {};
               }
               xml2obj(_loc4_,param2[_loc9_]);
            }
            else if(_loc3_ == "var")
            {
               _loc5_ = _loc4_.@n;
               _loc6_ = _loc4_.@t;
               _loc11_ = _loc4_.toString();
               if(_loc6_ == "b")
               {
                  param2[_loc5_] = _loc11_ == "0" ? false : true;
               }
               else if(_loc6_ == "n")
               {
                  param2[_loc5_] = Number(_loc11_);
               }
               else if(_loc6_ == "s")
               {
                  param2[_loc5_] = _loc11_;
               }
               else if(_loc6_ == "x")
               {
                  param2[_loc5_] = null;
               }
            }
         }
      }
      
      private function encodeEntities(param1:String) : String
      {
         return param1;
      }
   }
}

