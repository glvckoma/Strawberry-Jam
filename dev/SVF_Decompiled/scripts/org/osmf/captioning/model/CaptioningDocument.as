package org.osmf.captioning.model
{
   import flash.errors.IllegalOperationError;
   import org.osmf.utils.OSMFStrings;
   
   public class CaptioningDocument
   {
      private var _title:String;
      
      private var _desc:String;
      
      private var _copyright:String;
      
      private var _captions:Vector.<Caption>;
      
      private var _styles:Vector.<CaptionStyle>;
      
      public function CaptioningDocument()
      {
         super();
      }
      
      public function get title() : String
      {
         return _title;
      }
      
      public function set title(param1:String) : void
      {
         _title = param1;
      }
      
      public function get description() : String
      {
         return _desc;
      }
      
      public function set description(param1:String) : void
      {
         _desc = param1;
      }
      
      public function get copyright() : String
      {
         return _copyright;
      }
      
      public function set copyright(param1:String) : void
      {
         _copyright = param1;
      }
      
      public function addStyle(param1:CaptionStyle) : void
      {
         if(_styles == null)
         {
            _styles = new Vector.<CaptionStyle>();
         }
         _styles.push(param1);
      }
      
      public function get numStyles() : int
      {
         var _loc1_:int = 0;
         if(_styles != null)
         {
            _loc1_ = int(_styles.length);
         }
         return _loc1_;
      }
      
      public function getStyleAt(param1:int) : CaptionStyle
      {
         if(_styles == null || param1 >= _styles.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
         }
         return _styles[param1];
      }
      
      public function addCaption(param1:Caption) : void
      {
         if(_captions == null)
         {
            _captions = new Vector.<Caption>();
         }
         _captions.push(param1);
      }
      
      public function get numCaptions() : int
      {
         var _loc1_:int = 0;
         if(_captions != null)
         {
            _loc1_ = int(_captions.length);
         }
         return _loc1_;
      }
      
      public function getCaptionAt(param1:int) : Caption
      {
         if(_captions == null || param1 >= _captions.length)
         {
            throw new IllegalOperationError(OSMFStrings.getString("invalidParam"));
         }
         return _captions[param1];
      }
   }
}

