package ru.etcs.utils
{
   import flash.display.LoaderInfo;
   import flash.utils.ByteArray;
   
   public function getDefinitionNames(param1:Object, param2:Boolean = false, param3:Boolean = false) : Array
   {
      var _loc4_:ByteArray = null;
      if(param1 is LoaderInfo)
      {
         _loc4_ = (param1 as LoaderInfo).bytes;
      }
      else
      {
         if(!(param1 is ByteArray))
         {
            throw new ArgumentError("Error #1001: The specified data is invalid");
         }
         _loc4_ = param1 as ByteArray;
      }
      var _loc5_:uint = _loc4_.position;
      var _loc6_:Finder = new Finder(_loc4_);
      _loc4_.position = _loc5_;
      return _loc6_.getDefinitionNames(param2,param3);
   }
}

import flash.geom.Rectangle;
import flash.utils.ByteArray;

class Finder
{
   private var _data:SWFByteArray;
   
   private var _stringTable:Array;
   
   private var _namespaceTable:Array;
   
   private var _multinameTable:Array;
   
   public function Finder(param1:ByteArray)
   {
      super();
      this._data = new SWFByteArray(param1);
   }
   
   public function getDefinitionNames(param1:Boolean, param2:Boolean) : Array
   {
      var _loc7_:* = 0;
      var _loc8_:* = 0;
      var _loc3_:* = 0;
      var _loc10_:* = 0;
      var _loc11_:* = 0;
      var _loc9_:* = 0;
      var _loc4_:String = null;
      var _loc6_:int = 0;
      var _loc5_:* = 0;
      var _loc12_:Array = [];
      for(; this._data.bytesAvailable; this._data.position = _loc9_ + _loc3_)
      {
         _loc7_ = uint(this._data.readUnsignedShort());
         _loc8_ = uint(_loc7_ >> 6);
         _loc3_ = uint(_loc7_ & 0x3F);
         _loc3_ = uint(_loc3_ == 63 ? this._data.readUnsignedInt() : _loc3_);
         _loc9_ = uint(this._data.position);
         if(param2)
         {
            if(_loc8_ == 76)
            {
               _loc5_ = uint(this._data.readUnsignedShort());
               while(_loc5_--)
               {
                  this._data.readUnsignedShort();
                  _loc4_ = this._data.readString();
                  _loc6_ = int(_loc4_.lastIndexOf("."));
                  if(_loc6_ >= 0)
                  {
                     _loc4_ = _loc4_.substr(0,_loc6_) + "::" + _loc4_.substr(_loc6_ + 1);
                  }
                  _loc12_.push(_loc4_);
               }
            }
            continue;
         }
         switch(int(_loc8_) - 72)
         {
            case 0:
            case 10:
               if(_loc8_ == 82)
               {
                  this._data.position += 4;
                  this._data.readString();
               }
               _loc10_ = uint(this._data.readUnsignedShort());
               _loc11_ = uint(this._data.readUnsignedShort());
               if(_loc10_ == 16 && _loc11_ == 46)
               {
                  _loc12_.push.apply(_loc12_,this.getDefinitionNamesInTag(param1));
               }
               break;
         }
      }
      return _loc12_;
   }
   
