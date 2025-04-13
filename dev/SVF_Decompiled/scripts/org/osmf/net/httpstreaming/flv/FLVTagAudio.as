package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   
   public class FLVTagAudio extends FLVTag
   {
      public static const SOUND_FORMAT_LINEAR:int = 0;
      
      public static const SOUND_FORMAT_ADPCM:int = 1;
      
      public static const SOUND_FORMAT_MP3:int = 2;
      
      public static const SOUND_FORMAT_LINEAR_LE:int = 3;
      
      public static const SOUND_FORMAT_NELLYMOSER_16K:int = 4;
      
      public static const SOUND_FORMAT_NELLYMOSER_8K:int = 5;
      
      public static const SOUND_FORMAT_NELLYMOSER:int = 6;
      
      public static const SOUND_FORMAT_G711A:int = 7;
      
      public static const SOUND_FORMAT_G711U:int = 8;
      
      public static const SOUND_FORMAT_AAC:int = 10;
      
      public static const SOUND_FORMAT_SPEEX:int = 11;
      
      public static const SOUND_FORMAT_MP3_8K:int = 14;
      
      public static const SOUND_FORMAT_DEVICE_SPECIFIC:int = 15;
      
      public static const SOUND_RATE_5K:Number = 5512.5;
      
      public static const SOUND_RATE_11K:Number = 11025;
      
      public static const SOUND_RATE_22K:Number = 22050;
      
      public static const SOUND_RATE_44K:Number = 44100;
      
      public static const SOUND_SIZE_8BITS:int = 8;
      
      public static const SOUND_SIZE_16BITS:int = 16;
      
      public static const SOUND_CHANNELS_MONO:int = 1;
      
      public static const SOUND_CHANNELS_STEREO:int = 2;
      
      public function FLVTagAudio(param1:int = 8)
      {
         super(param1);
      }
      
      public function get soundFormatByte() : int
      {
         return bytes[11 + 0];
      }
      
      public function set soundFormatByte(param1:int) : void
      {
         bytes[11 + 0] = param1;
      }
      
      public function get soundFormat() : int
      {
         return bytes[11 + 0] >> 4 & 0x0F;
      }
      
      public function set soundFormat(param1:int) : void
      {
         var _loc2_:* = 11 + 0;
         var _loc3_:* = bytes[_loc2_] & 0x0F;
         bytes[_loc2_] = _loc3_;
         bytes[11 + 0] |= param1 << 4 & 0xF0;
         if(param1 == 10)
         {
            soundRate = 44100;
            soundChannels = 2;
            isAACSequenceHeader = false;
         }
      }
      
      public function get soundRate() : Number
      {
         switch(bytes[11 + 0] >> 2 & 3)
         {
            case 0:
               return 5512.5;
            case 1:
               return 11025;
            case 2:
               return 22050;
            case 3:
               return 44100;
            default:
               throw new Error("get soundRate() a two-bit number wasn\'t 0, 1, 2, or 3. impossible.");
         }
      }
      
      public function set soundRate(param1:Number) : void
      {
         var _loc2_:int = 0;
         switch(param1)
         {
            case 5512.5:
               _loc2_ = 0;
               break;
            case 11025:
               _loc2_ = 1;
               break;
            case 22050:
               _loc2_ = 2;
               break;
            case 44100:
               _loc2_ = 3;
               break;
            default:
               throw new Error("set soundRate valid values 5512.5, 11025, 22050, 44100");
         }
         var _loc3_:* = 11 + 0;
         var _loc4_:* = bytes[_loc3_] & 0xF3;
         bytes[_loc3_] = _loc4_;
         bytes[11 + 0] |= _loc2_ << 2;
      }
      
      public function get soundSize() : int
      {
         if(bytes[11 + 0] >> 1 & 1)
         {
            return 16;
         }
         return 8;
      }
      
      public function set soundSize(param1:int) : void
      {
         switch(param1 - 8)
         {
            case 0:
               var _loc2_:* = 11 + 0;
               var _loc3_:* = bytes[_loc2_] & 0xFD;
               bytes[_loc2_] = _loc3_;
               break;
            case 8:
               _loc3_ = 11 + 0;
               _loc2_ = bytes[_loc3_] | 2;
               bytes[_loc3_] = _loc2_;
               break;
            default:
               throw new Error("set soundSize valid values 8, 16");
         }
      }
      
      public function get soundChannels() : int
      {
         if(bytes[11 + 0] & 1)
         {
            return 2;
         }
         return 1;
      }
      
      public function set soundChannels(param1:int) : void
      {
         switch(param1 - 1)
         {
            case 0:
               var _loc2_:* = 11 + 0;
               var _loc3_:* = bytes[_loc2_] & 0xFE;
               bytes[_loc2_] = _loc3_;
               break;
            case 1:
               _loc3_ = 11 + 0;
               _loc2_ = bytes[_loc3_] | 1;
               bytes[_loc3_] = _loc2_;
               break;
            default:
               throw new Error("set soundChannels valid values 1, 2");
         }
      }
      
      public function get isAACSequenceHeader() : Boolean
      {
         if(soundFormat != 10)
         {
            throw new Error("get isAACSequenceHeader not valid if soundFormat != SOUND_FORMAT_AAC");
         }
         if(bytes[11 + 1] == 0)
         {
            return true;
         }
         return false;
      }
      
      public function set isAACSequenceHeader(param1:Boolean) : void
      {
         if(soundFormat != 10)
         {
            throw new Error("set isAACSequenceHeader not valid if soundFormat != SOUND_FORMAT_AAC");
         }
         if(param1)
         {
            bytes[11 + 1] = 0;
         }
         else
         {
            bytes[11 + 1] = 1;
         }
      }
      
      public function get isCodecConfiguration() : Boolean
      {
         switch(soundFormat - 10)
         {
            case 0:
               if(isAACSequenceHeader)
               {
                  return true;
               }
               break;
         }
         return false;
      }
      
      override public function get data() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         if(soundFormat == 10)
         {
            _loc1_.writeBytes(bytes,11 + 2,dataSize - 2);
         }
         else
         {
            _loc1_.writeBytes(bytes,11 + 1,dataSize - 1);
         }
         return _loc1_;
      }
      
      override public function set data(param1:ByteArray) : void
      {
         if(soundFormat == 10)
         {
            bytes.length = 11 + param1.length + 2;
            bytes.position = 11 + 2;
            bytes.writeBytes(param1,0,param1.length);
            dataSize = param1.length + 2;
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

