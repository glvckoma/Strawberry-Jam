package flash.compiler.embed
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.system.ApplicationDomain;
   import flash.system.LoaderContext;
   import flash.utils.ByteArray;
   
   public class EmbeddedMovieClip extends MovieClip
   {
      private var loader:Loader = null;
      
      private var initialized:Boolean = false;
      
      private var requestedWidth:Number;
      
      private var requestedHeight:Number;
      
      private var bytes:ByteArray;
      
      protected var initialWidth:Number = 0;
      
      protected var initialHeight:Number = 0;
      
      public function EmbeddedMovieClip(param1:ByteArray, param2:Number, param3:Number)
      {
         super();
         this.bytes = param1;
         this.initialWidth = param2;
         this.initialHeight = param3;
         var _loc4_:LoaderContext = new LoaderContext();
         _loc4_.applicationDomain = new ApplicationDomain(ApplicationDomain.currentDomain);
         if("allowLoadBytesCodeExecution" in _loc4_)
         {
            _loc4_["allowLoadBytesCodeExecution"] = true;
         }
         this.loader = new Loader();
         this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.completeHandler);
         this.loader.loadBytes(this.movieClipData,_loc4_);
         addChild(this.loader);
      }
      
      override public function get height() : Number
      {
         if(!this.initialized)
         {
            return this.initialHeight;
         }
         return super.height;
      }
      
      override public function set height(param1:Number) : void
      {
         if(!this.initialized)
         {
            this.requestedHeight = param1;
         }
         else
         {
            this.loader.height = param1;
         }
      }
      
      override public function get width() : Number
      {
         if(!this.initialized)
         {
            return this.initialWidth;
         }
         return super.width;
      }
      
      override public function set width(param1:Number) : void
      {
         if(!this.initialized)
         {
            this.requestedWidth = param1;
         }
         else
         {
            this.loader.width = param1;
         }
      }
      
      public function get movieClipData() : ByteArray
      {
         return this.bytes;
      }
      
      private function completeHandler(param1:Event) : void
      {
         this.initialized = true;
         this.initialWidth = this.loader.contentLoaderInfo.width;
         this.initialHeight = this.loader.contentLoaderInfo.height;
         if(!isNaN(this.requestedWidth))
         {
            this.loader.width = this.requestedWidth;
         }
         if(!isNaN(this.requestedHeight))
         {
            this.loader.height = this.requestedHeight;
         }
         dispatchEvent(param1);
      }
   }
}

