package game.pVP_Marbles
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class PVP_Marbles_Marble extends MovieClip
   {
      private static const FADE_RATE:Number = 0.1;
      
      public var _fadeIn:Boolean;
      
      public var _fadedOut:Function;
      
      public var _fadedIn:Function;
      
      public var _delayTime:Number;
      
      public function PVP_Marbles_Marble()
      {
         super();
      }
      
      public function fade(param1:Function) : void
      {
         alpha -= 0.1;
         _fadeIn = false;
         _fadedOut = param1;
         addEventListener("enterFrame",heartbeat);
      }
      
      public function heartbeat(param1:Event) : void
      {
         if(_fadeIn)
         {
            alpha += 0.1;
            if(alpha >= 1)
            {
               alpha = 1;
               removeEventListener("enterFrame",heartbeat);
               if(_fadedIn != null)
               {
                  _fadedIn(this);
               }
            }
         }
         else if(_delayTime > 0)
         {
            _delayTime -= 0.04;
         }
         else
         {
            alpha -= 0.1;
            if(alpha <= 0)
            {
               alpha = 0;
               _fadedOut(this);
               _fadeIn = true;
            }
         }
      }
   }
}

