package org.osmf.net.httpstreaming.f4f
{
   public class AdobeBootstrapBox extends FullBox
   {
      private var _bootstrapVersion:uint;
      
      private var _profile:uint;
      
      private var _live:Boolean;
      
      private var _update:Boolean;
      
      private var _timeScale:uint;
      
      private var _currentMediaTime:Number;
      
      private var _smpteTimeCodeOffset:Number;
      
      private var _movieIdentifier:String;
      
      private var _serverEntryCount:uint;
      
      private var _serverBaseURLs:Vector.<String>;
      
      private var _qualitySegmentURLModifiers:Vector.<String>;
      
      private var _drmData:String;
      
      private var _metadata:String;
      
      private var _segmentRunTables:Vector.<AdobeSegmentRunTable>;
      
      private var _fragmentRunTables:Vector.<AdobeFragmentRunTable>;
      
      public function AdobeBootstrapBox()
      {
         super();
      }
      
      public function get bootstrapVersion() : uint
      {
         return _bootstrapVersion;
      }
      
      public function set bootstrapVersion(param1:uint) : void
      {
         _bootstrapVersion = param1;
      }
      
      public function get profile() : uint
      {
         return _profile;
      }
      
      public function set profile(param1:uint) : void
      {
         _profile = param1;
      }
      
      public function get live() : Boolean
      {
         return _live;
      }
      
      public function set live(param1:Boolean) : void
      {
         _live = param1;
      }
      
      public function get update() : Boolean
      {
         return _update;
      }
      
      public function set update(param1:Boolean) : void
      {
         _update = param1;
      }
      
      public function get timeScale() : uint
      {
         return _timeScale;
      }
      
      public function set timeScale(param1:uint) : void
      {
         _timeScale = param1;
      }
      
      public function get currentMediaTime() : Number
      {
         return _currentMediaTime;
      }
      
      public function set currentMediaTime(param1:Number) : void
      {
         _currentMediaTime = param1;
      }
      
      public function get smpteTimeCodeOffset() : Number
      {
         return _smpteTimeCodeOffset;
      }
      
      public function set smpteTimeCodeOffset(param1:Number) : void
      {
         _smpteTimeCodeOffset = param1;
      }
      
      public function get movieIdentifier() : String
      {
         return _movieIdentifier;
      }
      
      public function set movieIdentifier(param1:String) : void
      {
         _movieIdentifier = param1;
      }
      
      public function get serverBaseURLs() : Vector.<String>
      {
         return _serverBaseURLs;
      }
      
      public function set serverBaseURLs(param1:Vector.<String>) : void
      {
         _serverBaseURLs = param1;
      }
      
      public function get qualitySegmentURLModifiers() : Vector.<String>
      {
         return _qualitySegmentURLModifiers;
      }
      
      public function set qualitySegmentURLModifiers(param1:Vector.<String>) : void
      {
         _qualitySegmentURLModifiers = param1;
      }
      
      public function get drmData() : String
      {
         return _drmData;
      }
      
      public function set drmData(param1:String) : void
      {
         _drmData = param1;
      }
      
      public function get metadata() : String
      {
         return _metadata;
      }
      
      public function set metadata(param1:String) : void
      {
         _metadata = param1;
      }
      
      public function get segmentRunTables() : Vector.<AdobeSegmentRunTable>
      {
         return _segmentRunTables;
      }
      
      public function set segmentRunTables(param1:Vector.<AdobeSegmentRunTable>) : void
      {
         _segmentRunTables = param1;
      }
      
      public function get fragmentRunTables() : Vector.<AdobeFragmentRunTable>
      {
         return _fragmentRunTables;
      }
      
      public function set fragmentRunTables(param1:Vector.<AdobeFragmentRunTable>) : void
      {
         var _loc2_:AdobeFragmentRunTable = null;
         _fragmentRunTables = param1;
         if(param1 != null && param1.length > 0)
         {
            _loc2_ = param1[param1.length - 1];
            _loc2_.adjustEndEntryDurationAccrued(_currentMediaTime);
         }
      }
      
      public function findSegmentId(param1:uint) : uint
      {
         return _segmentRunTables[0].findSegmentIdByFragmentId(param1);
      }
      
      public function get totalFragments() : uint
      {
         var _loc4_:AdobeFragmentRunTable = _fragmentRunTables[_fragmentRunTables.length - 1];
         var _loc5_:Vector.<FragmentDurationPair> = _loc4_.fragmentDurationPairs;
         var _loc1_:FragmentDurationPair = _loc5_[_loc5_.length - 1];
         if(_loc1_.duration == 0)
         {
            _loc1_ = _loc5_[_loc5_.length - 2];
         }
         var _loc3_:Number = _currentMediaTime - _loc1_.durationAccrued;
         var _loc2_:uint = _loc3_ <= 0 ? 0 : _loc3_ / _loc1_.duration;
         return _loc1_.firstFragment + _loc2_ - 1;
      }
      
      public function get totalDuration() : uint
      {
         if(_fragmentRunTables == null || _fragmentRunTables.length < 1)
         {
            return 0;
         }
         var _loc1_:AdobeFragmentRunTable = _fragmentRunTables[0];
         return _currentMediaTime - _loc1_.fragmentDurationPairs[0].durationAccrued;
      }
      
      public function contentComplete() : Boolean
      {
         var _loc1_:AdobeFragmentRunTable = _fragmentRunTables[_fragmentRunTables.length - 1];
         return _loc1_.tableComplete();
      }
   }
}