   private function getDefinitionNamesInTag(param1:Boolean) : Array
   {
      var _loc5_:int = 0;
      var _loc4_:* = 0;
      var _loc14_:* = 0;
      var _loc6_:* = 0;
      var _loc7_:* = 0;
      var _loc3_:* = 0;
      var _loc13_:* = 0;
      var _loc8_:* = 0;
      var _loc15_:* = 0;
      var _loc17_:int = 0;
      var _loc12_:String = null;
      var _loc16_:Boolean = false;
      var _loc2_:Array = null;
      var _loc9_:* = !param1;
      var _loc11_:Array = [];
      this._stringTable = [];
      this._namespaceTable = [];
      this._multinameTable = [];
      _loc5_ = this._data.readASInt() - 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         this._data.readASInt();
      }
      _loc5_ = this._data.readASInt() - 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         this._data.readASInt();
      }
      _loc5_ = this._data.readASInt() - 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         this._data.readDouble();
      }
      _loc5_ = this._data.readASInt() - 1;
      _loc14_ = 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         this._stringTable[_loc14_] = this._data.readUTFBytes(this._data.readASInt());
         _loc14_++;
      }
      _loc5_ = this._data.readASInt() - 1;
      _loc14_ = 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         _loc4_ = uint(this._data.readUnsignedByte());
         _loc3_ = uint(this._data.readASInt());
         if(_loc4_ == 22)
         {
            this._namespaceTable[_loc14_] = _loc3_;
         }
         _loc14_++;
      }
      _loc5_ = this._data.readASInt() - 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         _loc7_ = uint(this._data.readUnsignedByte());
         while(_loc7_--)
         {
            this._data.readASInt();
         }
      }
      _loc5_ = this._data.readASInt() - 1;
      _loc14_ = 1;
      while(_loc5_ > 0 && _loc5_--)
      {
         switch(_loc4_ = uint(this._data.readASInt()))
         {
            case 7:
            case 13:
               _loc3_ = uint(this._data.readASInt());
               break;
            case 15:
            case 16:
               this._multinameTable[_loc14_] = [0,this._stringTable[this._data.readASInt()]];
               break;
            case 17:
            case 18:
               break;
            case 9:
            case 14:
               this._multinameTable[_loc14_] = [0,this._stringTable[this._data.readASInt()]];
               this._data.readASInt();
               break;
            case 27:
            case 28:
               this._data.readASInt();
               break;
            case 29:
               if(param1)
               {
                  _loc13_ = uint(this._data.readASInt());
                  _loc8_ = uint(this._data.readASInt());
                  _loc12_ = this.getName(_loc13_);
                  while(_loc8_--)
                  {
                     _loc15_ = uint(this._data.readASInt());
                     if(_loc12_)
                     {
                        _loc12_ = _loc12_ + ".<" + this.getName(_loc15_) + ">";
                        _loc11_.push(_loc12_);
                     }
                  }
                  this._multinameTable[_loc14_] = [0,_loc12_];
               }
               else
               {
                  this._data.readASInt();
                  this._data.readASInt();
                  this._data.readASInt();
               }
               break;
         }
         this._multinameTable[_loc14_] = [_loc3_,this._data.readASInt()];
         _loc14_++;
      }
      _loc5_ = int(this._data.readASInt());
      while(_loc5_ > 0 && _loc5_--)
      {
         _loc7_ = uint(_loc17_ = int(this._data.readASInt()));
         this._data.readASInt();
         while(_loc7_--)
         {
            this._data.readASInt();
         }
         this._data.readASInt();
         _loc6_ = uint(this._data.readUnsignedByte());
         if(_loc6_ & 8)
         {
            _loc7_ = uint(this._data.readASInt());
            while(_loc7_--)
            {
               this._data.readASInt();
               this._data.readASInt();
            }
         }
         if(_loc6_ & 0x80)
         {
            _loc7_ = uint(_loc17_);
            while(_loc7_--)
            {
               this._data.readASInt();
            }
         }
      }
      _loc5_ = int(this._data.readASInt());
      while(_loc5_ > 0 && _loc5_--)
      {
         this._data.readASInt();
         _loc7_ = uint(this._data.readASInt());
         while(_loc7_--)
         {
            this._data.readASInt();
            this._data.readASInt();
         }
      }
      var _loc10_:uint = uint(_loc5_ = int(this._data.readASInt()));
      while(_loc5_ > 0 && _loc5_--)
      {
         _loc14_ = uint(this._data.readASInt());
         this._data.readASInt();
         _loc6_ = uint(this._data.readUnsignedByte());
         if(_loc6_ & 8)
         {
            _loc3_ = uint(this._data.readASInt());
         }
         _loc16_ = Boolean(_loc6_ & 4);
         _loc7_ = uint(this._data.readASInt());
         while(_loc7_--)
         {
            this._data.readASInt();
         }
         this._data.readASInt();
         this.readTraits();
         if(_loc9_ && !_loc16_)
         {
            _loc12_ = this.getName(_loc14_);
            if(_loc12_)
            {
               _loc11_.push(_loc12_);
            }
         }
      }
      if(_loc9_)
      {
         return _loc11_;
      }
      _loc5_ = int(_loc10_);
      while(_loc5_ && _loc5_--)
      {
         this._data.readASInt();
         this.readTraits();
      }
      _loc5_ = int(this._data.readASInt());
      while(_loc5_ && _loc5_--)
      {
         this._data.readASInt();
         _loc2_ = this.readTraits(true);
         if(_loc2_.length)
         {
            _loc11_.push.apply(_loc11_,_loc2_);
         }
      }
      return _loc11_;
   }
   
   private function readTraits(param1:Boolean = false) : Array
   {
      var _loc5_:* = 0;
      var _loc8_:* = 0;
      var _loc9_:* = 0;
      var _loc3_:Array = null;
      var _loc7_:String = null;
      var _loc10_:* = 0;
      var _loc2_:* = 0;
      var _loc6_:uint = uint(this._data.readASInt());
      if(param1)
      {
         _loc3_ = [];
      }
      while(_loc6_--)
      {
         _loc9_ = uint(this._data.readASInt());
         _loc5_ = uint(this._data.readUnsignedByte());
         _loc10_ = uint(_loc5_ >> 4);
         _loc2_ = uint(_loc5_ & 0x0F);
         this._data.readASInt();
         this._data.readASInt();
         switch(int(_loc2_))
         {
            case 0:
            case 6:
               if(this._data.readASInt())
               {
                  this._data.readASInt();
                  break;
               }
         }
         if(param1)
         {
            _loc7_ = this.getName(_loc9_);
            if(_loc7_)
            {
               _loc3_.push(_loc7_);
            }
         }
         if(_loc10_ & 4)
         {
            _loc8_ = uint(this._data.readASInt());
            while(_loc8_--)
            {
               this._data.readASInt();
            }
         }
      }
      return _loc3_;
   }
   
   private function getName(param1:uint) : String
   {
      if(!(param1 in this._multinameTable))
      {
         return null;
      }
      var _loc2_:Array = this._multinameTable[param1] as Array;
      var _loc3_:uint = _loc2_[0] as uint;
      var _loc5_:String = this._stringTable[this._namespaceTable[_loc3_] as uint] as String;
      var _loc4_:String = _loc2_[1] is String ? _loc2_[1] : this._stringTable[_loc2_[1] as uint] as String;
      if(_loc5_ && _loc5_.indexOf("__AS3__") < 0)
      {
         _loc4_ = _loc5_ + "::" + _loc4_;
      }
      return _loc4_;
   }
}

