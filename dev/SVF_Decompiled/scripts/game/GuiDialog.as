package game
{
   import flash.display.MovieClip;
   
   public class GuiDialog
   {
      private var _mc:MovieClip;
      
      private var _buttons:Array;
      
      public function GuiDialog(param1:MovieClip, param2:Array)
      {
         var _loc6_:int = 0;
         var _loc9_:Object = null;
         var _loc5_:MovieClip = null;
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc7_:String = null;
         var _loc8_:GuiButton = null;
         super();
         _mc = param1;
         _buttons = [];
         while(_loc6_ < param2.length)
         {
            _loc9_ = param2[_loc6_];
            _loc5_ = _mc[_loc9_.name];
            if(!_loc5_)
            {
               _loc3_ = _loc9_.name;
               _loc4_ = _mc;
               while(_loc3_.indexOf(".") != -1)
               {
                  _loc7_ = _loc3_.substring(0,_loc3_.indexOf("."));
                  _loc4_ = _loc4_[_loc7_];
                  _loc3_ = _loc3_.substring(_loc3_.indexOf(".") + 1,_loc3_.length);
               }
               _loc5_ = _loc4_[_loc3_];
               if(!_loc5_)
               {
                  throw new Error("ERROR: Button Not Found:\" " + _loc9_.name + "\" verify button names across SWF files.");
               }
            }
            _loc8_ = new GuiButton(_loc5_,_loc9_.f);
            if(_loc9_.hasOwnProperty("grayed") && _loc9_.grayed == "yes")
            {
               _loc8_.setGrayState(true);
            }
            _buttons.push(_loc8_);
            _loc6_++;
         }
      }
      
      public function release() : void
      {
         var _loc1_:int = 0;
         while(_loc1_ < _buttons.length)
         {
            _buttons[_loc1_].release();
            _loc1_++;
         }
         _buttons = [];
      }
   }
}

