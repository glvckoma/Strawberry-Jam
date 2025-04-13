package org.osmf.net.httpstreaming.f4f
{
   import flash.utils.ByteArray;
   import flash.utils.IDataInput;
   import org.osmf.events.HTTPStreamingFileHandlerEvent;
   import org.osmf.net.httpstreaming.HTTPStreamingFileHandlerBase;
   
   public class HTTPStreamingF4FFileHandler extends HTTPStreamingFileHandlerBase
   {
      private static const MAX_BYTES_PER_MDAT_READ:uint = 5120;
      
      private var _afra:AdobeFragmentRandomAccessBox;
      
      private var _ba:ByteArray;
      
      private var _boxInfoPending:Boolean;
      
      private var _bytesNeeded:uint;
      
      private var _bytesReadSinceAfraStart:uint;
      
      private var _countingReadBytes:Boolean;
      
      private var _mdatBytesPending:uint;
      
      private var _nextBox:BoxInfo;
      
      private var _parser:BoxParser = new BoxParser();
      
      private var _seekToTime:Number;
      
      private var _mdatBytesOffset:Number;
      
      private var _processRequestWasSeek:Boolean = false;
      
      public function HTTPStreamingF4FFileHandler()
      {
         super();
      }
      
      override public function beginProcessFile(param1:Boolean, param2:Number) : void
      {
         _processRequestWasSeek = param1;
         _seekToTime = param1 ? param2 : 0;
         _bytesNeeded = 4 + 4 + 8 + 16;
         _bytesReadSinceAfraStart = 0;
         _countingReadBytes = false;
         _boxInfoPending = true;
         _nextBox = null;
      }
      
      override public function get inputBytesNeeded() : Number
      {
         return _bytesNeeded;
      }
      
      override public function processFileSegment(param1:IDataInput) : ByteArray
      {
         var _loc3_:* = 0;
         var _loc5_:AdobeBootstrapBox = null;
         if(param1.bytesAvailable < _bytesNeeded)
         {
            return null;
         }
         var _loc2_:ByteArray = null;
         var _loc4_:Number = 8;
         if(_boxInfoPending)
         {
            _ba = new ByteArray();
            param1.readBytes(_ba,0,_loc4_);
            if(_countingReadBytes)
            {
               _bytesReadSinceAfraStart += _loc4_;
            }
            _parser.init(_ba);
            _nextBox = _parser.getNextBoxInfo();
            if(_nextBox.size == 1)
            {
               _loc4_ += 8;
               _ba.position = 0;
               param1.readBytes(_ba,0,8);
               if(_countingReadBytes)
               {
                  _bytesReadSinceAfraStart += 8;
               }
               _nextBox.size = _parser.readLongUIntToNumber();
            }
            _boxInfoPending = false;
            if(_nextBox.type == "mdat")
            {
               _bytesNeeded = 0;
               _mdatBytesPending = _nextBox.size - _loc4_;
            }
            else
            {
               _bytesNeeded = _nextBox.size - _loc4_;
               _mdatBytesPending = 0;
               if(_nextBox.type == "afra")
               {
                  _bytesReadSinceAfraStart = _loc4_;
                  _countingReadBytes = true;
               }
            }
         }
         else if(_bytesNeeded > 0)
         {
            _loc3_ = _ba.position;
            param1.readBytes(_ba,_ba.length,_nextBox.size - _loc4_);
            if(_countingReadBytes)
            {
               _bytesReadSinceAfraStart += _nextBox.size - _loc4_;
            }
            _ba.position = _loc3_;
            if(_nextBox.type == "abst")
            {
               _loc5_ = _parser.readAdobeBootstrapBox(_nextBox);
               if(_loc5_ != null)
               {
                  dispatchEvent(new HTTPStreamingFileHandlerEvent("notifyBootstrapBox",false,false,0,null,false,false,_loc5_));
               }
            }
            else if(_nextBox.type == "afra")
            {
               _afra = _parser.readFragmentRandomAccessBox(_nextBox);
               processSeekToTime();
            }
            else if(_nextBox.type == "moof")
            {
            }
            _bytesNeeded = 4 + 4 + 8 + 16;
            _boxInfoPending = true;
            _nextBox = null;
         }
         else
         {
            _loc2_ = getMDATBytes(param1,false);
         }
         return _loc2_;
      }
      
      override public function endProcessFile(param1:IDataInput) : ByteArray
      {
         if(this._bytesNeeded > 0)
         {
            dispatchEvent(new HTTPStreamingFileHandlerEvent("notifyError",false,false,0,null,false,false,null,true));
         }
         return getMDATBytes(param1,true);
      }
      
      override public function flushFileSegment(param1:IDataInput) : ByteArray
      {
         return null;
      }
      
      private function getMDATBytes(param1:IDataInput, param2:Boolean) : ByteArray
      {
         var _loc4_:ByteArray = null;
         var _loc3_:* = 0;
         if(param1 == null)
         {
            return null;
         }
         skipSeekBytes(param1);
         if(_mdatBytesPending > 0)
         {
            _loc3_ = _mdatBytesPending < param1.bytesAvailable ? _mdatBytesPending : uint(param1.bytesAvailable);
            if(!param2 && _loc3_ > 5120)
            {
               _loc3_ = 5120;
            }
            _loc4_ = new ByteArray();
            _mdatBytesPending -= _loc3_;
            param1.readBytes(_loc4_,0,_loc3_);
         }
         return _loc4_;
      }
      
      private function skipSeekBytes(param1:IDataInput) : void
      {
         var _loc2_:* = 0;
         var _loc3_:ByteArray = null;
         if(_bytesReadSinceAfraStart < _mdatBytesOffset)
         {
            _loc2_ = _mdatBytesOffset - _bytesReadSinceAfraStart;
            if(param1.bytesAvailable < _loc2_)
            {
               _loc2_ = uint(param1.bytesAvailable);
            }
            _loc3_ = new ByteArray();
            param1.readBytes(_loc3_,0,_loc2_);
            _bytesReadSinceAfraStart += _loc2_;
            _mdatBytesPending -= _loc2_;
         }
      }
      
      private function processSeekToTime() : void
      {
         var _loc2_:Number = 0;
         var _loc1_:LocalRandomAccessEntry = null;
         if(_seekToTime <= 0)
         {
            _mdatBytesOffset = 0;
         }
         else
         {
            _loc1_ = getMDATBytesOffset(_seekToTime);
            if(_loc1_ != null)
            {
               _mdatBytesOffset = _loc1_.offset;
               _loc2_ = _loc1_.time;
            }
            else
            {
               _mdatBytesOffset = 0;
            }
         }
      }
      
      private function getMDATBytesOffset(param1:Number) : LocalRandomAccessEntry
      {
         return !isNaN(param1) ? _afra.findNearestKeyFrameOffset(param1 * _afra.timeScale) : null;
      }
   }
}