class SWFByteArray extends ByteArray
{
   private static const TAG_SWF:String = "FWS";
   
   private static const TAG_SWF_COMPRESSED:String = "CWS";
   
   private var _bitIndex:uint;
   
   private var _version:uint;
   
   private var _frameRate:Number;
   
   private var _rect:Rectangle;
   
   public function SWFByteArray(param1:ByteArray = null)
   {
      var _loc3_:String = null;
      var _loc2_:String = null;
      super();
      super.endian = "littleEndian";
      if(param1)
      {
         _loc3_ = param1.endian;
         param1.endian = "littleEndian";
         if(param1.bytesAvailable > 26)
         {
            _loc2_ = param1.readUTFBytes(3);
            if(!(_loc2_ == "FWS" || _loc2_ == "CWS"))
            {
               throw new ArgumentError("Error #2124: Loaded file is an unknown type.");
            }
            this._version = param1.readUnsignedByte();
            param1.readUnsignedInt();
            param1.readBytes(this);
            if(_loc2_ == "CWS")
            {
               super.uncompress();
            }
            this.readHeader();
         }
         param1.endian = _loc3_;
      }
   }
   
   public function get version() : uint
   {
      return this._version;
   }
   
   public function get frameRate() : Number
   {
      return this._frameRate;
   }
   
