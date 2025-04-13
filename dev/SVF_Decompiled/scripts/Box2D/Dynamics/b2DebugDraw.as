package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import flash.display.Sprite;
   
   public class b2DebugDraw
   {
      public static var e_shapeBit:uint = 1;
      
      public static var e_jointBit:uint = 2;
      
      public static var e_coreShapeBit:uint = 4;
      
      public static var e_aabbBit:uint = 8;
      
      public static var e_obbBit:uint = 16;
      
      public static var e_pairBit:uint = 32;
      
      public static var e_centerOfMassBit:uint = 64;
      
      public var m_drawFlags:uint;
      
      public var m_sprite:Sprite;
      
      public var m_drawScale:Number = 1;
      
      public var m_lineThickness:Number = 1;
      
      public var m_alpha:Number = 1;
      
      public var m_fillAlpha:Number = 1;
      
      public var m_xformScale:Number = 1;
      
      public function b2DebugDraw()
      {
         super();
         m_drawFlags = 0;
      }
      
      public function SetFlags(param1:uint) : void
      {
         m_drawFlags = param1;
      }
      
      public function GetFlags() : uint
      {
         return m_drawFlags;
      }
      
      public function AppendFlags(param1:uint) : void
      {
         m_drawFlags |= param1;
      }
      
      public function ClearFlags(param1:uint) : void
      {
         m_drawFlags &= ~param1;
      }
      
      public function DrawPolygon(param1:Array, param2:int, param3:b2Color) : void
      {
         var _loc4_:int = 0;
         m_sprite.graphics.lineStyle(m_lineThickness,param3.color,m_alpha);
         m_sprite.graphics.moveTo(param1[0].x * m_drawScale,param1[0].y * m_drawScale);
         _loc4_ = 1;
         while(_loc4_ < param2)
         {
            m_sprite.graphics.lineTo(param1[_loc4_].x * m_drawScale,param1[_loc4_].y * m_drawScale);
            _loc4_++;
         }
         m_sprite.graphics.lineTo(param1[0].x * m_drawScale,param1[0].y * m_drawScale);
      }
      
      public function DrawSolidPolygon(param1:Array, param2:int, param3:b2Color) : void
      {
         var _loc4_:int = 0;
         m_sprite.graphics.lineStyle(m_lineThickness,param3.color,m_alpha);
         m_sprite.graphics.moveTo(param1[0].x * m_drawScale,param1[0].y * m_drawScale);
         m_sprite.graphics.beginFill(param3.color,m_fillAlpha);
         _loc4_ = 1;
         while(_loc4_ < param2)
         {
            m_sprite.graphics.lineTo(param1[_loc4_].x * m_drawScale,param1[_loc4_].y * m_drawScale);
            _loc4_++;
         }
         m_sprite.graphics.lineTo(param1[0].x * m_drawScale,param1[0].y * m_drawScale);
         m_sprite.graphics.endFill();
      }
      
      public function DrawCircle(param1:b2Vec2, param2:Number, param3:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,param3.color,m_alpha);
         m_sprite.graphics.drawCircle(param1.x * m_drawScale,param1.y * m_drawScale,param2 * m_drawScale);
      }
      
      public function DrawSolidCircle(param1:b2Vec2, param2:Number, param3:b2Vec2, param4:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,param4.color,m_alpha);
         m_sprite.graphics.moveTo(0,0);
         m_sprite.graphics.beginFill(param4.color,m_fillAlpha);
         m_sprite.graphics.drawCircle(param1.x * m_drawScale,param1.y * m_drawScale,param2 * m_drawScale);
         m_sprite.graphics.endFill();
         m_sprite.graphics.moveTo(param1.x * m_drawScale,param1.y * m_drawScale);
         m_sprite.graphics.lineTo((param1.x + param3.x * param2) * m_drawScale,(param1.y + param3.y * param2) * m_drawScale);
      }
      
      public function DrawSegment(param1:b2Vec2, param2:b2Vec2, param3:b2Color) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,param3.color,m_alpha);
         m_sprite.graphics.moveTo(param1.x * m_drawScale,param1.y * m_drawScale);
         m_sprite.graphics.lineTo(param2.x * m_drawScale,param2.y * m_drawScale);
      }
      
      public function DrawXForm(param1:b2XForm) : void
      {
         m_sprite.graphics.lineStyle(m_lineThickness,16711680,m_alpha);
         m_sprite.graphics.moveTo(param1.position.x * m_drawScale,param1.position.y * m_drawScale);
         m_sprite.graphics.lineTo((param1.position.x + m_xformScale * param1.R.col1.x) * m_drawScale,(param1.position.y + m_xformScale * param1.R.col1.y) * m_drawScale);
         m_sprite.graphics.lineStyle(m_lineThickness,65280,m_alpha);
         m_sprite.graphics.moveTo(param1.position.x * m_drawScale,param1.position.y * m_drawScale);
         m_sprite.graphics.lineTo((param1.position.x + m_xformScale * param1.R.col2.x) * m_drawScale,(param1.position.y + m_xformScale * param1.R.col2.y) * m_drawScale);
      }
   }
}

