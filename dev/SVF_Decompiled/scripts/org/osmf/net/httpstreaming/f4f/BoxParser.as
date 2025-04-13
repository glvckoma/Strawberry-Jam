package org.osmf.net.httpstreaming.f4f
{
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.ByteArray;
   
   internal class BoxParser extends EventDispatcher
   {
      private static const FULL_BOX_FIELD_FLAGS_LENGTH:uint = 3;
      
      private static const AFRA_MASK_LONG_ID:uint = 128;
      
      private static const AFRA_MASK_LONG_OFFSET:uint = 64;
      
      private static const AFRA_MASK_GLOBAL_ENTRIES:uint = 32;
      
      private var _ba:ByteArray;
      
      public function BoxParser()
      {
         super();
         _ba = null;
      }
      
      public function init(param1:ByteArray) : void
      {
         _ba = param1;
         _ba.position = 0;
      }
      
      public function getNextBoxInfo() : BoxInfo
      {
         if(_ba == null || _ba.bytesAvailable < 4 + 4)
         {
            return null;
         }
         var _loc1_:Number = _ba.readUnsignedInt();
         var _loc2_:String = _ba.readUTFBytes(4);
         return new BoxInfo(_loc1_,_loc2_);
      }
      
      public function getBoxes() : Vector.<Box>
      {
         var _loc5_:AdobeBootstrapBox = null;
         var _loc3_:AdobeFragmentRandomAccessBox = null;
         var _loc4_:MediaDataBox = null;
         var _loc1_:Vector.<Box> = new Vector.<Box>();
         var _loc2_:BoxInfo = getNextBoxInfo();
         while(_loc2_ != null)
         {
            if(_loc2_.type == "abst")
            {
               _loc5_ = new AdobeBootstrapBox();
               parseAdobeBootstrapBox(_loc2_,_loc5_);
               _loc1_.push(_loc5_);
            }
            else if(_loc2_.type == "afra")
            {
               _loc3_ = new AdobeFragmentRandomAccessBox();
               parseAdobeFragmentRandomAccessBox(_loc2_,_loc3_);
               _loc1_.push(_loc3_);
            }
            else if(_loc2_.type == "mdat")
            {
               _loc4_ = new MediaDataBox();
               parseMediaDataBox(_loc2_,_loc4_);
               _loc1_.push(_loc4_);
            }
            else
            {
               _ba.position = _ba.position + _loc2_.size - (4 + 4);
            }
            _loc2_ = getNextBoxInfo();
            if(_loc2_ != null && _loc2_.size <= 0)
            {
               break;
            }
         }
         return _loc1_;
      }
      
      public function readFragmentRandomAccessBox(param1:BoxInfo) : AdobeFragmentRandomAccessBox
      {
         var _loc2_:AdobeFragmentRandomAccessBox = new AdobeFragmentRandomAccessBox();
         parseAdobeFragmentRandomAccessBox(param1,_loc2_);
         return _loc2_;
      }
      
      public function readAdobeBootstrapBox(param1:BoxInfo) : AdobeBootstrapBox
      {
         var _loc2_:AdobeBootstrapBox = new AdobeBootstrapBox();
         this.parseAdobeBootstrapBox(param1,_loc2_);
         return _loc2_;
      }
      
      internal function readLongUIntToNumber() : Number
      {
         if(_ba == null || _ba.bytesAvailable < 8)
         {
            throw new IllegalOperationError("not enough length for readLongUIntToNumer");
         }
         var _loc1_:Number = _ba.readUnsignedInt();
         _loc1_ *= 4294967296;
         return _loc1_ + _ba.readUnsignedInt();
      }
      
      private function readUnsignedInt() : uint
      {
         if(_ba == null || _ba.bytesAvailable < 4)
         {
            throw new IllegalOperationError("not enough length for readUnsignedInt");
         }
         return _ba.readUnsignedInt();
      }
      
      private function readBytes(param1:ByteArray, param2:uint = 0, param3:uint = 0) : void
      {
         if(_ba == null || _ba.bytesAvailable < param3)
         {
            throw new IllegalOperationError("not enough length for readBytes: " + param3);
         }
         return _ba.readBytes(param1,param2,param3);
      }
      
      private function readUnsignedByte() : uint
      {
         if(_ba == null || _ba.bytesAvailable < 1)
         {
            throw new IllegalOperationError("not enough length for readUnsingedByte");
         }
         return _ba.readUnsignedByte();
      }
      
      private function readBytesToUint(param1:uint) : uint
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         if(_ba == null || _ba.bytesAvailable < param1)
         {
            throw new IllegalOperationError("not enough length for readUnsingedByte");
         }
         if(param1 > 4)
         {
            throw new IllegalOperationError("number of bytes to read must be equal or less than 4");
         }
         var _loc2_:uint = 0;
         _loc4_ = 0;
         while(_loc4_ < param1)
         {
            _loc2_ <<= 8;
            _loc3_ = _ba.readUnsignedByte();
            _loc2_ += _loc3_;
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function readString() : String
      {
         var _loc1_:* = 0;
         var _loc2_:uint = _ba.position;
         while(_ba.position < _ba.length)
         {
            _loc1_ = uint(_ba.readByte());
            if(_loc1_ == 0)
            {
               break;
            }
         }
         var _loc3_:uint = uint(_ba.position - _loc2_);
         _ba.position = _loc2_;
         return _ba.readUTFBytes(_loc3_);
      }
      
      private function parseBox(param1:BoxInfo, param2:Box) : void
      {
         var _loc5_:ByteArray = null;
         var _loc4_:Number = param1.size;
         var _loc3_:uint = 8;
         if(param1.size == 1)
         {
            _loc4_ = readLongUIntToNumber();
            _loc3_ += 8;
         }
         if(param1.type == "uuid")
         {
            _loc5_ = new ByteArray();
            readBytes(_loc5_,0,16);
            _loc3_ += 16;
         }
         param2.size = _loc4_;
         param2.type = param1.type;
         param2.boxLength = _loc3_;
      }
      
      private function parseFullBox(param1:BoxInfo, param2:FullBox) : void
      {
         parseBox(param1,param2);
         param2.version = readUnsignedByte();
         param2.flags = readBytesToUint(3);
      }
      
      private function parseAdobeBootstrapBox(param1:BoxInfo, param2:AdobeBootstrapBox) : void
      {
         var _loc5_:int = 0;
         var _loc14_:AdobeSegmentRunTable = null;
         var _loc6_:AdobeFragmentRunTable = null;
         parseFullBox(param1,param2);
         param2.bootstrapVersion = readUnsignedInt();
         var _loc3_:uint = readUnsignedByte();
         param2.profile = _loc3_ >> 6;
         param2.live = (_loc3_ & 0x20) == 32;
         param2.update = (_loc3_ & 1) == 1;
         param2.timeScale = readUnsignedInt();
         param2.currentMediaTime = readLongUIntToNumber();
         param2.smpteTimeCodeOffset = readLongUIntToNumber();
         param2.movieIdentifier = readString();
         var _loc8_:uint = readUnsignedByte();
         var _loc10_:Vector.<String> = new Vector.<String>();
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc10_.push(readString());
            _loc5_++;
         }
         param2.serverBaseURLs = _loc10_;
         var _loc12_:uint = readUnsignedByte();
         var _loc13_:Vector.<String> = new Vector.<String>();
         _loc5_ = 0;
         while(_loc5_ < _loc12_)
         {
            _loc13_.push(readString());
            _loc5_++;
         }
         param2.qualitySegmentURLModifiers = _loc13_;
         param2.drmData = readString();
         param2.metadata = readString();
         var _loc11_:uint = readUnsignedByte();
         var _loc4_:Vector.<AdobeSegmentRunTable> = new Vector.<AdobeSegmentRunTable>();
         _loc5_ = 0;
         while(_loc5_ < _loc11_)
         {
            param1 = getNextBoxInfo();
            if(param1.type != "asrt")
            {
               throw new IllegalOperationError("Unexpected data structure: " + param1.type);
            }
            _loc14_ = new AdobeSegmentRunTable();
            parseAdobeSegmentRunTable(param1,_loc14_);
            _loc4_.push(_loc14_);
            _loc5_++;
         }
         param2.segmentRunTables = _loc4_;
         var _loc9_:uint = readUnsignedByte();
         var _loc7_:Vector.<AdobeFragmentRunTable> = new Vector.<AdobeFragmentRunTable>();
         _loc5_ = 0;
         while(_loc5_ < _loc9_)
         {
            param1 = getNextBoxInfo();
            if(param1.type != "afrt")
            {
               throw new IllegalOperationError("Unexpected data structure: " + param1.type);
            }
            _loc6_ = new AdobeFragmentRunTable();
            parseAdobeFragmentRunTable(param1,_loc6_);
            _loc7_.push(_loc6_);
            _loc5_++;
         }
         param2.fragmentRunTables = _loc7_;
      }
      
      private function parseAdobeSegmentRunTable(param1:BoxInfo, param2:AdobeSegmentRunTable) : void
      {
         var _loc6_:* = 0;
         parseFullBox(param1,param2);
         var _loc3_:uint = readUnsignedByte();
         var _loc5_:Vector.<String> = new Vector.<String>();
         _loc6_ = 0;
         while(_loc6_ < _loc3_)
         {
            _loc5_.push(readString());
            _loc6_++;
         }
         param2.qualitySegmentURLModifiers = _loc5_;
         var _loc4_:uint = readUnsignedInt();
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            param2.addSegmentFragmentPair(new SegmentFragmentPair(readUnsignedInt(),readUnsignedInt()));
            _loc6_++;
         }
      }
      
      private function parseAdobeFragmentRunTable(param1:BoxInfo, param2:AdobeFragmentRunTable) : void
      {
         var _loc7_:* = 0;
         var _loc5_:FragmentDurationPair = null;
         parseFullBox(param1,param2);
         param2.timeScale = readUnsignedInt();
         var _loc3_:uint = readUnsignedByte();
         var _loc6_:Vector.<String> = new Vector.<String>();
         _loc7_ = 0;
         while(_loc7_ < _loc3_)
         {
            _loc6_.push(readString());
            _loc7_++;
         }
         param2.qualitySegmentURLModifiers = _loc6_;
         var _loc4_:uint = readUnsignedInt();
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            _loc5_ = new FragmentDurationPair();
            parseFragmentDurationPair(_loc5_);
            param2.addFragmentDurationPair(_loc5_);
            _loc7_++;
         }
      }
      
      private function parseFragmentDurationPair(param1:FragmentDurationPair) : void
      {
         param1.firstFragment = readUnsignedInt();
         param1.durationAccrued = readLongUIntToNumber();
         param1.duration = readUnsignedInt();
         if(param1.duration == 0)
         {
            param1.discontinuityIndicator = readUnsignedByte();
         }
      }
      
      private function parseAdobeFragmentRandomAccessBox(param1:BoxInfo, param2:AdobeFragmentRandomAccessBox) : void
      {
         var _loc8_:* = 0;
         var _loc7_:LocalRandomAccessEntry = null;
         var _loc12_:GlobalRandomAccessEntry = null;
         parseFullBox(param1,param2);
         var _loc5_:uint = readBytesToUint(1);
         var _loc3_:* = (_loc5_ & 0x80) > 0;
         var _loc11_:* = (_loc5_ & 0x40) > 0;
         var _loc6_:* = (_loc5_ & 0x20) > 0;
         param2.timeScale = readUnsignedInt();
         var _loc4_:uint = readUnsignedInt();
         var _loc10_:Vector.<LocalRandomAccessEntry> = new Vector.<LocalRandomAccessEntry>();
         _loc8_ = 0;
         while(_loc8_ < _loc4_)
         {
            _loc7_ = new LocalRandomAccessEntry();
            parseLocalRandomAccessEntry(_loc7_,_loc11_);
            _loc10_.push(_loc7_);
            _loc8_++;
         }
         param2.localRandomAccessEntries = _loc10_;
         var _loc9_:Vector.<GlobalRandomAccessEntry> = new Vector.<GlobalRandomAccessEntry>();
         if(_loc6_)
         {
            _loc4_ = readUnsignedInt();
            _loc8_ = 0;
            while(_loc8_ < _loc4_)
            {
               _loc12_ = new GlobalRandomAccessEntry();
               parseGlobalRandomAccessEntry(_loc12_,_loc3_,_loc11_);
               _loc9_.push(_loc12_);
               _loc8_++;
            }
         }
         param2.globalRandomAccessEntries = _loc9_;
      }
      
      private function parseLocalRandomAccessEntry(param1:LocalRandomAccessEntry, param2:Boolean) : void
      {
         param1.time = readLongUIntToNumber();
         if(param2)
         {
            param1.offset = readLongUIntToNumber();
         }
         else
         {
            param1.offset = readUnsignedInt();
         }
      }
      
      private function parseGlobalRandomAccessEntry(param1:GlobalRandomAccessEntry, param2:Boolean, param3:Boolean) : void
      {
         param1.time = readLongUIntToNumber();
         if(param2)
         {
            param1.segment = readUnsignedInt();
            param1.fragment = readUnsignedInt();
         }
         else
         {
            param1.segment = readBytesToUint(2);
            param1.fragment = readBytesToUint(2);
         }
         if(param3)
         {
            param1.afraOffset = readLongUIntToNumber();
            param1.offsetFromAfra = readLongUIntToNumber();
         }
         else
         {
            param1.afraOffset = readUnsignedInt();
            param1.offsetFromAfra = readUnsignedInt();
         }
      }
      
      private function parseMediaDataBox(param1:BoxInfo, param2:MediaDataBox) : void
      {
         parseBox(param1,param2);
         var _loc3_:ByteArray = new ByteArray();
         readBytes(_loc3_,0,param2.size - param2.boxLength);
         param2.data = _loc3_;
      }
   }
}