   public function get rect() : Rectangle
   {
      return this._rect;
   }
   
   public function writeBytesFromString(param1:String) : void
   {
      var _loc4_:* = 0;
      var _loc5_:String = null;
      var _loc2_:* = 0;
      var _loc3_:uint = uint(param1.length);
      _loc4_ = 0;
      while(_loc4_ < _loc3_)
      {
         _loc5_ = param1.substr(_loc4_,2);
         _loc2_ = parseInt(_loc5_,16);
         writeByte(_loc2_);
         _loc4_ += 2;
      }
   }
   
   public function readRect() : Rectangle
   {
      var _loc3_:uint = uint(super.position);
      var _loc4_:uint = uint(this[_loc3_]);
      var _loc5_:uint = uint(_loc4_ >> 3);
      var _loc7_:Number = this.readBits(_loc5_,5) / 20;
      var _loc6_:Number = this.readBits(_loc5_) / 20;
      var _loc1_:Number = this.readBits(_loc5_) / 20;
      var _loc2_:Number = this.readBits(_loc5_) / 20;
      super.position = _loc3_ + Math.ceil((_loc5_ * 4 - 3) / 8) + 1;
      return new Rectangle(_loc7_,_loc1_,_loc6_ - _loc7_,_loc2_ - _loc1_);
   }
   
   public function readBits(param1:uint, param2:int = -1) : Number
   {
      if(param2 < 0)
      {
         param2 = int(this._bitIndex);
      }
      this._bitIndex = param2;
      var _loc4_:uint = uint(this[super.position]);
      var _loc7_:Number = 0;
      var _loc6_:uint = uint(8 - param2);
      var _loc3_:Number = param1 - _loc6_;
      if(_loc3_ > 0)
      {
         position++;
         _loc7_ = this.readBits(_loc3_,0) | (_loc4_ & (1 << _loc6_) - 1) << _loc3_;
      }
      else
      {
         _loc7_ = _loc4_ >> 8 - param1 - param2 & (1 << param1) - 1;
         this._bitIndex = (param2 + param1) % 8;
         if(param2 + param1 > 7)
         {
            position++;
         }
      }
      return _loc7_;
   }
   
   public function readASInt() : int
   {
      var _loc2_:* = 0;
      var _loc1_:uint = 0;
      var _loc3_:uint = 0;
      do
      {
         _loc2_ = super.readUnsignedByte();
         _loc1_ |= (_loc2_ & 0x7F) << _loc3_ * 7;
         _loc3_ += 1;
      }
      while(_loc2_ & 0x80);
      
      return _loc1_;
   }
   
   public function readString() : String
   {
      var _loc2_:uint = uint(super.position);
      while(this[_loc2_] && ++_loc2_)
      {
      }
      var _loc1_:String = super.readUTFBytes(_loc2_ - super.position);
      super.position = _loc2_ + 1;
      return _loc1_;
   }
   
   public function traceArray(param1:ByteArray) : String
   {
      var _loc2_:String = null;
      var _loc5_:String = "";
      var _loc3_:uint = param1.position;
      param1.position = 0;
      while(param1.bytesAvailable)
      {
         _loc2_ = param1.readUnsignedByte().toString(16).toUpperCase();
         _loc2_ = _loc2_.length < 2 ? "0" + _loc2_ : _loc2_;
         _loc5_ += _loc2_ + " ";
      }
      param1.position = _loc3_;
      return _loc5_;
   }
   
   private function readFrameRate() : void
   {
      var _loc1_:Number = NaN;
      if(this._version < 8)
      {
         this._frameRate = super.readUnsignedShort();
      }
      else
      {
         _loc1_ = super.readUnsignedByte() / 255;
         this._frameRate = super.readUnsignedByte() + _loc1_;
      }
   }
   
   private function readHeader() : void
   {
      this._rect = this.readRect();
      this.readFrameRate();
      super.readShort();
   }
}
