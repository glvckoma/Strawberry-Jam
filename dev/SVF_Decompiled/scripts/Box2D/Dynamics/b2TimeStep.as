package Box2D.Dynamics
{
   public class b2TimeStep
   {
      public var dt:Number;
      
      public var inv_dt:Number;
      
      public var dtRatio:Number;
      
      public var maxIterations:int;
      
      public var warmStarting:Boolean;
      
      public var positionCorrection:Boolean;
      
      public function b2TimeStep()
      {
         super();
      }
   }
}

