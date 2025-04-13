package org.osmf.net.dvr
{
   import flash.net.Responder;
   
   internal class TestableResponder extends Responder
   {
      private var _result:Function;
      
      private var _status:Function;
      
      public function TestableResponder(param1:Function, param2:Function = null)
      {
         _result = param1;
         _status = param2;
         super(param1,param2);
      }
      
      internal function get result() : Function
      {
         return _result;
      }
      
      internal function get status() : Function
      {
         return _status;
      }
   }
}

