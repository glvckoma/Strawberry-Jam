package movie
{
   public class MovieTreeNode extends MovieNode
   {
      private var _isCorrectChoice:Boolean;
      
      private var _nodeIndex:int;
      
      private var _parentDefId:int;
      
      public function MovieTreeNode(param1:Object)
      {
         super(param1);
         nodeIndex = 1;
      }
      
      public function get isCorrectChoice() : Boolean
      {
         return _isCorrectChoice;
      }
      
      public function set isCorrectChoice(param1:Boolean) : void
      {
         _isCorrectChoice = param1;
      }
      
      public function get nodeIndex() : int
      {
         return _nodeIndex;
      }
      
      public function set nodeIndex(param1:int) : void
      {
         _nodeIndex = param1;
      }
      
      public function get parentDefId() : int
      {
         return _parentDefId;
      }
      
      public function set parentDefId(param1:int) : void
      {
         _parentDefId = param1;
      }
   }
}

