package game
{
   public interface IMinigame
   {
      function start(param1:uint, param2:Array) : void;
      
      function message(param1:Array) : void;
      
      function end(param1:Array) : void;
   }
}

