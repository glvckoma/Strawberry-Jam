package org.osmf.net.httpstreaming.flv
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import flash.utils.IDataOutput;
   
   public class FLVHeader
   {
      public static const MIN_FILE_HEADER_BYTE_COUNT:int = 9;
      
      private var _hasVideoTags:Boolean = true;
      
      private var _hasAudioTags:Boolean = true;
      
      private var offset:uint;
      
      public function FLVHeader(param1:IDataInput = null)
      {
         super();
         if(param1 != null)
         {
            readHeader(param1);
            readRest(param1);
         }
      }
      
      public function get hasAudioTags() : Boolean
      {
         return _hasAudioTags;
      }
      
      public function set hasAudioTags(param1:Boolean) : void
      {
         _hasAudioTags = param1;
      }
      
      public function get hasVideoTags() : Boolean
      {
         return _hasVideoTags;
      }
      
      public function set hasVideoTags(param1:Boolean) : void
      {
         _hasVideoTags = param1;
      }
      
      public function write(param1:IDataOutput) : void
      {
         param1.writeByte(70);
         param1.writeByte(76);
         param1.writeByte(86);
         param1.writeByte(1);
         var _loc3_:uint = 0;
         if(_hasAudioTags)
         {
            _loc3_ |= 4;
         }
         if(_hasVideoTags)
         {
            _loc3_ |= 1;
         }
         param1.writeByte(_loc3_);
         param1.writeUnsignedInt(9);
         param1.writeUnsignedInt(0);
      }
      
      internal function readHeader(param1:IDataInput) : void
      {
         if(param1.bytesAvailable < 9)
         {
            throw new Error("FLVHeader() input too short");
         }
         if(param1.readByte() != 70)
         {
            throw new Error("FLVHeader readHeader() Signature[0] not \'F\'");
         }
         if(param1.readByte() != 76)
         {
            throw new Error("FLVHeader readHeader() Signature[1] not \'L\'");
         }
         if(param1.readByte() != 86)
         {
            throw new Error("FLVHeader readHeader() Signature[2] not \'V\'");
         }
         if(param1.readByte() != 1)
         {
            throw new Error("FLVHeader readHeader() Version not 0x01");
         }
         var _loc2_:int = int(param1.readByte());
         _hasAudioTags = !!(_loc2_ & 4) ? true : false;
         _hasVideoTags = !!(_loc2_ & 1) ? true : false;
         offset = param1.readUnsignedInt();
         if(offset < 9)
         {
            throw new Error("FLVHeader() offset smaller than minimum");
         }
      }
      
      internal function readRest(param1:IDataInput) : void
      {
         var _loc2_:ByteArray = null;
         if(offset > 9)
         {
            if(offset - 9 < param1.bytesAvailable - 4)
            {
               throw new Error("FLVHeader() input too short for nonstandard offset");
            }
            _loc2_ = new ByteArray();
            param1.readBytes(_loc2_,0,offset - 9);
         }
         if(param1.bytesAvailable < 4)
         {
            throw new Error("FLVHeader() input too short for previousTagSize0");
         }
         param1.readUnsignedInt();
      }
      
      internal function get restBytesNeeded() : int
      {
         return 4 + (offset - 9);
      }
   }
}

