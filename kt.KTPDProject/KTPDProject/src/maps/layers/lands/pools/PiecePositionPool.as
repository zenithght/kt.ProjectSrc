// // // // // /////////////////////////////////////////////////
// PiecePositionPool.as
// Macromedia ActionScript Implementation of the Class PiecePositionPool
// Generated by Enterprise Architect
// Created on:      11-五月-2012 15:20:02
// Original author: ZengFeng
// // // // // /////////////////////////////////////////////////
package maps.layers.lands.pools
{
    import maps.layers.lands.pieces.PiecePosition;
    /**
     * 地图块位置
     * @author ZengFeng
     * @version 1.0
     * @updated 11-五月-2012 16:16:12
     */
    public class PiecePositionPool
    {
        /** 单例对像 */
        private static var _instance : PiecePositionPool;

        /** 获取单例对像 */
        static public function get instance() : PiecePositionPool
        {
            if (_instance == null)
            {
                _instance = new PiecePositionPool(new Singleton());
            }
            return _instance;
        }

        private var list : Vector.<PiecePosition> = new Vector.<PiecePosition>();

        function PiecePositionPool(singleton : Singleton)
        {
        }

        public function getObject() : PiecePosition
        {
            if (list.length > 0)
            {
                return list.pop();
            }
            return new PiecePosition();
        }

        public function destoryObject(piecePosition : PiecePosition, destoryed:Boolean = false) : void
        {
            if (piecePosition == null) return;
            if (list.indexOf(piecePosition) != -1) return;
            if(!destoryed) piecePosition.dispose();
            list.push(piecePosition);
        }
    }
}
class Singleton
{
}