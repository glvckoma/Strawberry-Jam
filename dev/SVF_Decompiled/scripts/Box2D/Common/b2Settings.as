package Box2D.Common
{
   public class b2Settings
   {
      public static const USHRT_MAX:int = 65535;
      
      public static const b2_pi:Number = 3.141592653589793;
      
      public static const b2_maxManifoldPoints:int = 2;
      
      public static const b2_maxPolygonVertices:int = 8;
      
      public static const b2_maxProxies:int = 512;
      
      public static const b2_maxPairs:int = 4096;
      
      public static const b2_linearSlop:Number = 0.005;
      
      public static const b2_angularSlop:Number = 0.03490658503988659;
      
      public static const b2_toiSlop:Number = 0.04;
      
      public static const b2_maxTOIContactsPerIsland:int = 32;
      
      public static const b2_velocityThreshold:Number = 1;
      
      public static const b2_maxLinearCorrection:Number = 0.2;
      
      public static const b2_maxAngularCorrection:Number = 0.13962634015954636;
      
      public static const b2_maxLinearVelocity:Number = 200;
      
      public static const b2_maxLinearVelocitySquared:Number = 40000;
      
      public static const b2_maxAngularVelocity:Number = 250;
      
      public static const b2_maxAngularVelocitySquared:Number = 62500;
      
      public static const b2_contactBaumgarte:Number = 0.2;
      
      public static const b2_timeToSleep:Number = 0.5;
      
      public static const b2_linearSleepTolerance:Number = 0.01;
      
      public static const b2_angularSleepTolerance:Number = 0.011111111111111112;
      
      public function b2Settings()
      {
         super();
      }
      
      public static function b2Assert(param1:Boolean) : void
      {
         if(!param1)
         {
            null.x++;
         }
      }
   }
}

