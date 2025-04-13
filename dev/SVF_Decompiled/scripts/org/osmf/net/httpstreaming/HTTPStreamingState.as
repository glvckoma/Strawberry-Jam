package org.osmf.net.httpstreaming
{
   internal class HTTPStreamingState
   {
      internal static const INIT:String = "init";
      
      internal static const LOAD_SEEK:String = "loadSeek";
      
      internal static const LOAD_SEEK_RETRY_WAIT:String = "loadSeekRetryWait";
      
      internal static const LOAD:String = "load";
      
      internal static const LOAD_WAIT:String = "loadWait";
      
      internal static const LOAD_NEXT:String = "loadNext";
      
      internal static const LOAD_NEXT_RETRY_WAIT:String = "loadNextRetryWait";
      
      internal static const PLAY_START_SEEK:String = "playStartSeek";
      
      internal static const PLAY_START_NEXT:String = "playStartNext";
      
      internal static const PLAY_START_COMMON:String = "playStartCommon";
      
      internal static const PLAY:String = "play";
      
      internal static const END_SEGMENT:String = "endSegment";
      
      internal static const SEEK:String = "seek";
      
      internal static const STOP:String = "stop";
      
      internal static const HALT:String = "halt";
      
      public function HTTPStreamingState()
      {
         super();
      }
   }
}

