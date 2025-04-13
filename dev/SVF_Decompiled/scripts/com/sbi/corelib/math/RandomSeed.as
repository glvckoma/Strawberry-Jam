package com.sbi.corelib.math
{
   public class RandomSeed
   {
      protected static var _instance:RandomSeed;
      
      protected var _seed:uint = 0;
      
      protected var _currentSeed:uint = 0;
      
      public function RandomSeed(param1:uint = 1)
      {
         super();
         _seed = _currentSeed = param1;
      }
      
      public static function get instance() : RandomSeed
      {
         if(_instance == null)
         {
            _instance = new RandomSeed();
         }
         return _instance;
      }
      
      public static function get seed() : uint
      {
         return instance.seed;
      }
      
      public static function set seed(param1:uint) : void
      {
         instance.seed = param1;
      }
      
      public static function get currentSeed() : uint
      {
         return instance.currentSeed;
      }
      
      public static function random() : Number
      {
         return instance.random();
      }
      
      public static function float(param1:Number, param2:Number = NaN) : Number
      {
         return instance.float(param1,param2);
      }
      
      public static function boolean(param1:Number = 0.5) : Boolean
      {
         return instance.boolean(param1);
      }
      
      public static function sign(param1:Number = 0.5) : int
      {
         return instance.sign(param1);
      }
      
      public static function bit(param1:Number = 0.5) : int
      {
         return instance.bit(param1);
      }
      
      public static function integer(param1:Number, param2:Number = NaN) : int
      {
         return instance.integer(param1,param2);
      }
      
      public static function reset() : void
      {
         instance.reset();
      }
      
      public function get seed() : uint
      {
         return _seed;
      }
      
      public function set seed(param1:uint) : void
      {
         _seed = _currentSeed = param1;
      }
      
      public function get currentSeed() : uint
      {
         return _currentSeed;
      }
      
      public function random() : Number
      {
         return (_currentSeed = _currentSeed * 16807 % 2147483647) / 2147483647 + 2.33e-10;
      }
      
      public function float(param1:Number, param2:Number = NaN) : Number
      {
         if(isNaN(param2))
         {
            param2 = param1;
            param1 = 0;
         }
         return random() * (param2 - param1) + param1;
      }
      
      public function boolean(param1:Number = 0.5) : Boolean
      {
         return random() < param1;
      }
      
      public function sign(param1:Number = 0.5) : int
      {
         return random() < param1 ? 1 : -1;
      }
      
      public function bit(param1:Number = 0.5) : int
      {
         return random() < param1 ? 1 : 0;
      }
      
      public function integer(param1:Number, param2:Number = NaN) : int
      {
         if(isNaN(param2))
         {
            param2 = param1;
            param1 = 0;
         }
         return Math.floor(float(param1,param2));
      }
      
      public function reset() : void
      {
         _seed = _currentSeed;
      }
   }
}

