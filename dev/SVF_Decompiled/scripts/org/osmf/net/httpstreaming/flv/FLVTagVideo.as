package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   
   public class FLVTagVideo extends FLVTag
   {
      public static const FRAME_TYPE_KEYFRAME:int = 1;
      
      public static const FRAME_TYPE_INTER:int = 2;
      
      public static const FRAME_TYPE_DISPOSABLE_INTER:int = 3;
      
      public static const FRAME_TYPE_GENERATED_KEYFRAME:int = 4;
      
      public static const FRAME_TYPE_INFO:int = 5;
      
      public static const CODEC_ID_JPEG:int = 1;
      
      public static const CODEC_ID_SORENSON:int = 2;
      
      public static const CODEC_ID_SCREEN:int = 3;
      
      public static const CODEC_ID_VP6:int = 4;
      
      public static const CODEC_ID_VP6_ALPHA:int = 5;
      
      public static const CODEC_ID_SCREEN_V2:int = 6;
      
      public static const CODEC_ID_AVC:int = 7;
      
      public static const AVC_PACKET_TYPE_SEQUENCE_HEADER:int = 0;
      
      public static const AVC_PACKET_TYPE_NALU:int = 1;
      
      public static const AVC_PACKET_TYPE_END_OF_SEQUENCE:int = 2;
      
      public static const INFO_PACKET_SEEK_START:int = 0;
      
      public static const INFO_PACKET_SEEK_END:int = 1;
      
      public function FLVTagVideo(param1:int = 9)
      {
         super(param1);
      }
      
      public function get frameType() : int
      {
         return bytes[11 + 0] >> 4 & 0x0F;
      }
      
      public function set frameType(param1:int) : void
      {
         var _loc2_:* = 11 + 0;
         var _loc3_:* = bytes[_loc2_] & 0x0F;
         bytes[_loc2_] = _loc3_;
         bytes[11 + 0] |= (param1 & 0x0F) << 4;
      }
      
      public function get codecID() : int
      {
         return bytes[11 + 0] & 0x0F;
      }
      
      public function set codecID(param1:int) : void
      {
         var _loc2_:* = 11 + 0;
         var _loc3_:* = bytes[_loc2_] & 0xF0;
         bytes[_loc2_] = _loc3_;
         bytes[11 + 0] |= param1 & 0x0F;
      }
      
      public function get infoPacketValue() : int
      {
         if(frameType != 5)
         {
            throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
         }
         return bytes[11 + 1];
      }
      
      public function set infoPacketValue(param1:int) : void
      {
         if(frameType != 5)
         {
            throw new Error("get infoPacketValue() not permitted unless frameType is FRAME_TYPE_INFO");
         }
         bytes[11 + 1] = param1;
         bytes.length = 11 + 2;
         dataSize = 2;
      }
      
      public function get avcPacketType() : int
      {
         if(codecID != 7)
         {
            throw new Error("get avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
         }
         return bytes[11 + 1];
      }
      
      public function set avcPacketType(param1:int) : void
      {
         if(codecID != 7)
         {
            throw new Error("set avcPacketType() not permitted unless codecID is CODEC_ID_AVC");
         }
         bytes[11 + 1] = param1;
         if(avcPacketType != 1)
         {
            bytes[11 + 2] = 0;
            bytes[11 + 3] = 0;
            bytes[11 + 4] = 0;
            bytes.length = 11 + 5;
            dataSize = 5;
         }
      }
      
      public function get avcCompositionTimeOffset() : int
      {
         if(codecID != 7 || avcPacketType != 1)
         {
            throw new Error("get avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
         }
         var _loc1_:* = bytes[11 + 2] << 16;
         _loc1_ |= bytes[11 + 3] << 8;
         _loc1_ |= bytes[11 + 4];
         if(_loc1_ & 0x800000)
         {
            _loc1_ |= 4278190080;
         }
         return _loc1_;
      }
      
      public function set avcCompositionTimeOffset(param1:int) : void
      {
         if(codecID != 7 || avcPacketType != 1)
         {
            throw new Error("set avcCompositionTimeOffset() not permitted unless codecID is CODEC_ID_AVC and avcPacketType is AVC NALU");
         }
         bytes[11 + 2] = param1 >> 16 & 0xFF;
         bytes[11 + 3] = param1 >> 8 & 0xFF;
         bytes[11 + 4] = param1 & 0xFF;
      }
      
      override public function get data() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         if(codecID == 7)
         {
            _loc1_.writeBytes(bytes,11 + 5,dataSize - 5);
         }
         else
         {
            _loc1_.writeBytes(bytes,11 + 1,dataSize - 1);
         }
         return _loc1_;
      }
      
      override public function set data(param1:ByteArray) : void
      {
         if(codecID == 7)
         {
            bytes.length = 11 + param1.length + 5;
            bytes.position = 11 + 5;
            bytes.writeBytes(param1,0,param1.length);
            dataSize = param1.length + 5;
         }
         else
         {
            bytes.length = 11 + param1.length + 1;
            bytes.position = 11 + 1;
            bytes.writeBytes(param1,0,param1.length);
            dataSize = param1.length + 1;
         }
      }
   }
}

