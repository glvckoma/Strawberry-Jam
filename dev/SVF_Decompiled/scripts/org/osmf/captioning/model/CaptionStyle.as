package org.osmf.captioning.model
{
   public class CaptionStyle
   {
      private var _id:String;
      
      private var _backgroundColor:Object;
      
      private var _backgroundColorAlpha:Object;
      
      private var _textColor:Object;
      
      private var _textColorAlpha:Object;
      
      private var _fontFamily:String;
      
      private var _fontSize:int;
      
      private var _fontStyle:String;
      
      private var _fontWeight:String;
      
      private var _textAlign:String;
      
      private var _wrapOption:Boolean;
      
      public function CaptionStyle(param1:String)
      {
         super();
         _id = param1;
      }
      
      public function get id() : String
      {
         return _id;
      }
      
      public function get backgroundColor() : Object
      {
         return _backgroundColor;
      }
      
      public function set backgroundColor(param1:Object) : void
      {
         _backgroundColor = param1;
      }
      
      public function get backgroundColorAlpha() : Object
      {
         return _backgroundColorAlpha;
      }
      
      public function set backgroundColorAlpha(param1:Object) : void
      {
         _backgroundColorAlpha = param1;
      }
      
      public function get textColor() : Object
      {
         return _textColor;
      }
      
      public function set textColor(param1:Object) : void
      {
         _textColor = param1;
      }
      
      public function get textColorAlpha() : Object
      {
         return _textColorAlpha;
      }
      
      public function set textColorAlpha(param1:Object) : void
      {
         _textColorAlpha = param1;
      }
      
      public function get fontFamily() : String
      {
         return _fontFamily;
      }
      
      public function set fontFamily(param1:String) : void
      {
         _fontFamily = param1;
      }
      
      public function get fontSize() : int
      {
         return _fontSize;
      }
      
      public function set fontSize(param1:int) : void
      {
         _fontSize = param1;
      }
      
      public function get fontStyle() : String
      {
         return _fontStyle;
      }
      
      public function set fontStyle(param1:String) : void
      {
         _fontStyle = param1;
      }
      
      public function get fontWeight() : String
      {
         return _fontWeight;
      }
      
      public function set fontWeight(param1:String) : void
      {
         _fontWeight = param1;
      }
      
      public function get textAlign() : String
      {
         return _textAlign;
      }
      
      public function set textAlign(param1:String) : void
      {
         _textAlign = param1;
      }
      
      public function get wrapOption() : Boolean
      {
         return _wrapOption;
      }
      
      public function set wrapOption(param1:Boolean) : void
      {
         _wrapOption = param1;
      }
   }
}

