package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class FLVTag
   {
      public static const TAG_TYPE_AUDIO:int = 8;
      
      public static const TAG_TYPE_VIDEO:int = 9;
      
      public static const TAG_TYPE_SCRIPTDATAOBJECT:int = 18;
      
      public static const TAG_FLAG_ENCRYPTED:int = 32;
      
      public static const TAG_TYPE_ENCRYPTED_AUDIO:int = 40;
      
      public static const TAG_TYPE_ENCRYPTED_VIDEO:int = 41;
      
      public static const TAG_TYPE_ENCRYPTED_SCRIPTDATAOBJECT:int = 50;
      
      internal static const TAG_HEADER_BYTE_COUNT:int = 11;
      
      internal static const PREV_TAG_BYTE_COUNT:int = 4;
      
      protected var bytes:ByteArray = null;
      
      public function FLVTag(param1:int)
      {
         super();
         bytes = new ByteArray();
         bytes.length = 11;
         bytes[0] = param1;
      }
      
      public function read(param1:IDataInput) : void
      {
         readType(param1);
         readRemainingHeader(param1);
         readData(param1);
         readPrevTag(param1);
      }
      
      public function readType(param1:IDataInput) : void
      {
         if(param1.bytesAvailable < 1)
         {
            throw new Error("FLVTag.readType() input too short");
         }
         param1.readBytes(bytes,0,1);
      }
      
      public function readRemaining(param1:IDataInput) : void
      {
         readRemainingHeader(param1);
         readData(param1);
         readPrevTag(param1);
      }
      
      public function readRemainingHeader(param1:IDataInput) : void
      {
         if(param1.bytesAvailable < 10)
         {
            throw new Error("FLVTag.readHeader() input too short");
         }
         param1.readBytes(bytes,1,11 - 1);
      }
      
      public function readData(param1:IDataInput) : void
      {
         if(dataSize > 0)
         {
            if(param1.bytesAvailable < dataSize)
            {
               throw new Error("FLVTag().readData input shorter than dataSize");
            }
            param1.readBytes(bytes,11,dataSize);
         }
      }
      
      public function readPrevTag(param1:IDataInput) : void
      {
         if(param1.bytesAvailable < 4)
         {
            throw new Error("FLVTag.readPrevTag() input too short");
         }
         param1.readUnsignedInt();
      }
      
      public function write(param1:IDataOutput) : void
      {
         param1.writeBytes(bytes,0,11 + dataSize);
         param1.writeUnsignedInt(11 + dataSize);
      }
      
      public function get tagType() : uint
      {
         return bytes[0];
      }
      
      public function set tagType(param1:uint) : void
      {
         bytes[0] = param1;
      }
      
      public function get isEncrpted() : Boolean
      {
         return !!(bytes[0] & 0x20) ? true : false;
      }
      
      public function get dataSize() : uint
      {
         return bytes[1] << 16 | bytes[2] << 8 | bytes[3];
      }
      
      public function set dataSize(param1:uint) : void
      {
         bytes[1] = param1 >> 16 & 0xFF;
         bytes[2] = param1 >> 8 & 0xFF;
         bytes[3] = param1 & 0xFF;
         bytes.length = 11 + param1;
      }
      
      public function get timestamp() : uint
      {
         return bytes[7] << 24 | bytes[4] << 16 | bytes[5] << 8 | bytes[6];
      }
      
      public function set timestamp(param1:uint) : void
      {
         bytes[7] = param1 >> 24 & 0xFF;
         bytes[4] = param1 >> 16 & 0xFF;
         bytes[5] = param1 >> 8 & 0xFF;
         bytes[6] = param1 & 0xFF;
      }
      
      public function get data() : ByteArray
      {
         var _loc1_:ByteArray = new ByteArray();
         _loc1_.writeBytes(bytes,11,dataSize);
         return _loc1_;
      }
      
      public function set data(param1:ByteArray) : void
      {
         bytes.length = 11 + param1.length;
         bytes.position = 11;
         bytes.writeBytes(param1,0,param1.length);
         dataSize = param1.length;
      }
   }
}

