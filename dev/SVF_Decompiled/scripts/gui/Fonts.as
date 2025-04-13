package gui
{
   import flash.text.Font;
   import flash.text.TextFormat;
   
   public class Fonts
   {
      public static var defaultFont:Font;
      
      public static var defaultFontBold:Font;
      
      public static var titleFont:Font;
      
      public static var defaultFontFormat:TextFormat;
      
      public static var defaultFontBoldFormat:TextFormat;
      
      public static var defaultFontRedFormat:TextFormat;
      
      public static var defaultFontBlackFormat:TextFormat;
      
      public static var titleFontFormat:TextFormat;
      
      public function Fonts()
      {
         super();
      }
      
      public static function init() : void
      {
         defaultFontFormat = new TextFormat();
         defaultFontBoldFormat = new TextFormat();
         defaultFontBoldFormat.bold = true;
         defaultFontRedFormat = new TextFormat();
         defaultFontRedFormat.color = 13369344;
         defaultFontBlackFormat = new TextFormat();
         defaultFontBlackFormat.color = 0;
         titleFontFormat = new TextFormat();
      }
   }
}

