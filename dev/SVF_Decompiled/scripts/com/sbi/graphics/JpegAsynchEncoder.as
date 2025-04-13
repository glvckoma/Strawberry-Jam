package com.sbi.graphics
{
   import flash.display.BitmapData;
   import flash.events.EventDispatcher;
   import flash.events.ProgressEvent;
   import flash.utils.ByteArray;
   import flash.utils.setTimeout;
   
   public class JpegAsynchEncoder extends EventDispatcher
   {
      public static const CONTENT_TYPE:String = "image/jpeg";
      
      private var ZigZag:Array = [0,1,5,6,14,15,27,28,2,4,7,13,16,26,29,42,3,8,12,17,25,30,41,43,9,11,18,24,31,40,44,53,10,19,23,32,39,45,52,54,20,22,33,38,46,51,55,60,21,34,37,47,50,56,59,61,35,36,48,49,57,58,62,63];
      
      private var std_dc_luminance_nrcodes:Array = [0,0,1,5,1,1,1,1,1,1,0,0,0,0,0,0,0];
      
      private var std_dc_luminance_values:Array = [0,1,2,3,4,5,6,7,8,9,10,11];
      
      private var std_ac_luminance_nrcodes:Array = [0,0,2,1,3,3,2,4,3,5,5,4,4,0,0,1,125];
      
      private var std_ac_luminance_values:Array = [1,2,3,0,4,17,5,18,33,49,65,6,19,81,97,7,34,113,20,50,129,145,161,8,35,66,177,193,21,82,209,240,36,51,98,114,130,9,10,22,23,24,25,26,37,38,39,40,41,42,52,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,118,119,120,121,122,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,225,226,227,228,229,230,231,232,233,234,241,242,243,244,245,246,247,248,249,250];
      
      private var std_dc_chrominance_nrcodes:Array = [0,0,3,1,1,1,1,1,1,1,1,1,0,0,0,0,0];
      
      private var std_dc_chrominance_values:Array = [0,1,2,3,4,5,6,7,8,9,10,11];
      
      private var std_ac_chrominance_nrcodes:Array = [0,0,2,1,2,4,4,3,4,7,5,4,4,0,1,2,119];
      
      private var std_ac_chrominance_values:Array = [0,1,2,3,17,4,5,33,49,6,18,65,81,7,97,113,19,34,50,129,8,20,66,145,161,177,193,9,35,51,82,240,21,98,114,209,10,22,36,52,225,37,241,23,24,25,26,38,39,40,41,42,53,54,55,56,57,58,67,68,69,70,71,72,73,74,83,84,85,86,87,88,89,90,99,100,101,102,103,104,105,106,115,116,117,118,119,120,121,122,130,131,132,133,134,135,136,137,138,146,147,148,149,150,151,152,153,154,162,163,164,165,166,167,168,169,170,178,179,180,181,182,183,184,185,186,194,195,196,197,198,199,200,201,202,210,211,212,213,214,215,216,217,218,226,227,228,229,230,231,232,233,234,242,243,244,245,246,247,248,249,250];
      
      private var YTable:Array = new Array(64);
      
      private var UVTable:Array = new Array(64);
      
      private var fdtbl_Y:Array = new Array(64);
      
      private var fdtbl_UV:Array = new Array(64);
      
      private var YDC_HT:Array;
      
      private var UVDC_HT:Array;
      
      private var YAC_HT:Array;
      
      private var UVAC_HT:Array;
      
      private var YDU:Array = new Array(64);
      
      private var UDU:Array = new Array(64);
      
      private var VDU:Array = new Array(64);
      
      private var DU:Array = new Array(64);
      
      private var bitcode:Array = new Array(65535);
      
      private var category:Array = new Array(65535);
      
      private var byteout:ByteArray;
      
      private var bytenew:int = 0;
      
      private var bytepos:int = 7;
      
      private var DCY:Number = 0;
      
      private var DCU:Number = 0;
      
      private var DCV:Number = 0;
      
      private var SrcWidth:int = 0;
      
      private var SrcHeight:int = 0;
      
      private var Source:Object = null;
      
      private var TotalSize:int = 0;
      
      private var PixelsPerIter:int = 128;
      
      private var PercentageInc:int = 0;
      
      private var NextProgressAt:int = 0;
      
      private var CurrentTotalPos:int = 0;
      
      private var Working:Boolean = false;
      
      public function JpegAsynchEncoder()
      {
         super();
      }
      
      public function JPEGAsyncEncoder(param1:Number = 50) : void
      {
         if(param1 <= 0)
         {
            param1 = 1;
         }
         if(param1 > 100)
         {
            param1 = 100;
         }
         var _loc2_:int = 0;
         if(param1 < 50)
         {
            _loc2_ = 5000 / param1;
         }
         else
         {
            _loc2_ = 200 - param1 * 2;
         }
         initHuffmanTbl();
         initCategoryNumber();
         initQuantTables(_loc2_);
      }
      
      public function get contentType() : String
      {
         return "image/jpeg";
      }
      
      public function get PixelsPerIteration() : int
      {
         return PixelsPerIter;
      }
      
      public function set PixelsPerIteration(param1:int) : void
      {
         PixelsPerIter = param1;
      }
      
      public function get ImageData() : ByteArray
      {
         return byteout;
      }
      
      public function encodeByteArray(param1:ByteArray, param2:int, param3:int) : Boolean
      {
         return internalEncode(param1,param2,param3);
      }
      
      public function encode(param1:BitmapData) : Boolean
      {
         return internalEncode(param1,param1.width,param1.height);
      }
      
      private function internalEncode(param1:Object, param2:int, param3:int) : Boolean
      {
         if(Working)
         {
            return false;
         }
         Working = true;
         Source = param1;
         SrcWidth = param2;
         SrcHeight = param3;
         TotalSize = param2 * param3;
         PercentageInc = TotalSize / 100;
         NextProgressAt = PercentageInc;
         CurrentTotalPos = 0;
         setTimeout(StartEncode,10);
         return true;
      }
      
      private function StartEncode() : void
      {
         byteout = new ByteArray();
         bytenew = 0;
         bytepos = 7;
         writeWord(65496);
         writeAPP0();
         writeDQT();
         writeSOF0(SrcWidth,SrcHeight);
         writeDHT();
         writeSOS();
         DCY = 0;
         DCV = 0;
         DCU = 0;
         bytenew = 0;
         bytepos = 7;
         this.dispatchEvent(new ProgressEvent("progress",false,false,0,TotalSize));
         setTimeout(AsyncLoop,10,0,0);
      }
      
      private function AsyncLoop(param1:int, param2:int) : void
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < PixelsPerIter)
         {
            RGB2YUV(Source,param1,param2,SrcWidth,SrcHeight);
            DCY = processDU(YDU,fdtbl_Y,DCY,YDC_HT,YAC_HT);
            DCU = processDU(UDU,fdtbl_UV,DCU,UVDC_HT,UVAC_HT);
            DCV = processDU(VDU,fdtbl_UV,DCV,UVDC_HT,UVAC_HT);
            param1 += 8;
            if(param1 >= SrcWidth)
            {
               param1 = 0;
               param2 += 8;
            }
            if(param2 >= SrcHeight)
            {
               setTimeout(FinishEncode,10);
               return;
            }
            CurrentTotalPos += 64;
            if(CurrentTotalPos >= NextProgressAt)
            {
               this.dispatchEvent(new ProgressEvent("progress",false,false,CurrentTotalPos,TotalSize));
               NextProgressAt += PercentageInc;
            }
            _loc3_++;
         }
         setTimeout(AsyncLoop,10,param1,param2);
      }
      
      private function FinishEncode() : void
      {
         var _loc1_:BitString = null;
         if(bytepos >= 0)
         {
            _loc1_ = new BitString();
            _loc1_.len = bytepos + 1;
            _loc1_.val = (1 << bytepos + 1) - 1;
            writeBits(_loc1_);
         }
         writeWord(65497);
         this.dispatchEvent(new ProgressEvent("progress",false,false,TotalSize,TotalSize));
         this.dispatchEvent(new JPEGAsyncCompleteEvent(byteout));
         Working = false;
      }
      
      private function initQuantTables(param1:int) : void
      {
         var _loc4_:Number = NaN;
         var _loc6_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Array = [16,11,10,16,24,40,51,61,12,12,14,19,26,58,60,55,14,13,16,24,40,57,69,56,14,17,22,29,51,87,80,62,18,22,37,56,68,109,103,77,24,35,55,64,81,104,113,92,49,64,78,87,103,121,120,101,72,92,95,98,112,100,103,99];
         _loc5_ = 0;
         while(_loc5_ < 64)
         {
            _loc4_ = Math.floor((_loc7_[_loc5_] * param1 + 50) / 100);
            if(_loc4_ < 1)
            {
               _loc4_ = 1;
            }
            else if(_loc4_ > 255)
            {
               _loc4_ = 255;
            }
            YTable[ZigZag[_loc5_]] = _loc4_;
            _loc5_++;
         }
         var _loc3_:Array = [17,18,24,47,99,99,99,99,18,21,26,66,99,99,99,99,24,26,56,99,99,99,99,99,47,66,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99,99];
         _loc5_ = 0;
         while(_loc5_ < 64)
         {
            _loc4_ = Math.floor((_loc3_[_loc5_] * param1 + 50) / 100);
            if(_loc4_ < 1)
            {
               _loc4_ = 1;
            }
            else if(_loc4_ > 255)
            {
               _loc4_ = 255;
            }
            UVTable[ZigZag[_loc5_]] = _loc4_;
            _loc5_++;
         }
         var _loc8_:Array = [1,1.387039845,1.306562965,1.175875602,1,0.785694958,0.5411961,0.275899379];
         _loc5_ = 0;
         _loc6_ = 0;
         while(_loc6_ < 8)
         {
            _loc2_ = 0;
            while(_loc2_ < 8)
            {
               fdtbl_Y[_loc5_] = 1 / (YTable[ZigZag[_loc5_]] * _loc8_[_loc6_] * _loc8_[_loc2_] * 8);
               fdtbl_UV[_loc5_] = 1 / (UVTable[ZigZag[_loc5_]] * _loc8_[_loc6_] * _loc8_[_loc2_] * 8);
               _loc5_++;
               _loc2_++;
            }
            _loc6_++;
         }
      }
      
      private function computeHuffmanTbl(param1:Array, param2:Array) : Array
      {
         var _loc6_:int = 0;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:Array = [];
         _loc6_ = 1;
         while(_loc6_ <= 16)
         {
            _loc5_ = 1;
            while(_loc5_ <= param1[_loc6_])
            {
               _loc7_[param2[_loc3_]] = new BitString();
               _loc7_[param2[_loc3_]].val = _loc4_;
               _loc7_[param2[_loc3_]].len = _loc6_;
               _loc3_++;
               _loc4_++;
               _loc5_++;
            }
            _loc4_ *= 2;
            _loc6_++;
         }
         return _loc7_;
      }
      
      private function initHuffmanTbl() : void
      {
         YDC_HT = computeHuffmanTbl(std_dc_luminance_nrcodes,std_dc_luminance_values);
         UVDC_HT = computeHuffmanTbl(std_dc_chrominance_nrcodes,std_dc_chrominance_values);
         YAC_HT = computeHuffmanTbl(std_ac_luminance_nrcodes,std_ac_luminance_values);
         UVAC_HT = computeHuffmanTbl(std_ac_chrominance_nrcodes,std_ac_chrominance_values);
      }
      
      private function initCategoryNumber() : void
      {
         var _loc2_:* = 0;
         var _loc4_:int = 0;
         var _loc1_:* = 1;
         var _loc3_:* = 2;
         _loc4_ = 1;
         while(_loc4_ <= 15)
         {
            _loc2_ = _loc1_;
            while(_loc2_ < _loc3_)
            {
               category[32767 + _loc2_] = _loc4_;
               bitcode[32767 + _loc2_] = new BitString();
               bitcode[32767 + _loc2_].len = _loc4_;
               bitcode[32767 + _loc2_].val = _loc2_;
               _loc2_++;
            }
            _loc2_ = -(_loc3_ - 1);
            while(_loc2_ <= -_loc1_)
            {
               category[32767 + _loc2_] = _loc4_;
               bitcode[32767 + _loc2_] = new BitString();
               bitcode[32767 + _loc2_].len = _loc4_;
               bitcode[32767 + _loc2_].val = _loc3_ - 1 + _loc2_;
               _loc2_++;
            }
            _loc1_ <<= 1;
            _loc3_ <<= 1;
            _loc4_++;
         }
      }
      
      private function writeBits(param1:BitString) : void
      {
         var _loc3_:int = param1.val;
         var _loc2_:int = param1.len - 1;
         while(_loc2_ >= 0)
         {
            if(_loc3_ & uint(1 << _loc2_))
            {
               bytenew |= uint(1 << bytepos);
            }
            _loc2_--;
            bytepos--;
            if(bytepos < 0)
            {
               if(bytenew == 255)
               {
                  writeByte(255);
                  writeByte(0);
               }
               else
               {
                  writeByte(bytenew);
               }
               bytepos = 7;
               bytenew = 0;
            }
         }
      }
      
      private function writeByte(param1:int) : void
      {
         byteout.writeByte(param1);
      }
      
      private function writeWord(param1:int) : void
      {
         writeByte(param1 >> 8 & 0xFF);
         writeByte(param1 & 0xFF);
      }
      
      private function fDCTQuant(param1:Array, param2:Array) : Array
      {
         var _loc7_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc3_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < 8)
         {
            _loc15_ = param1[_loc3_ + 0] + param1[_loc3_ + 7];
            _loc16_ = param1[_loc3_ + 0] - param1[_loc3_ + 7];
            _loc11_ = param1[_loc3_ + 1] + param1[_loc3_ + 6];
            _loc8_ = param1[_loc3_ + 1] - param1[_loc3_ + 6];
            _loc13_ = param1[_loc3_ + 2] + param1[_loc3_ + 5];
            _loc6_ = param1[_loc3_ + 2] - param1[_loc3_ + 5];
            _loc9_ = param1[_loc3_ + 3] + param1[_loc3_ + 4];
            _loc10_ = param1[_loc3_ + 3] - param1[_loc3_ + 4];
            _loc5_ = _loc15_ + _loc9_;
            _loc12_ = _loc15_ - _loc9_;
            _loc4_ = _loc11_ + _loc13_;
            _loc14_ = _loc11_ - _loc13_;
            param1[_loc3_ + 0] = _loc5_ + _loc4_;
            param1[_loc3_ + 4] = _loc5_ - _loc4_;
            _loc17_ = (_loc14_ + _loc12_) * 0.707106781;
            param1[_loc3_ + 2] = _loc12_ + _loc17_;
            param1[_loc3_ + 6] = _loc12_ - _loc17_;
            _loc5_ = _loc10_ + _loc6_;
            _loc4_ = _loc6_ + _loc8_;
            _loc14_ = _loc8_ + _loc16_;
            _loc21_ = (_loc5_ - _loc14_) * 0.382683433;
            _loc18_ = 0.5411961 * _loc5_ + _loc21_;
            _loc20_ = 1.306562965 * _loc14_ + _loc21_;
            _loc19_ = _loc4_ * 0.707106781;
            _loc22_ = _loc16_ + _loc19_;
            _loc23_ = _loc16_ - _loc19_;
            param1[_loc3_ + 5] = _loc23_ + _loc18_;
            param1[_loc3_ + 3] = _loc23_ - _loc18_;
            param1[_loc3_ + 1] = _loc22_ + _loc20_;
            param1[_loc3_ + 7] = _loc22_ - _loc20_;
            _loc3_ += 8;
            _loc7_++;
         }
         _loc3_ = 0;
         _loc7_ = 0;
         while(_loc7_ < 8)
         {
            _loc15_ = param1[_loc3_ + 0] + param1[_loc3_ + 56];
            _loc16_ = param1[_loc3_ + 0] - param1[_loc3_ + 56];
            _loc11_ = param1[_loc3_ + 8] + param1[_loc3_ + 48];
            _loc8_ = param1[_loc3_ + 8] - param1[_loc3_ + 48];
            _loc13_ = param1[_loc3_ + 16] + param1[_loc3_ + 40];
            _loc6_ = param1[_loc3_ + 16] - param1[_loc3_ + 40];
            _loc9_ = param1[_loc3_ + 24] + param1[_loc3_ + 32];
            _loc10_ = param1[_loc3_ + 24] - param1[_loc3_ + 32];
            _loc5_ = _loc15_ + _loc9_;
            _loc12_ = _loc15_ - _loc9_;
            _loc4_ = _loc11_ + _loc13_;
            _loc14_ = _loc11_ - _loc13_;
            param1[_loc3_ + 0] = _loc5_ + _loc4_;
            param1[_loc3_ + 32] = _loc5_ - _loc4_;
            _loc17_ = (_loc14_ + _loc12_) * 0.707106781;
            param1[_loc3_ + 16] = _loc12_ + _loc17_;
            param1[_loc3_ + 48] = _loc12_ - _loc17_;
            _loc5_ = _loc10_ + _loc6_;
            _loc4_ = _loc6_ + _loc8_;
            _loc14_ = _loc8_ + _loc16_;
            _loc21_ = (_loc5_ - _loc14_) * 0.382683433;
            _loc18_ = 0.5411961 * _loc5_ + _loc21_;
            _loc20_ = 1.306562965 * _loc14_ + _loc21_;
            _loc19_ = _loc4_ * 0.707106781;
            _loc22_ = _loc16_ + _loc19_;
            _loc23_ = _loc16_ - _loc19_;
            param1[_loc3_ + 40] = _loc23_ + _loc18_;
            param1[_loc3_ + 24] = _loc23_ - _loc18_;
            param1[_loc3_ + 8] = _loc22_ + _loc20_;
            param1[_loc3_ + 56] = _loc22_ - _loc20_;
            _loc3_++;
            _loc7_++;
         }
         _loc7_ = 0;
         while(_loc7_ < 64)
         {
            param1[_loc7_] = Math.round(param1[_loc7_] * param2[_loc7_]);
            _loc7_++;
         }
         return param1;
      }
      
      private function writeAPP0() : void
      {
         writeWord(65504);
         writeWord(16);
         writeByte(74);
         writeByte(70);
         writeByte(73);
         writeByte(70);
         writeByte(0);
         writeByte(1);
         writeByte(1);
         writeByte(0);
         writeWord(1);
         writeWord(1);
         writeByte(0);
         writeByte(0);
      }
      
      private function writeSOF0(param1:int, param2:int) : void
      {
         writeWord(65472);
         writeWord(17);
         writeByte(8);
         writeWord(param2);
         writeWord(param1);
         writeByte(3);
         writeByte(1);
         writeByte(17);
         writeByte(0);
         writeByte(2);
         writeByte(17);
         writeByte(1);
         writeByte(3);
         writeByte(17);
         writeByte(1);
      }
      
      private function writeDQT() : void
      {
         var _loc1_:int = 0;
         writeWord(65499);
         writeWord(132);
         writeByte(0);
         _loc1_ = 0;
         while(_loc1_ < 64)
         {
            writeByte(YTable[_loc1_]);
            _loc1_++;
         }
         writeByte(1);
         _loc1_ = 0;
         while(_loc1_ < 64)
         {
            writeByte(UVTable[_loc1_]);
            _loc1_++;
         }
      }
      
      private function writeDHT() : void
      {
         var _loc1_:int = 0;
         writeWord(65476);
         writeWord(418);
         writeByte(0);
         _loc1_ = 0;
         while(_loc1_ < 16)
         {
            writeByte(std_dc_luminance_nrcodes[_loc1_ + 1]);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 11)
         {
            writeByte(std_dc_luminance_values[_loc1_]);
            _loc1_++;
         }
         writeByte(16);
         _loc1_ = 0;
         while(_loc1_ < 16)
         {
            writeByte(std_ac_luminance_nrcodes[_loc1_ + 1]);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 161)
         {
            writeByte(std_ac_luminance_values[_loc1_]);
            _loc1_++;
         }
         writeByte(1);
         _loc1_ = 0;
         while(_loc1_ < 16)
         {
            writeByte(std_dc_chrominance_nrcodes[_loc1_ + 1]);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 11)
         {
            writeByte(std_dc_chrominance_values[_loc1_]);
            _loc1_++;
         }
         writeByte(17);
         _loc1_ = 0;
         while(_loc1_ < 16)
         {
            writeByte(std_ac_chrominance_nrcodes[_loc1_ + 1]);
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ <= 161)
         {
            writeByte(std_ac_chrominance_values[_loc1_]);
            _loc1_++;
         }
      }
      
      private function writeSOS() : void
      {
         writeWord(65498);
         writeWord(12);
         writeByte(3);
         writeByte(1);
         writeByte(0);
         writeByte(2);
         writeByte(17);
         writeByte(3);
         writeByte(17);
         writeByte(0);
         writeByte(63);
         writeByte(0);
      }
      
      private function processDU(param1:Array, param2:Array, param3:Number, param4:Array, param5:Array) : Number
      {
         var _loc9_:int = 0;
         var _loc11_:* = 0;
         var _loc6_:* = 0;
         var _loc10_:int = 0;
         var _loc12_:BitString = param5[0];
         var _loc13_:BitString = param5[240];
         var _loc7_:Array = fDCTQuant(param1,param2);
         _loc9_ = 0;
         while(_loc9_ < 64)
         {
            DU[ZigZag[_loc9_]] = _loc7_[_loc9_];
            _loc9_++;
         }
         var _loc8_:int = DU[0] - param3;
         param3 = Number(DU[0]);
         if(_loc8_ == 0)
         {
            writeBits(param4[0]);
         }
         else
         {
            writeBits(param4[category[32767 + _loc8_]]);
            writeBits(bitcode[32767 + _loc8_]);
         }
         var _loc14_:int = 63;
         while(_loc14_ > 0 && DU[_loc14_] == 0)
         {
            _loc14_--;
         }
         if(_loc14_ == 0)
         {
            writeBits(_loc12_);
            return param3;
         }
         _loc9_ = 1;
         while(_loc9_ <= _loc14_)
         {
            _loc11_ = _loc9_;
            while(DU[_loc9_] == 0 && _loc9_ <= _loc14_)
            {
               _loc9_++;
            }
            _loc6_ = _loc9_ - _loc11_;
            if(_loc6_ >= 16)
            {
               _loc10_ = 1;
               while(_loc10_ <= _loc6_ / 16)
               {
                  writeBits(_loc13_);
                  _loc10_++;
               }
               _loc6_ &= 15;
            }
            writeBits(param5[_loc6_ * 16 + category[32767 + DU[_loc9_]]]);
            writeBits(bitcode[32767 + DU[_loc9_]]);
            _loc9_++;
         }
         if(_loc14_ != 63)
         {
            writeBits(_loc12_);
         }
         return param3;
      }
      
      private function RGB2YUV(param1:Object, param2:int, param3:int, param4:int = 0, param5:int = 0) : void
      {
         var _loc12_:int = 0;
         var _loc11_:int = 0;
         var _loc6_:* = 0;
         var _loc7_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:int = 0;
         _loc12_ = 0;
         while(_loc12_ < 8)
         {
            _loc11_ = 0;
            while(_loc11_ < 8)
            {
               _loc6_ = getPixel32(param1,param2 + _loc11_,param3 + _loc12_,param4,param5);
               _loc7_ = _loc6_ >> 16 & 0xFF;
               _loc10_ = _loc6_ >> 8 & 0xFF;
               _loc8_ = _loc6_ & 0xFF;
               YDU[_loc9_] = 0.299 * _loc7_ + 0.587 * _loc10_ + 0.114 * _loc8_ - 128;
               UDU[_loc9_] = -0.16874 * _loc7_ + -0.33126 * _loc10_ + 0.5 * _loc8_;
               VDU[_loc9_] = 0.5 * _loc7_ + -0.41869 * _loc10_ + -0.08131 * _loc8_;
               _loc9_++;
               _loc11_++;
            }
            _loc12_++;
         }
      }
      
      private function getPixel32(param1:Object, param2:int, param3:int, param4:int = 0, param5:int = 0) : uint
      {
         var _loc6_:BitmapData = null;
         var _loc7_:ByteArray = null;
         if(param1 is BitmapData)
         {
            _loc6_ = param1 as BitmapData;
            return _loc6_.getPixel32(param2,param3);
         }
         if(param1 is ByteArray)
         {
            _loc7_ = param1 as ByteArray;
            _loc7_.position = param3 * param4 * 4 + param2 * 4;
            return _loc7_.readUnsignedInt();
         }
         throw new ArgumentError("The source argument must be an instance of flash.display.BitmapData or flash.utils.ByteArray.");
      }
   }
}

class BitString
{
   public var len:int = 0;
   
   public var val:int = 0;
   
   public function BitString()
   {
      super();
   }
}
