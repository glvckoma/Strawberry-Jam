package com.sbi.popup
{
   import flash.display.MovieClip;
   
   public dynamic class SBPopupSkin
   {
      public var s:MovieClip;
      
      public function SBPopupSkin(param1:MovieClip)
      {
         super();
         s = param1;
         if(!(s["c"] && s["ba"]))
         {
            throw new Error("skin " + s.name + " is missing parts!");
         }
      }
   }
}

