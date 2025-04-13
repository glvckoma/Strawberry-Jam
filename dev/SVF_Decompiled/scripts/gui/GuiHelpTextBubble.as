package gui
{
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class GuiHelpTextBubble extends MovieClip
   {
      public var soundBtn:MovieClip;
      
      public var txt:TextField;
      
      public var tl:MovieClip;
      
      public var tr:MovieClip;
      
      public var bl:MovieClip;
      
      public var bl2:MovieClip;
      
      public var br:MovieClip;
      
      public var bubble:MovieClip;
      
      public var helpBubbleBG:MovieClip = null;
      
      public var helpBubble:MovieClip = null;
      
      public function GuiHelpTextBubble()
      {
         super();
         soundBtn = this["soundBtn"];
         txt = this["txt"];
         tl = this["tl"];
         tr = this["tr"];
         bl = this["bl"];
         bl2 = this["bl2"];
         br = this["br"];
         bubble = this["bubble"];
         if(!soundBtn)
         {
            throw new Error("GuiHelpTextBubble MAIN BUTTONS is missing part or they are named incorrectly!");
         }
         if(!(tl && tr && bl && bl2 && br && bubble))
         {
            throw new Error("GuiHelpTextBubble MAIN CONTENTS section is missing parts or they are named incorrectly!");
         }
         if(!txt)
         {
            throw new Error("GuiHelpTextBubble TEXT FIELDS section is missing parts or they are named incorrectly!");
         }
      }
      
      public function init(param1:Number = undefined, param2:Number = undefined) : void
      {
         visible = false;
         txt.autoSize = "center";
      }
      
      public function setText(param1:String) : void
      {
         txt.text = param1;
      }
      
      public function setPos(param1:int, param2:int) : void
      {
         this.x = param1;
         this.y = param2;
      }
      
      public function bringToFront() : void
      {
         parent.setChildIndex(this,parent.numChildren - 1);
      }
      
      public function setTails(param1:Boolean = false, param2:Boolean = false, param3:Boolean = false) : void
      {
         if(param3)
         {
            tl.visible = false;
            tr.visible = false;
            bl.visible = false;
            br.visible = false;
            bl2.visible = true;
         }
         else if(param1)
         {
            if(param2)
            {
               tl.visible = true;
               tr.visible = false;
               bl.visible = false;
               br.visible = false;
               bl2.visible = false;
            }
            else
            {
               tl.visible = false;
               tr.visible = true;
               bl.visible = false;
               br.visible = false;
               bl2.visible = false;
            }
         }
         else if(param2)
         {
            tl.visible = false;
            tr.visible = false;
            bl.visible = true;
            br.visible = false;
            bl2.visible = false;
         }
         else
         {
            tl.visible = false;
            tr.visible = false;
            bl.visible = false;
            br.visible = true;
            bl2.visible = false;
         }
      }
   }
}

